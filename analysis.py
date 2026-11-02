import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Keep this script in the same folder as the CSV file.
df = pd.read_csv("customer_support_interactions.csv", parse_dates=["interaction_date"])

# Basic data quality checks
print("Shape:", df.shape)
print("\nMissing values:\n", df.isna().sum())
print("\nDuplicate interaction IDs:", df["interaction_id"].duplicated().sum())

# Clean and prepare
df = df.drop_duplicates(subset=["interaction_id"]).copy()
df["month"] = df["interaction_date"].dt.to_period("M").astype(str)
df["resolution_status"] = np.where(df["resolved_flag"].eq(1), "Resolved", "Unresolved")
df["retention_status"] = np.where(df["retained_flag"].eq(1), "Retained", "Not Retained")

# KPI summary
kpis = pd.DataFrame({
    "Metric": ["Total interactions", "Resolution rate (%)", "Retention rate (%)",
               "Repeat contact rate (%)", "Average CSAT", "Average handling time (min)"],
    "Value": [len(df), df["resolved_flag"].mean()*100, df["retained_flag"].mean()*100,
              df["repeat_contact_flag"].mean()*100, df["csat_score"].mean(),
              df["handling_time_min"].mean()]
})
print("\nKPI SUMMARY\n", kpis.round(2).to_string(index=False))
kpis.to_csv("python_kpi_summary.csv", index=False)

# Monthly trend
monthly = df.groupby("month").agg(
    interactions=("interaction_id", "count"),
    resolution_rate=("resolved_flag", "mean"),
    retention_rate=("retained_flag", "mean"),
    avg_csat=("csat_score", "mean")
).reset_index()
monthly[["resolution_rate", "retention_rate"]] *= 100
monthly.to_csv("python_monthly_trend.csv", index=False)

# Agent scorecard
agent = df.groupby(["agent_id", "agent_name"]).agg(
    interactions=("interaction_id", "count"),
    resolution_rate=("resolved_flag", "mean"),
    retention_rate=("retained_flag", "mean"),
    avg_csat=("csat_score", "mean")
).reset_index()
agent[["resolution_rate", "retention_rate"]] *= 100
agent = agent.sort_values("avg_csat", ascending=False)
agent.to_csv("python_agent_scorecard.csv", index=False)

# Visualizations
monthly.plot(x="month", y=["resolution_rate", "retention_rate"], marker="o",
             title="Monthly Resolution and Retention Rates")
plt.ylabel("Rate (%)")
plt.tight_layout()
plt.savefig("monthly_trends.png", dpi=150)
plt.show()

df.groupby("channel")["handling_time_min"].mean().sort_values().plot(
    kind="bar", title="Average Handling Time by Channel")
plt.ylabel("Minutes")
plt.tight_layout()
plt.savefig("handling_time_by_channel.png", dpi=150)
plt.show()

print("\nOutputs saved: KPI summary, monthly trend, agent scorecard and charts.")