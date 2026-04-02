-- ============================================================
-- Retail Analytics — 12 SQL Queries
-- Topics: Revenue KPIs, Customer Analysis, Product Velocity,
--         Window Functions (RANK, LAG), CTEs, Subqueries
-- ============================================================

USE retail_analytics;

-- ──────────────────────────────────────────────────────────────
-- Q1: Monthly Revenue (2023–2024)
--     Shows revenue trend month over month.
-- ──────────────────────────────────────────────────────────────
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m')          AS month,
    COUNT(DISTINCT o.order_id)                  AS total_orders,
    SUM(oi.quantity * oi.unit_price
        * (1 - oi.discount_pct / 100))          AS gross_revenue,
    ROUND(AVG(oi.quantity * oi.unit_price
        * (1 - oi.discount_pct / 100)), 2)      AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Completed'
GROUP BY month
ORDER BY month;


-- ──────────────────────────────────────────────────────────────
-- Q2: Month-over-Month Revenue Growth (LAG window function)
-- ──────────────────────────────────────────────────────────────
WITH monthly AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m')      AS month,
        SUM(oi.quantity * oi.unit_price
            * (1 - oi.discount_pct / 100))      AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Completed'
    GROUP BY month
)
SELECT
    month,
    ROUND(revenue, 2)                           AS revenue,
    ROUND(LAG(revenue) OVER (ORDER BY month), 2) AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month))
        / LAG(revenue) OVER (ORDER BY month) * 100, 2
    )                                           AS growth_pct
FROM monthly
ORDER BY month;


-- ──────────────────────────────────────────────────────────────
-- Q3: Top 10 Customers by Total Spend
-- ──────────────────────────────────────────────────────────────
SELECT
    c.customer_id,
    c.full_name,
    c.city,
    r.region_name,
    COUNT(DISTINCT o.order_id)                  AS total_orders,
    ROUND(SUM(oi.quantity * oi.unit_price
        * (1 - oi.discount_pct / 100)), 2)      AS total_spend
FROM customers c
JOIN orders o       ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id    = oi.order_id
JOIN regions r      ON c.region_id   = r.region_id
WHERE o.status = 'Completed'
GROUP BY c.customer_id, c.full_name, c.city, r.region_name
ORDER BY total_spend DESC
LIMIT 10;


-- ──────────────────────────────────────────────────────────────
-- Q4: Product Velocity — Top 10 Products by Units Sold
-- ──────────────────────────────────────────────────────────────
SELECT
    p.product_id,
    p.product_name,
    cat.category_name,
    SUM(oi.quantity)                            AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price
        * (1 - oi.discount_pct / 100)), 2)      AS revenue
FROM products p
JOIN categories cat  ON p.category_id  = cat.category_id
JOIN order_items oi  ON p.product_id   = oi.product_id
JOIN orders o        ON oi.order_id    = o.order_id
WHERE o.status = 'Completed'
GROUP BY p.product_id, p.product_name, cat.category_name
ORDER BY units_sold DESC
LIMIT 10;


-- ──────────────────────────────────────────────────────────────
-- Q5: Revenue by Region
-- ──────────────────────────────────────────────────────────────
SELECT
    r.region_name,
    COUNT(DISTINCT c.customer_id)               AS customers,
    COUNT(DISTINCT o.order_id)                  AS orders,
    ROUND(SUM(oi.quantity * oi.unit_price
        * (1 - oi.discount_pct / 100)), 2)      AS revenue
FROM regions r
JOIN customers c    ON r.region_id   = c.region_id
JOIN orders o       ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id    = oi.order_id
WHERE o.status = 'Completed'
GROUP BY r.region_name
ORDER BY revenue DESC;


-- ──────────────────────────────────────────────────────────────
-- Q6: Revenue by Category
-- ──────────────────────────────────────────────────────────────
SELECT
    cat.category_name,
    COUNT(DISTINCT p.product_id)                AS products_count,
    SUM(oi.quantity)                            AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price
        * (1 - oi.discount_pct / 100)), 2)      AS revenue,
    ROUND(SUM(oi.quantity * (oi.unit_price - p.cost_price)
        * (1 - oi.discount_pct / 100)), 2)      AS gross_profit
FROM categories cat
JOIN products p      ON cat.category_id = p.category_id
JOIN order_items oi  ON p.product_id    = oi.product_id
JOIN orders o        ON oi.order_id     = o.order_id
WHERE o.status = 'Completed'
GROUP BY cat.category_name
ORDER BY revenue DESC;


-- ──────────────────────────────────────────────────────────────
-- Q7: Product Rank Within Category (RANK window function)
-- ──────────────────────────────────────────────────────────────
WITH product_rev AS (
    SELECT
        p.product_id,
        p.product_name,
        cat.category_name,
        ROUND(SUM(oi.quantity * oi.unit_price
            * (1 - oi.discount_pct / 100)), 2)  AS revenue
    FROM products p
    JOIN categories cat  ON p.category_id  = cat.category_id
    JOIN order_items oi  ON p.product_id   = oi.product_id
    JOIN orders o        ON oi.order_id    = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY p.product_id, p.product_name, cat.category_name
)
SELECT
    category_name,
    product_name,
    revenue,
    RANK() OVER (PARTITION BY category_name ORDER BY revenue DESC) AS rank_in_category
FROM product_rev
ORDER BY category_name, rank_in_category;


-- ──────────────────────────────────────────────────────────────
-- Q8: Customer Segmentation by Spend (subquery)
-- ──────────────────────────────────────────────────────────────
SELECT
    segment,
    COUNT(*)                                    AS customer_count,
    ROUND(AVG(total_spend), 2)                  AS avg_spend
FROM (
    SELECT
        c.customer_id,
        SUM(oi.quantity * oi.unit_price
            * (1 - oi.discount_pct / 100))      AS total_spend,
        CASE
            WHEN SUM(oi.quantity * oi.unit_price
                * (1 - oi.discount_pct / 100)) >= 20000 THEN 'High Value'
            WHEN SUM(oi.quantity * oi.unit_price
                * (1 - oi.discount_pct / 100)) >= 8000  THEN 'Mid Value'
            ELSE 'Low Value'
        END                                     AS segment
    FROM customers c
    JOIN orders o       ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id    = oi.order_id
    WHERE o.status = 'Completed'
    GROUP BY c.customer_id
) seg
GROUP BY segment
ORDER BY avg_spend DESC;


-- ──────────────────────────────────────────────────────────────
-- Q9: Order Status Distribution
-- ──────────────────────────────────────────────────────────────
SELECT
    status,
    COUNT(*)                                    AS order_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM orders
GROUP BY status
ORDER BY order_count DESC;


-- ──────────────────────────────────────────────────────────────
-- Q10: Return Rate by Product
-- ──────────────────────────────────────────────────────────────
SELECT
    p.product_name,
    cat.category_name,
    COUNT(DISTINCT oi.order_id)                 AS times_ordered,
    COUNT(DISTINCT ret.return_id)               AS times_returned,
    ROUND(COUNT(DISTINCT ret.return_id) * 100.0
        / NULLIF(COUNT(DISTINCT oi.order_id), 0), 2) AS return_rate_pct
FROM products p
JOIN categories cat  ON p.category_id   = cat.category_id
JOIN order_items oi  ON p.product_id    = oi.product_id
LEFT JOIN returns ret ON oi.order_id    = ret.order_id
                      AND oi.product_id = ret.product_id
GROUP BY p.product_id, p.product_name, cat.category_name
ORDER BY return_rate_pct DESC;


-- ──────────────────────────────────────────────────────────────
-- Q11: Payment Mode Preference
-- ──────────────────────────────────────────────────────────────
SELECT
    payment_mode,
    COUNT(*)                                    AS order_count,
    ROUND(SUM(oi.quantity * oi.unit_price
        * (1 - oi.discount_pct / 100)), 2)      AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Completed'
GROUP BY payment_mode
ORDER BY order_count DESC;


-- ──────────────────────────────────────────────────────────────
-- Q12: Running Total Revenue (cumulative — SUM OVER)
-- ──────────────────────────────────────────────────────────────
WITH monthly AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m')      AS month,
        ROUND(SUM(oi.quantity * oi.unit_price
            * (1 - oi.discount_pct / 100)), 2)  AS monthly_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Completed'
    GROUP BY month
)
SELECT
    month,
    monthly_revenue,
    ROUND(SUM(monthly_revenue)
        OVER (ORDER BY month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2
    )                                           AS running_total
FROM monthly
ORDER BY month;
