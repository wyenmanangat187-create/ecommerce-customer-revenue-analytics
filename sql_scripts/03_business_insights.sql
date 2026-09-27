-- E-Commerce Customer & Revenue Analytics

-- DOMAIN 1: REVENUE & SALES TRENDS

-- 1.1: Total Revenue 

SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
    SUM(p.amount) AS total_revenue
FROM orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY 1

-- 1.2: Top 10 Best-Selling Products by Revenue 

SELECT 
    p.product_id,
    p.product_name,
    SUM(oi.quantity * p.price) AS total_sales
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_sales DESC
LIMIT 10;

-- 1.3: Top Selling Products by Volume

SELECT 
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_units_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_units_sold DESC
LIMIT 10;

-- DOMAIN 2: CUSTOMER BEHAVIOR & RETENTION

-- 2.1: High-Value Customer (VIP) Segmentation

SELECT 
    o.customer_id,
    COUNT(o.order_id) AS total_orders,
    SUM(p.amount) AS total_spent,
    CASE 
        WHEN SUM(p.amount) >= 2000 THEN 'VIP / High Value'
        WHEN SUM(p.amount) BETWEEN 500 AND 1999 THEN 'Mid-Tier Spender'
        ELSE 'Low-Tier Spender'
    END AS customer_segment
FROM orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY o.customer_id
ORDER BY total_spent DESC;

-- 2.2 Average Basket Size and Item Revenue per Category

SELECT 
    p.category,
    COUNT(DISTINCT oi.order_id) AS unique_orders,
    SUM(oi.quantity) AS total_units_sold,
    ROUND(AVG(oi.quantity), 1) AS avg_units_per_order,
    ROUND(SUM(oi.quantity * p.price) / COUNT(DISTINCT oi.order_id), 2) AS category_aov
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY category_aov DESC;

-- 2.3 Basket Complexity (Single-Item vs. Multi-Item Buyers)

WITH OrderItemCounts AS (
    SELECT 
        order_id,
        SUM(quantity) AS total_items_in_order
    FROM order_items
    GROUP BY order_id
)
SELECT 
    CASE 
        WHEN total_items_in_order = 1 THEN 'Single-Item Order'
        ELSE 'Multi-Item Order (Bundled)'
    END AS order_type,
    COUNT(order_id) AS order_count,
    ROUND(COUNT(order_id) * 100.0 / (SELECT COUNT(*) FROM OrderItemCounts), 1) AS percentage_of_total
FROM OrderItemCounts
GROUP BY 1;

-- 2.4 Payment Method Usage by Price Tier

WITH CategorizedPayments AS (
    SELECT 
        p.payment_mode,
        p.amount,
        CASE 
            WHEN p.amount < 500 THEN 'Low-Tier (< $500)'
            WHEN p.amount BETWEEN 500 AND 2000 THEN 'Mid-Tier ($500 - $2000)'
            ELSE 'High-Tier (> $2000)'
        END AS price_bracket
    FROM payments p
)
SELECT 
    price_bracket,
    payment_mode,
    COUNT(*) AS total_transactions,
    ROUND(SUM(amount), 2) AS total_spent
FROM CategorizedPayments
GROUP BY price_bracket, payment_mode
ORDER BY 
    CASE price_bracket
        WHEN 'Low-Tier (< $500)' THEN 1
        WHEN 'Mid-Tier ($500 - $2000)' THEN 2
        ELSE 3
    END, 
    total_transactions DESC;
    
