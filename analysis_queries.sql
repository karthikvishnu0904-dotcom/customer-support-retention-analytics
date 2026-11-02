CREATE DATABASE IF NOT EXISTS support_retention_analytics;
USE support_retention_analytics;

DROP TABLE IF EXISTS fact_interactions;
CREATE TABLE fact_interactions (
    interaction_id VARCHAR(20) PRIMARY KEY,
    interaction_date DATE NOT NULL,
    customer_id VARCHAR(20) NOT NULL,
    agent_id VARCHAR(10) NOT NULL,
    agent_name VARCHAR(50) NOT NULL,
    region VARCHAR(20) NOT NULL,
    channel VARCHAR(20) NOT NULL,
    issue_type VARCHAR(40) NOT NULL,
    customer_plan VARCHAR(20) NOT NULL,
    handling_time_min DECIMAL(6,1),
    wait_time_min DECIMAL(6,1),
    resolved_flag TINYINT NOT NULL,
    repeat_contact_flag TINYINT NOT NULL,
    retained_flag TINYINT NOT NULL,
    csat_score TINYINT NOT NULL
);

-- Import customer_support_interactions.csv into this table using MySQL Workbench
-- Table Data Import Wizard, or LOAD DATA LOCAL INFILE if enabled.

-- 1. Overall KPI scorecard
SELECT COUNT(*) AS total_interactions,
       ROUND(AVG(resolved_flag)*100,2) AS resolution_rate_pct,
       ROUND(AVG(retained_flag)*100,2) AS retention_rate_pct,
       ROUND(AVG(repeat_contact_flag)*100,2) AS repeat_contact_rate_pct,
       ROUND(AVG(csat_score),2) AS avg_csat,
       ROUND(AVG(handling_time_min),2) AS avg_handling_time_min,
       ROUND(AVG(wait_time_min),2) AS avg_wait_time_min
FROM fact_interactions;

-- 2. Monthly operational trend
SELECT DATE_FORMAT(interaction_date, '%Y-%m') AS month,
       COUNT(*) AS interactions,
       ROUND(AVG(resolved_flag)*100,2) AS resolution_rate_pct,
       ROUND(AVG(retained_flag)*100,2) AS retention_rate_pct,
       ROUND(AVG(csat_score),2) AS avg_csat
FROM fact_interactions
GROUP BY DATE_FORMAT(interaction_date, '%Y-%m')
ORDER BY month;

-- 3. Channel performance
SELECT channel, COUNT(*) AS interactions,
       ROUND(AVG(handling_time_min),2) AS avg_handling_time,
       ROUND(AVG(wait_time_min),2) AS avg_wait_time,
       ROUND(AVG(resolved_flag)*100,2) AS resolution_rate_pct,
       ROUND(AVG(csat_score),2) AS avg_csat
FROM fact_interactions
GROUP BY channel
ORDER BY interactions DESC;

-- 4. Agent performance ranking
SELECT agent_id, agent_name, COUNT(*) AS interactions,
       ROUND(AVG(resolved_flag)*100,2) AS resolution_rate_pct,
       ROUND(AVG(retained_flag)*100,2) AS retention_rate_pct,
       ROUND(AVG(csat_score),2) AS avg_csat,
       DENSE_RANK() OVER (ORDER BY AVG(csat_score) DESC) AS csat_rank
FROM fact_interactions
GROUP BY agent_id, agent_name
ORDER BY csat_rank;

-- 5. Issue types with highest repeat contacts
SELECT issue_type, COUNT(*) AS interactions,
       ROUND(AVG(repeat_contact_flag)*100,2) AS repeat_contact_rate_pct,
       ROUND(AVG(resolved_flag)*100,2) AS resolution_rate_pct
FROM fact_interactions
GROUP BY issue_type
ORDER BY repeat_contact_rate_pct DESC;

-- 6. Customer-level interaction frequency using CTE
WITH customer_activity AS (
    SELECT customer_id, COUNT(*) AS interaction_count,
           SUM(retained_flag) AS retained_interactions,
           AVG(csat_score) AS avg_csat
    FROM fact_interactions
    GROUP BY customer_id
)
SELECT customer_id, interaction_count,
       ROUND(avg_csat,2) AS avg_csat,
       CASE WHEN interaction_count >= 5 THEN 'High Contact'
            WHEN interaction_count >= 3 THEN 'Medium Contact'
            ELSE 'Low Contact' END AS contact_segment
FROM customer_activity
ORDER BY interaction_count DESC
LIMIT 20;

-- 7. Running monthly interaction total
WITH monthly AS (
    SELECT DATE_FORMAT(interaction_date, '%Y-%m') AS month,
           COUNT(*) AS interactions
    FROM fact_interactions
    GROUP BY DATE_FORMAT(interaction_date, '%Y-%m')
)
SELECT month, interactions,
       SUM(interactions) OVER (ORDER BY month) AS running_total
FROM monthly
ORDER BY month;

-- 8. Compare resolution by issue and channel
SELECT issue_type, channel, COUNT(*) AS interactions,
       ROUND(AVG(resolved_flag)*100,2) AS resolution_rate_pct
FROM fact_interactions
GROUP BY issue_type, channel
ORDER BY issue_type, resolution_rate_pct DESC;