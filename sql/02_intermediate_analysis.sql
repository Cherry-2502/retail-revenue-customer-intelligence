-- ==============================================================================
-- 02_intermediate_analysis.sql
-- E-Commerce Sales & Customer Analytics: Intermediate SQL Queries (Q6 - Q10)
-- Schema: retail_transactions (PostgreSQL)
-- ==============================================================================

-- Q6: Monthly Net Revenue Trend & Transaction Volume
SELECT
    TO_CHAR(DATE_TRUNC('month', invoice_date), 'YYYY-MM') AS year_month,
    ROUND(SUM(revenue), 2) AS monthly_revenue,
    COUNT(DISTINCT invoice_no) AS monthly_orders
FROM retail_transactions
GROUP BY DATE_TRUNC('month', invoice_date)
ORDER BY DATE_TRUNC('month', invoice_date);


-- Q7: Average Order Value (AOV) Across Completed Valid Orders
SELECT
    ROUND(AVG(order_total), 2) AS average_order_value,
    ROUND(MIN(order_total), 2) AS min_order_value,
    ROUND(MAX(order_total), 2) AS max_order_value
FROM (
    SELECT 
        invoice_no, 
        SUM(revenue) AS order_total
    FROM retail_transactions
    WHERE NOT is_cancelled
    GROUP BY invoice_no
) AS valid_orders;


-- Q8: High-Value Customers (Above Mean Customer Spend)
WITH customer_spending AS (
    SELECT 
        customer_id, 
        ROUND(SUM(revenue), 2) AS total_spent,
        COUNT(DISTINCT invoice_no) AS order_count
    FROM retail_transactions
    WHERE NOT is_cancelled 
      AND customer_id IS NOT NULL
      AND customer_id != 'Null'
    GROUP BY customer_id
)
SELECT 
    customer_id,
    total_spent,
    order_count
FROM customer_spending
WHERE total_spent > (SELECT AVG(total_spent) FROM customer_spending)
ORDER BY total_spent DESC;


-- Q9: Top 10 Customers by Lifetime Revenue
SELECT 
    customer_id, 
    ROUND(SUM(revenue), 2) AS total_revenue,
    COUNT(DISTINCT invoice_no) AS total_orders
FROM retail_transactions
WHERE NOT is_cancelled 
  AND customer_id IS NOT NULL 
  AND customer_id != 'Null'
GROUP BY customer_id
ORDER BY total_revenue DESC
LIMIT 10;


-- Q10: Revenue Contribution by Country (% Share of Store Total)
SELECT
    country,
    ROUND(SUM(revenue), 2) AS country_revenue,
    ROUND(SUM(revenue) * 100.0 / (SELECT SUM(revenue) FROM retail_transactions), 2) AS pct_of_total
FROM retail_transactions
GROUP BY country
ORDER BY country_revenue DESC
LIMIT 10;
