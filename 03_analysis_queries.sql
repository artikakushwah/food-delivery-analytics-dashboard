-- ============================================================
-- FOOD DELIVERY ANALYTICS PROJECT - ANALYSIS QUERIES
-- ============================================================
-- A mix of joins, CTEs, window functions, and subqueries.
-- Organized by business question - use these directly in your
-- portfolio / interview to explain your SQL thinking.

-- ------------------------------------------------------------
-- Q1. City-wise total orders, revenue, and cancellation rate
-- ------------------------------------------------------------
SELECT
    r.city,
    COUNT(o.order_id)                                        AS total_orders,
    SUM(CASE WHEN o.status = 'Delivered' THEN o.order_value ELSE 0 END) AS total_revenue,
    ROUND(100.0 * SUM(CASE WHEN o.status = 'Cancelled' THEN 1 ELSE 0 END)
          / COUNT(o.order_id), 2)                             AS cancellation_rate_pct
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY r.city
ORDER BY cancellation_rate_pct DESC;

-- ------------------------------------------------------------
-- Q2. Top 3 restaurants by revenue, PER CITY (window function)
-- ------------------------------------------------------------
WITH restaurant_revenue AS (
    SELECT
        r.city,
        r.restaurant_name,
        SUM(o.order_value) AS revenue,
        RANK() OVER (PARTITION BY r.city ORDER BY SUM(o.order_value) DESC) AS city_rank
    FROM orders o
    JOIN restaurants r ON o.restaurant_id = r.restaurant_id
    WHERE o.status = 'Delivered'
    GROUP BY r.city, r.restaurant_name
)
SELECT * FROM restaurant_revenue
WHERE city_rank <= 3
ORDER BY city, city_rank;

-- ------------------------------------------------------------
-- Q3. Month-over-month order growth (window function: LAG)
-- ------------------------------------------------------------
WITH monthly_orders AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS order_month,   -- MySQL
        -- TO_CHAR(order_date, 'YYYY-MM') AS order_month,  -- PostgreSQL alt
        COUNT(*) AS total_orders
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
    order_month,
    total_orders,
    LAG(total_orders) OVER (ORDER BY order_month)               AS prev_month_orders,
    ROUND(100.0 * (total_orders - LAG(total_orders) OVER (ORDER BY order_month))
          / LAG(total_orders) OVER (ORDER BY order_month), 2)   AS mom_growth_pct
FROM monthly_orders
ORDER BY order_month;

-- ------------------------------------------------------------
-- Q4. Customers at churn risk: 3+ cancelled orders (CTE + HAVING)
-- ------------------------------------------------------------
WITH cancelled_counts AS (
    SELECT customer_id, COUNT(*) AS cancelled_orders
    FROM orders
    WHERE status = 'Cancelled'
    GROUP BY customer_id
    HAVING COUNT(*) >= 3
)
SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    cc.cancelled_orders
FROM cancelled_counts cc
JOIN customers c ON cc.customer_id = c.customer_id
ORDER BY cc.cancelled_orders DESC;

-- ------------------------------------------------------------
-- Q5. Restaurants performing below their city's average rating (subquery)
-- ------------------------------------------------------------
SELECT
    restaurant_name,
    city,
    rating
FROM restaurants r1
WHERE rating < (
    SELECT AVG(rating)
    FROM restaurants r2
    WHERE r2.city = r1.city
)
ORDER BY city, rating;

-- ------------------------------------------------------------
-- Q6. Delivery partner performance: avg delivery time & rating
--     (join across orders + delivery_partners, with order volume)
-- ------------------------------------------------------------
SELECT
    dp.delivery_partner_id,
    dp.partner_name,
    dp.vehicle_type,
    COUNT(o.order_id)                          AS total_deliveries,
    ROUND(AVG(o.delivery_time_min), 1)          AS avg_delivery_time,
    ROUND(AVG(dp.partner_rating), 1)            AS partner_rating
FROM delivery_partners dp
JOIN orders o ON dp.delivery_partner_id = o.delivery_partner_id
WHERE o.status = 'Delivered'
GROUP BY dp.delivery_partner_id, dp.partner_name, dp.vehicle_type
ORDER BY avg_delivery_time DESC
LIMIT 10;

-- ------------------------------------------------------------
-- Q7. Customer Lifetime Value (CLV) segments (CTE + CASE)
-- ------------------------------------------------------------
WITH customer_value AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.city,
        COUNT(o.order_id)                AS total_orders,
        SUM(o.order_value)                AS total_spend
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.status = 'Delivered'
    GROUP BY c.customer_id, c.customer_name, c.city
)
SELECT
    *,
    CASE
        WHEN total_spend >= 5000 THEN 'High Value'
        WHEN total_spend >= 2000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM customer_value
ORDER BY total_spend DESC;

-- ------------------------------------------------------------
-- Q8. Payment failure rate by payment mode (join orders + payments)
-- ------------------------------------------------------------
SELECT
    p.payment_mode,
    COUNT(*)                                                       AS total_transactions,
    SUM(CASE WHEN p.transaction_status = 'Failed' THEN 1 ELSE 0 END) AS failed_transactions,
    ROUND(100.0 * SUM(CASE WHEN p.transaction_status = 'Failed' THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                             AS failure_rate_pct
FROM payments p
GROUP BY p.payment_mode
ORDER BY failure_rate_pct DESC;

-- ------------------------------------------------------------
-- Q9. Running total of revenue by month (window function)
-- ------------------------------------------------------------
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS order_month,
        SUM(order_value) AS revenue
    FROM orders
    WHERE status = 'Delivered'
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
    order_month,
    revenue,
    SUM(revenue) OVER (ORDER BY order_month) AS running_total_revenue
FROM monthly_revenue
ORDER BY order_month;

-- ------------------------------------------------------------
-- Q10. New vs Repeat customers per month (CTE)
-- ------------------------------------------------------------
WITH first_orders AS (
    SELECT customer_id, MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY customer_id
)
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
    SUM(CASE WHEN o.order_date = fo.first_order_date THEN 1 ELSE 0 END) AS new_customers,
    SUM(CASE WHEN o.order_date != fo.first_order_date THEN 1 ELSE 0 END) AS repeat_orders
FROM orders o
JOIN first_orders fo ON o.customer_id = fo.customer_id
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY order_month;
