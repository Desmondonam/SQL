-- ============================================================
--  SQL INTERVIEW PREP — 02: Filtering with WHERE  ✅ SOLUTIONS
--  Level     : Beginner → Intermediate
--  Dataset   : E-Commerce (Olist-inspired)
-- ============================================================
USE ecommerce_db;

-- Q1. All delivered orders.
SELECT * FROM orders WHERE order_status = 'delivered';

-- Q2. Products priced under 200.
SELECT * FROM products WHERE price < 200;

-- Q3. Credit card payments with a perfect review score.
SELECT * FROM orders
WHERE payment_type = 'credit_card' AND review_score = 5;

-- Q4. Electronics or Books products.
SELECT * FROM products
WHERE category = 'Electronics' OR category = 'Books';

-- Q5. All non-canceled orders.
SELECT * FROM orders WHERE order_status != 'canceled';
-- Also valid: WHERE order_status <> 'canceled'
-- Also valid: WHERE NOT order_status = 'canceled'

-- Q6. Orders with total_amount between 200 and 600.
SELECT * FROM orders
WHERE total_amount BETWEEN 200 AND 600;
-- Note: BETWEEN is inclusive on both ends.

-- Q7. Customers whose city starts with 'S'.
SELECT * FROM customers
WHERE city LIKE 'S%';
-- % matches zero or more characters. '_' matches exactly one.

-- Q8. Orders with no delivery date (not yet delivered).
SELECT * FROM orders
WHERE delivered_date IS NULL;
-- Never use: WHERE delivered_date = NULL  (always false in SQL!)

-- Q9. Products in Electronics, Sports, or Home & Garden.
SELECT * FROM products
WHERE category IN ('Electronics', 'Sports', 'Home & Garden');
-- IN is shorthand for multiple OR conditions.

-- Q10. Products whose name contains 'Pro' or 'Ultra'.
SELECT * FROM products
WHERE product_name LIKE '%Pro%'
   OR product_name LIKE '%Ultra%';

-- Q11. Orders placed in Q1 2023 (Jan–Mar).
SELECT * FROM orders
WHERE purchase_date BETWEEN '2023-01-01' AND '2023-03-31';
-- Alternative using MONTH():
-- WHERE YEAR(purchase_date) = 2023 AND MONTH(purchase_date) IN (1,2,3)

-- Q12. Orders with low review score OR canceled status.
SELECT order_id, customer_id, order_status, review_score
FROM orders
WHERE review_score < 3 OR order_status = 'canceled';

-- Q13. Low-stock AND expensive products.
SELECT * FROM products
WHERE stock_qty < 20 AND price > 400;

-- Q14. Delivered orders for specific customers.
SELECT * FROM orders
WHERE customer_id IN ('C001','C003','C005','C007')
  AND order_status = 'delivered';

-- Q15. Orders with quantity >=2, total > 300, not using voucher.
SELECT * FROM orders
WHERE quantity >= 2
  AND total_amount > 300
  AND payment_type != 'voucher';

-- ── KEY TAKEAWAYS ──────────────────────────────────────────
-- • AND requires BOTH conditions; OR requires at least one.
-- • BETWEEN low AND high is inclusive on both ends.
-- • LIKE '%text%' searches anywhere; 'text%' searches prefix.
-- • IS NULL / IS NOT NULL — never use = NULL.
-- • IN (v1, v2, v3) is cleaner than chained OR conditions.
-- • Combine multiple conditions carefully — AND binds tighter than OR;
--   use parentheses when mixing them to avoid logic bugs.
-- ───────────────────────────────────────────────────────────
