-- E-Commerce Business Performance Analytics
-- SQL Analysis Queries (SQLite/PostgreSQL compatible where possible)

-- 1. Total revenue & monthly revenue trend
-- Total revenue (delivered and shipped orders only)
WITH order_item_totals AS (
    SELECT
        oi.order_id,
        SUM(oi.quantity * oi.price) AS order_item_revenue
    FROM order_items oi
    GROUP BY oi.order_id
),
eligible_orders AS (
    SELECT
        o.order_id,
        o.order_date,
        o.order_status
    FROM orders o
    WHERE o.order_status IN ('delivered', 'shipped')
)
SELECT
    SUM(oit.order_item_revenue) AS total_revenue
FROM order_item_totals oit
JOIN eligible_orders eo ON eo.order_id = oit.order_id;

-- Monthly revenue trend
WITH order_item_totals AS (
    SELECT
        oi.order_id,
        SUM(oi.quantity * oi.price) AS order_item_revenue
    FROM order_items oi
    GROUP BY oi.order_id
),
eligible_orders AS (
    SELECT
        o.order_id,
        DATE(o.order_date) AS order_date,
        o.order_status
    FROM orders o
    WHERE o.order_status IN ('delivered', 'shipped')
)
SELECT
    strftime('%Y-%m', eo.order_date) AS year_month,      -- use TO_CHAR(eo.order_date, 'YYYY-MM') in PostgreSQL
    SUM(oit.order_item_revenue) AS monthly_revenue,
    COUNT(DISTINCT eo.order_id) AS monthly_orders
FROM order_item_totals oit
JOIN eligible_orders eo ON eo.order_id = oit.order_id
GROUP BY year_month
ORDER BY year_month;


-- 2. Top 10 selling products (by revenue)
WITH product_revenue AS (
    SELECT
        oi.product_id,
        p.product_name,
        p.product_category,
        SUM(oi.quantity) AS total_quantity_sold,
        SUM(oi.quantity * oi.price) AS total_revenue
    FROM order_items oi
    JOIN products p ON p.product_id = oi.product_id
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.order_status IN ('delivered', 'shipped')
    GROUP BY oi.product_id, p.product_name, p.product_category
)
SELECT
    product_id,
    product_name,
    product_category,
    total_quantity_sold,
    total_revenue
FROM product_revenue
ORDER BY total_revenue DESC
LIMIT 10;


-- 3. Revenue by product category
WITH order_item_revenue AS (
    SELECT
        oi.order_id,
        oi.product_id,
        SUM(oi.quantity * oi.price) AS line_revenue
    FROM order_items oi
    GROUP BY oi.order_id, oi.product_id
)
SELECT
    p.product_category,
    SUM(oir.line_revenue) AS category_revenue,
    SUM(oi.quantity) AS total_units_sold,
    COUNT(DISTINCT oi.order_id) AS orders_count
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
JOIN order_item_revenue oir ON oir.order_id = oi.order_id AND oir.product_id = oi.product_id
WHERE o.order_status IN ('delivered', 'shipped')
GROUP BY p.product_category
ORDER BY category_revenue DESC;


-- 4. Customer Lifetime Value (CLV)
-- CLV defined here as total revenue generated per customer
WITH order_revenue AS (
    SELECT
        oi.order_id,
        SUM(oi.quantity * oi.price) AS order_revenue
    FROM order_items oi
    GROUP BY oi.order_id
),
customer_revenue AS (
    SELECT
        o.customer_id,
        SUM(orv.order_revenue) AS lifetime_revenue,
        COUNT(DISTINCT o.order_id) AS orders_count,
        MIN(o.order_date) AS first_order_date,
        MAX(o.order_date) AS last_order_date
    FROM orders o
    JOIN order_revenue orv ON orv.order_id = o.order_id
    WHERE o.order_status IN ('delivered', 'shipped')
    GROUP BY o.customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    c.customer_country,
    cr.lifetime_revenue AS clv,
    cr.orders_count,
    cr.first_order_date,
    cr.last_order_date
FROM customer_revenue cr
JOIN customers c ON c.customer_id = cr.customer_id
ORDER BY clv DESC;


-- 5. Average Order Value (AOV)
WITH order_revenue AS (
    SELECT
        oi.order_id,
        SUM(oi.quantity * oi.price) AS order_revenue
    FROM order_items oi
    GROUP BY oi.order_id
),
eligible_orders AS (
    SELECT
        o.order_id
    FROM orders o
    WHERE o.order_status IN ('delivered', 'shipped')
)
SELECT
    AVG(orv.order_revenue) AS average_order_value
FROM order_revenue orv
JOIN eligible_orders eo ON eo.order_id = orv.order_id;


-- 6. Repeat vs one-time customers
WITH customer_order_counts AS (
    SELECT
        o.customer_id,
        COUNT(DISTINCT o.order_id) AS orders_count
    FROM orders o
    WHERE o.order_status IN ('delivered', 'shipped')
    GROUP BY o.customer_id
),
classified_customers AS (
    SELECT
        customer_id,
        orders_count,
        CASE
            WHEN orders_count = 1 THEN 'one_time'
            ELSE 'repeat'
        END AS customer_type
    FROM customer_order_counts
)
SELECT
    customer_type,
    COUNT(*) AS customers_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage_of_customers
FROM classified_customers
GROUP BY customer_type;


-- 7. Order cancellation rate
WITH order_counts AS (
    SELECT
        COUNT(*) AS total_orders,
        SUM(CASE WHEN o.order_status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_orders
    FROM orders o
)
SELECT
    total_orders,
    cancelled_orders,
    ROUND(100.0 * cancelled_orders / total_orders, 2) AS cancellation_rate_pct
FROM order_counts;


-- 8. Payment method usage (for dashboard)
SELECT
    p.payment_type,
    COUNT(*) AS payments_count,
    SUM(p.payment_amount) AS total_amount
FROM payments p
GROUP BY p.payment_type
ORDER BY total_amount DESC;


-- 9. Revenue by customer country (for map visual)
WITH order_revenue AS (
    SELECT
        oi.order_id,
        SUM(oi.quantity * oi.price) AS order_revenue
    FROM order_items oi
    GROUP BY oi.order_id
)
SELECT
    c.customer_country,
    SUM(orv.order_revenue) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS orders_count,
    COUNT(DISTINCT c.customer_id) AS customers_count
FROM orders o
JOIN order_revenue orv ON orv.order_id = o.order_id
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_status IN ('delivered', 'shipped')
GROUP BY c.customer_country
ORDER BY total_revenue DESC;


