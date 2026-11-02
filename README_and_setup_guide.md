# Customer Support & Retention Analytics — Portfolio Project

## Project overview
Analyze 5,000 fictional customer support interactions recorded during 2025. The goal is to measure service efficiency, customer retention, repeat contacts, customer satisfaction (CSAT), and agent performance.

**Data is synthetic and created for portfolio practice. It is not Foundever data.**

## Files
- `customer_support_interactions.csv` — source dataset for all tools
- `support_retention_analysis.xlsx` — Excel workbook with raw data, KPI dashboard, monthly and agent summaries
- `analysis_queries.sql` — MySQL table definition and 8 analytical queries
- `analysis.py` — Python data-quality checks, analysis, CSV outputs and charts
- `dashboard_build_guide.md` — Power BI and Tableau build steps, DAX and calculated fields

## Dataset dictionary
- `interaction_id`: unique interaction key
- `interaction_date`: date of contact
- `customer_id`: fictional customer key
- `agent_id`, `agent_name`: assigned agent
- `region`: North, South, East, West
- `channel`: Phone, Email, Chat
- `issue_type`: Billing, Technical Support, Cancellation, Account Access, Product Inquiry
- `customer_plan`: Basic, Standard, Premium
- `handling_time_min`, `wait_time_min`: minutes
- `resolved_flag`, `repeat_contact_flag`, `retained_flag`: 1 = Yes, 0 = No
- `csat_score`: customer satisfaction score from 1 to 5

## 1) MySQL — import and run
1. Install/open MySQL Workbench and connect to your local MySQL server.
2. Open `analysis_queries.sql` and execute the database/table creation section.
3. In the SCHEMAS panel, right-click `fact_interactions` → **Table Data Import Wizard**.
4. Select `customer_support_interactions.csv`, choose comma delimiter, map columns, and import.
5. Run each numbered SELECT query in the SQL file. Save screenshots of query results for your portfolio.
6. If import wizard reports a date/type issue, confirm `interaction_date` is parsed as `YYYY-MM-DD` and numeric flags as integers.

## 2) Advanced Excel — open and explore
1. Open `support_retention_analysis.xlsx` in Excel.
2. Start on `KPI_Dashboard`; inspect the KPI formulas and charts.
3. On `Raw_Data`, click inside the dataset and press Ctrl+T to convert it to an Excel Table (if not already formatted).
4. Practice formulas in new columns:
   - `=TEXT([@interaction_date],"mmm-yyyy")`
   - `=IF([@resolved_flag]=1,"Resolved","Unresolved")`
   - `=IF([@retained_flag]=1,"Retained","Not Retained")`
   - `=IF([@csat_score]>=4,"Satisfied","Needs Attention")`
   - `=COUNTIF(Raw_Data[repeat_contact_flag],1)`
   - `=AVERAGEIFS(Raw_Data[handling_time_min],Raw_Data[channel],"Phone")`
5. Create PivotTables: Rows = channel / issue_type / agent_name; Values = count of interaction_id, average of csat_score, average of resolved_flag.
6. Add slicers for region, channel, customer_plan and issue_type. Format percentage metrics as percentages.

## 3) Python — run the analysis
1. Install Python 3.10+ and open Terminal/Command Prompt in this project folder.
2. Install dependencies: `pip install pandas numpy matplotlib`
3. Run: `python analysis.py`
4. Review the printed KPI summary and generated files: `python_kpi_summary.csv`, `python_monthly_trend.csv`, `python_agent_scorecard.csv`, `monthly_trends.png`, `handling_time_by_channel.png`.
5. To explore interactively, open the script in VS Code or Jupyter and run it cell-by-cell.

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

## Business questions to answer in your interview
1. Which support channel has the highest average handling time?
2. Which issue type has the highest repeat-contact rate?
3. How do resolution and retention rates change month by month?
4. Which agents combine strong CSAT with high interaction volume?
5. What operational action would you recommend to reduce repeat contacts?

## Resume-ready project entry
**Customer Support & Retention Analytics | MySQL, Power BI, Tableau, Advanced Excel, Python**
- Analyzed 5,000+ fictional customer support interactions to evaluate resolution rate, retention, repeat contacts, CSAT and agent productivity.
- Used MySQL aggregations, joins/CTEs and window functions to answer operational performance questions.
- Cleaned and explored data using Python (Pandas, NumPy) and generated KPI summaries and trend visualizations.
- Built an Excel KPI dashboard with formulas, summary analysis and charts; designed interactive Power BI and Tableau dashboards with calculated metrics and filters.
- Translated findings into recommendations to improve service efficiency and customer retention.

**Interview honesty note:** Describe the Power BI and Tableau dashboards as completed only after you build and save them yourself. Until then, say you are developing those dashboard versions. The supplied workbook and scripts are ready to open and practice with.