-- Q1 : Total Revenue
SELECT SUM(revenue) AS total_revenue
FROM retail_transactions;


--Q2 : Unique Customers
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_transactions
WHERE customer_id IS NOT NULL AND customer_id != '';


--Q3: Top 10 Products by Quantity Sold
SELECT description, SUM(quantity) AS total_qty
FROM retail_transactions
WHERE quantity > 0 -- Exclude cancellations
GROUP BY description
ORDER BY total_qty DESC
LIMIT 10;


--Q4: Revenue by Country
SELECT country, SUM(revenue) AS total_revenue
FROM retail_transactions
GROUP BY country
ORDER BY total_revenue DESC;


--Q5: Count of Cancelled vs Valid Orders
SELECT
    SUM(CASE WHEN is_cancelled THEN 1 ELSE 0 END) AS cancelled_count,
    SUM(CASE WHEN NOT is_cancelled THEN 1 ELSE 0 END) AS valid_count
FROM retail_transactions;


--Q6: Monthly Revenue Trend
SELECT
    DATE_TRUNC('month', invoice_date) AS month,
    SUM(revenue) AS monthly_revenue
FROM retail_transactions
GROUP BY month
ORDER BY month;


--Q7: Average Order Value (AOV) Hint: An "order" is a unique InvoiceNo
SELECT
    AVG(order_total) AS average_order_value
FROM (
    SELECT invoice_no, SUM(revenue) AS order_total
    FROM retail_transactions
    WHERE NOT is_cancelled
    GROUP BY invoice_no
) AS orders;


--Q8: Customers who spent more than the average customer
WITH customer_spending AS (
    SELECT customer_id, SUM(revenue) AS total_spent
    FROM retail_transactions
    WHERE NOT is_cancelled AND customer_id IS NOT NULL
    GROUP BY customer_id
)
SELECT *
FROM customer_spending
WHERE total_spent > (SELECT AVG(total_spent) FROM customer_spending);


--Q9: Top 10 Customers by Revenue
SELECT customer_id, SUM(revenue) AS total_revenue
FROM retail_transactions
WHERE NOT is_cancelled AND customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY total_revenue DESC
LIMIT 10;


--Q10: Revenue Contribution by Country (% of Total)
SELECT
    country,
    SUM(revenue) AS country_revenue,
    (SUM(revenue) * 100.0 / (SELECT SUM(revenue) FROM retail_transactions)) AS pct_of_total
FROM retail_transactions
GROUP BY country
ORDER BY pct_of_total DESC;


--Q11: Rank Products by Revenue within Each Country This uses RANK().
WITH product_country_rev AS (
    SELECT
        country,
        description,
        SUM(revenue) AS revenue
    FROM retail_transactions
    WHERE NOT is_cancelled
    GROUP BY country, description
)
SELECT
    country,
    description,
    revenue,
    RANK() OVER (PARTITION BY country ORDER BY revenue DESC) AS rank_in_country
FROM product_country_rev
ORDER BY country, rank_in_country;


--Q12: Month-over-Month Growth This uses LAG() to compare to the previous month.
WITH monthly_rev AS (
    SELECT
        DATE_TRUNC('month', invoice_date) AS month,
        SUM(revenue) AS revenue
    FROM retail_transactions
    GROUP BY month
    ORDER BY month
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
    (revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue) OVER (ORDER BY month) * 100 AS growth_pct
FROM monthly_rev;


--Q13: Customer First and Last Purchase Date
SELECT
    customer_id,
    MIN(invoice_date) AS first_purchase,
    MAX(invoice_date) AS last_purchase
FROM retail_transactions
WHERE customer_id IS NOT NULL
GROUP BY customer_id
LIMIT 10;


--Q14: Find Customers with Only One Purchase
SELECT customer_id, COUNT(*) AS order_count
FROM retail_transactions
WHERE NOT is_cancelled AND customer_id IS NOT NULL
GROUP BY customer_id
HAVING COUNT(*) = 1;


--Q15: Revenue per Customer Segment (using SQL logic) You can recreate a simple version of RFM in SQL.
SELECT
    customer_id,
    COUNT(DISTINCT invoice_no) AS frequency,
    MAX(invoice_date) - MIN(invoice_date) AS tenure_days,
    SUM(revenue) AS monetary
FROM retail_transactions
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY monetary DESC
LIMIT 10;