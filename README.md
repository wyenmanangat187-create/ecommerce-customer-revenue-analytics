# E-Commerce Customer & Revenue Analytics (MySQL)

## Executive Summary
This project evaluates transactional e-commerce data using **MySQL** to analyze revenue performance, product demand distributions, customer value segments, and payment preferences. The analytical findings provide actionable guidance for sales optimization, inventory management, and fulfillment quality control.

**DOMAIN 1: REVENUE & SALES TRENDS**

**1.1: Total Revenue**

**SQL Query**

SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
    SUM(p.amount) AS total_revenue
FROM orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY 1

<img width="267" height="100" alt="Screenshot 2026-09-24 023611" src="https://github.com/user-attachments/assets/e75d8d32-ac92-401f-b0ab-b6ea2ae9eed2" />


- Monthly revenue peaked at $148,575 in February 2025.
- **Business Insight**: Shows good sign of the beginning of seasonal strength or promotional campaign success during this month.
  

**1.2: Top 10 Best-Selling Products by Revenue**

**SQL Query**

SELECT 
    p.product_id,
    p.product_name,
    SUM(oi.quantity * p.price) AS total_sales
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_sales DESC


LIMIT 10;

<img width="361" height="277" alt="Screenshot 2026-09-24 023644" src="https://github.com/user-attachments/assets/053f1215-4bae-44a8-91b5-681cc8f3ebda" />


- **Financial Value**: The "Python Hoodie" ($23,988) and "AI Nerd T-Shirt" ($19,188) lead the pack in terms of financial value.
- Developer-themed apparel products are ones that can generate solid margins and are effective key revenue generators with the high ticket apparel items.


**1.3: Top Selling Products by Volume**

**SQL Query**

SELECT 
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_units_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_units_sold DESC
LIMIT 10;

<img width="377" height="271" alt="Screenshot 2026-09-24 023730" src="https://github.com/user-attachments/assets/92d33db2-e4a8-47c5-912f-522572a38f5f" />


- Lower-cost merchandise leads unit sales, with the "DSA Notebook", "SQL Cheat Sheet", and "Terminal Stickers" each moving 18 units.
- Low-cost stationery and accessories act as primary add-on items, driving conversion rates and overall transaction frequency.


**DOMAIN 2: CUSTOMER BEHAVIOR & RETENTION**

**2.1: High-Value Customer (VIP) Segmentation**

**SQL Query**

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

<img width="462" height="287" alt="Screenshot 2026-09-24 023821" src="https://github.com/user-attachments/assets/bb6c9099-14d8-4f7e-b6af-901a3760d7b5" />


- Highly engaged accounts: Customer 8 ($22,386) and Customer 1 ($17,479) have completed 7 orders each and also the top spenders in the month of february.
- A concentrated group of VIP buyers drives platform profitability, highlighting strong brand loyalty among core power users.


**2.2 Average Basket Size and Item Revenue per Category**

**SQL Query**

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

<img width="625" height="142" alt="Screenshot 2026-09-24 023854" src="https://github.com/user-attachments/assets/11313389-5b97-4cc6-a7a1-60f1d7e5ca2f" />


- The highest Average Order Value ($12,764.57 AOV with 1.1 units per order) is seen in the category "Clothing" and the highest volume per cart (1.8 units per order, $3,852.00 AOV) is seen in "Stationery".
- Clothing accounts for basket value, with the higher prices, while stationery accounts for items per transaction.


**2.3 Basket Complexity (Single-Item vs. Multi-Item Buyers)**

**SQL Query**

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

<img width="506" height="75" alt="Screenshot 2026-09-24 023934" src="https://github.com/user-attachments/assets/47ae2fea-df42-48da-9709-66d7926a7749" />


- All recorded orders (20/20) are multi item bundled purchases.
- Customers are buying more than one product at a time, meaning basket density is high and organic cross-category interest.


**2.4 Payment Method Usage by Price Tier**

**SQL Query**

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

<img width="583" height="182" alt="Screenshot 2026-09-24 024004" src="https://github.com/user-attachments/assets/35dbbd22-4601-4548-ba30-eb376bfff480" />


- Instant digital payments via UPI lead transaction frequency across mid-tier purchases (42 transactions, $48,587 total spent). Credit Card usage dominates high-tier purchases by total dollar volume ($37,779 across 14 transactions).
- Customers rely on frictionless payment methods like UPI for standard orders, while leaning on Credit Cards for larger purchases.

    














