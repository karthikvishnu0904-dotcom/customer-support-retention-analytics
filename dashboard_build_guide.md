## 4) Power BI — build the dashboard
1. Open Power BI Desktop → **Get Data** → **Text/CSV** → select `customer_support_interactions.csv` → Load.
2. In Power Query, set `interaction_date` to Date; time fields to Decimal Number; flags to Whole Number; CSAT to Whole Number. Choose **Close & Apply**.
3. Create the measures below (Modeling → New measure):

```DAX
Total Interactions = COUNTROWS('customer_support_interactions')

Resolution Rate = DIVIDE(SUM('customer_support_interactions'[resolved_flag]), [Total Interactions])

Retention Rate = DIVIDE(SUM('customer_support_interactions'[retained_flag]), [Total Interactions])

Repeat Contact Rate = DIVIDE(SUM('customer_support_interactions'[repeat_contact_flag]), [Total Interactions])

Average CSAT = AVERAGE('customer_support_interactions'[csat_score])

Average Handling Time = AVERAGE('customer_support_interactions'[handling_time_min])

Average Wait Time = AVERAGE('customer_support_interactions'[wait_time_min])

Unique Customers = DISTINCTCOUNT('customer_support_interactions'[customer_id])
```

4. Format the three rate measures as Percentage (Modeling → Format).
5. Suggested one-page layout:
   - Top row: Card visuals for Total Interactions, Resolution Rate, Retention Rate, Average CSAT.
   - Middle: Line chart (interaction_date by month; Resolution Rate and Retention Rate).
   - Bottom left: Clustered bar chart (agent_name by Average CSAT).
   - Bottom middle: Column chart (issue_type by Repeat Contact Rate).
   - Bottom right: Bar chart (channel by Average Handling Time).
   - Add slicers for region, channel, customer_plan, issue_type and interaction_date.
6. Save as `Customer_Support_Retention.pbix`. Take a screenshot of the finished report page.

## 5) Tableau — build the dashboard
1. Open Tableau Public or Tableau Desktop → Connect → To a File → Text File.
2. Select `customer_support_interactions.csv`; confirm data types in the Data Source tab.
3. Create calculated fields (Analysis → Create Calculated Field):
   - `Total Interactions`: `COUNT([interaction_id])`
   - `Resolution Rate`: `AVG([resolved_flag])`
   - `Retention Rate`: `AVG([retained_flag])`
   - `Repeat Contact Rate`: `AVG([repeat_contact_flag])`
   - `Average CSAT`: `AVG([csat_score])`
   - `Average Handling Time`: `AVG([handling_time_min])`
4. Format Resolution Rate, Retention Rate and Repeat Contact Rate as Percentage.
5. Build worksheets:
   - KPI sheet: use the KPI measures as text labels.
   - Monthly Trend: MONTH([interaction_date]) on Columns; Resolution Rate and Retention Rate on Rows (use Measure Values if needed).
   - Agent Scorecard: agent_name on Rows; Average CSAT and Resolution Rate on Columns.
   - Issue Analysis: issue_type on Rows; Repeat Contact Rate on Columns.
   - Channel Analysis: channel on Rows; Average Handling Time on Columns.
6. Create a Dashboard, arrange the sheets, and add filters for region, channel, customer_plan and issue_type. Set filters to apply to all worksheets.
7. Save as `.twb` (Tableau workbook) or publish to Tableau Public if you want a shareable portfolio link. Do not publish customer-identifiable real data; this dataset is synthetic.