-- ==============================================================================
-- 01_basic_analysis.sql
-- E-Commerce Sales & Customer Analytics: Basic SQL Queries (Q1 - Q5)
-- Schema: retail_transactions (PostgreSQL)
-- ==============================================================================

-- Q1: Total Revenue (Net of Cancellations & Adjustments)
SELECT 
    ROUND(SUM(revenue), 2) AS total_net_revenue
FROM retail_transactions;


-- Q2: Unique Identified Customers
SELECT 
    COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_transactions
WHERE customer_id IS NOT NULL 
  AND customer_id != '' 
  AND customer_id != 'Null';


-- Q3: Top 10 Products by Quantity Sold (Excluding Cancellations)
SELECT 
    description,
    SUM(quantity) AS total_units_sold
FROM retail_transactions
WHERE NOT is_cancelled 
  AND quantity > 0
GROUP BY description
ORDER BY total_units_sold DESC
LIMIT 10;


-- Q4: Gross and Net Revenue by Country
SELECT 
    country,
    ROUND(SUM(revenue), 2) AS total_revenue,
    COUNT(DISTINCT invoice_no) AS total_orders
FROM retail_transactions
GROUP BY country
ORDER BY total_revenue DESC;


-- Q5: Count of Cancelled vs. Valid Transactions
SELECT
    SUM(CASE WHEN is_cancelled THEN 1 ELSE 0 END) AS cancelled_transactions,
    SUM(CASE WHEN NOT is_cancelled THEN 1 ELSE 0 END) AS valid_transactions,
    ROUND(SUM(CASE WHEN is_cancelled THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS cancellation_rate_pct
FROM retail_transactions;
