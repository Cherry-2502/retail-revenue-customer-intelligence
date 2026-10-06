-- ==============================================================================
-- 03_advanced_analysis.sql
-- E-Commerce Sales & Customer Analytics: Advanced SQL Queries (Q11 - Q15)
-- Schema: retail_transactions (PostgreSQL)
-- Window functions, CTEs, Cohort analysis & RFM metrics
-- ==============================================================================

-- Q11: Rank Products by Revenue within Each Country (Window Function: RANK)
WITH product_country_rev AS (
    SELECT
        country,
        description,
        ROUND(SUM(revenue), 2) AS revenue
    FROM retail_transactions
    WHERE NOT is_cancelled 
      AND stock_code NOT IN ('POST', 'D', 'M', 'BANK CHARGES', 'DOT', 'CRUK')
    GROUP BY country, description
)
SELECT
    country,
    description,
    revenue,
    RANK() OVER (PARTITION BY country ORDER BY revenue DESC) AS rank_in_country
FROM product_country_rev
ORDER BY country, rank_in_country;


-- Q12: Month-over-Month (MoM) Revenue Growth (Window Function: LAG)
WITH monthly_rev AS (
    SELECT
        DATE_TRUNC('month', invoice_date) AS month_date,
        TO_CHAR(DATE_TRUNC('month', invoice_date), 'YYYY-MM') AS year_month,
        ROUND(SUM(revenue), 2) AS revenue
    FROM retail_transactions
    GROUP BY DATE_TRUNC('month', invoice_date)
    ORDER BY DATE_TRUNC('month', invoice_date)
)
SELECT
    year_month,
    revenue,
    LAG(revenue) OVER (ORDER BY month_date) AS prev_month_revenue,
    ROUND((revenue - LAG(revenue) OVER (ORDER BY month_date)) * 100.0 / 
          LAG(revenue) OVER (ORDER BY month_date), 2) AS mom_growth_pct
FROM monthly_rev;


-- Q13: Customer Lifecycle Span & Retention Window
SELECT
    customer_id,
    MIN(invoice_date) AS first_purchase_date,
    MAX(invoice_date) AS last_purchase_date,
    DATE_PART('day', MAX(invoice_date) - MIN(invoice_date)) AS tenure_days,
    COUNT(DISTINCT invoice_no) AS total_orders
FROM retail_transactions
WHERE customer_id IS NOT NULL 
  AND customer_id != 'Null'
GROUP BY customer_id
ORDER BY tenure_days DESC
LIMIT 15;


-- Q14: Single-Purchase Customers (One-Time Buyers vs. Churn Cohort)
SELECT 
    customer_id, 
    COUNT(DISTINCT invoice_no) AS order_count,
    ROUND(SUM(revenue), 2) AS lifetime_spend
FROM retail_transactions
WHERE NOT is_cancelled 
  AND customer_id IS NOT NULL 
  AND customer_id != 'Null'
GROUP BY customer_id
HAVING COUNT(DISTINCT invoice_no) = 1
ORDER BY lifetime_spend DESC;


-- Q15: SQL-Based RFM Segmentation & Customer Spend Profiles
WITH rfm_raw AS (
    SELECT
        customer_id,
        DATE_PART('day', '2011-12-09'::timestamp - MAX(invoice_date)) AS recency_days,
        COUNT(DISTINCT invoice_no) AS frequency,
        ROUND(SUM(revenue), 2) AS monetary
    FROM retail_transactions
    WHERE NOT is_cancelled 
      AND customer_id IS NOT NULL 
      AND customer_id != 'Null'
    GROUP BY customer_id
)
SELECT
    customer_id,
    recency_days,
    frequency,
    monetary,
    NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
    NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
    NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
FROM rfm_raw
ORDER BY monetary DESC
LIMIT 20;
