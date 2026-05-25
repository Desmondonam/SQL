-- ============================================================
--  SQL INTERVIEW PREP — 06: JOINs  ✅ SOLUTIONS
-- ============================================================
USE northwind_db;

-- Q1. Orders with customer info (INNER JOIN).
SELECT o.order_id, c.company_name, c.contact_name, o.order_date
FROM orders_nw o
INNER JOIN customers_nw c ON o.customer_id = c.customer_id;

-- Q2. Order items with product name (INNER JOIN).
SELECT oi.order_id, p.product_name, oi.quantity, oi.unit_price
FROM order_items oi
INNER JOIN products_nw p ON oi.product_id = p.product_id;

-- Q3. ALL customers + their orders (LEFT JOIN).
SELECT c.customer_id, c.company_name, o.order_id, o.order_date
FROM customers_nw c
LEFT JOIN orders_nw o ON c.customer_id = o.customer_id;
-- Customers with no orders get NULL in the order columns.

-- Q4. All products + whether they were ordered (LEFT JOIN + CASE).
SELECT
    p.product_name,
    CASE WHEN oi.product_id IS NOT NULL THEN 'YES' ELSE 'NO' END AS ordered
FROM products_nw p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name;

-- Q5. Orders + customer + employee (three-table JOIN).
SELECT
    o.order_id,
    c.company_name,
    CONCAT(e.first_name,' ',e.last_name) AS employee_name,
    o.order_date
FROM orders_nw o
INNER JOIN customers_nw c  ON o.customer_id = c.customer_id
INNER JOIN employees_nw e  ON o.emp_id       = e.emp_id;

-- Q6. Employees with their manager (SELF JOIN).
SELECT
    CONCAT(e.first_name,' ',e.last_name)  AS employee,
    e.title,
    CONCAT(m.first_name,' ',m.last_name)  AS manager
FROM employees_nw e
LEFT JOIN employees_nw m ON e.reports_to = m.emp_id;

-- Q7. Full order detail (four-table JOIN with line total).
SELECT
    o.order_id,
    c.company_name,
    p.product_name,
    cat.cat_name                                        AS category,
    oi.quantity,
    ROUND(oi.quantity * oi.unit_price * (1-oi.discount),2) AS line_total
FROM orders_nw o
INNER JOIN customers_nw c  ON o.customer_id  = c.customer_id
INNER JOIN order_items  oi ON o.order_id     = oi.order_id
INNER JOIN products_nw  p  ON oi.product_id  = p.product_id
INNER JOIN categories   cat ON p.cat_id      = cat.cat_id;

-- Q8. Products with supplier country and category (exclude no supplier).
SELECT
    p.product_name,
    p.discontinued,
    s.company_name  AS supplier,
    s.country       AS supplier_country,
    cat.cat_name    AS category
FROM products_nw p
INNER JOIN suppliers  s   ON p.supplier_id = s.supplier_id
INNER JOIN categories cat ON p.cat_id      = cat.cat_id;

-- Q9. Customers who have NEVER placed an order (LEFT JOIN + IS NULL).
SELECT c.customer_id, c.company_name
FROM customers_nw c
LEFT JOIN orders_nw o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
-- This pattern (LEFT JOIN + WHERE right.PK IS NULL) = "anti-join"

-- Q10. Total value per order (JOIN + GROUP BY).
SELECT
    o.order_id,
    o.order_date,
    ROUND(SUM(oi.quantity * oi.unit_price * (1-oi.discount)),2) AS total_value
FROM orders_nw o
INNER JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.order_date
ORDER BY total_value DESC;

-- Q11. CROSS JOIN — category × supplier matrix.
SELECT c.cat_name, s.company_name
FROM categories c
CROSS JOIN suppliers s
ORDER BY c.cat_name, s.company_name;
-- CROSS JOIN = Cartesian product; 5 cats × 5 suppliers = 25 rows.

-- Q12. Orders with freight above average freight (subquery in WHERE).
SELECT
    o.order_id,
    c.company_name,
    o.freight
FROM orders_nw o
INNER JOIN customers_nw c ON o.customer_id = c.customer_id
WHERE o.freight > (SELECT AVG(freight) FROM orders_nw)
ORDER BY o.freight DESC;

-- ── KEY TAKEAWAYS ──────────────────────────────────────────
-- • INNER JOIN  → only matching rows on both sides.
-- • LEFT JOIN   → all rows from left + matching from right (NULLs for no match).
-- • RIGHT JOIN  → all rows from right + matching from left (rarely used; prefer LEFT).
-- • FULL OUTER JOIN → MySQL doesn't support directly; emulate with UNION of LEFT + RIGHT.
-- • SELF JOIN   → join a table to itself; use two aliases (e and m above).
-- • CROSS JOIN  → every row × every row; use sparingly.
-- • Anti-join pattern: LEFT JOIN … WHERE right.col IS NULL = "rows NOT in right table".
-- ───────────────────────────────────────────────────────────
