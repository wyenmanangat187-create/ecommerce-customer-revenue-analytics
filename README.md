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

