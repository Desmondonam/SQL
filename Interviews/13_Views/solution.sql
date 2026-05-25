-- ============================================================
--  SQL INTERVIEW PREP — 13: Views  ✅ SOLUTIONS
-- ============================================================
USE ecommerce_db;

-- Q1. View for delivered orders.
CREATE OR REPLACE VIEW v_delivered_orders AS
SELECT order_id, customer_id, product_id, purchase_date, total_amount
FROM orders
WHERE order_status = 'delivered';

SELECT * FROM v_delivered_orders;

-- Q2. View for Electronics/Books products.
CREATE OR REPLACE VIEW v_product_summary AS
SELECT product_id, category, product_name, price, stock_qty
FROM products
WHERE category IN ('Electronics','Books');

SELECT * FROM v_product_summary;

-- Q3. View joining customers + orders.
CREATE OR REPLACE VIEW v_customer_orders AS
SELECT
    c.customer_name,
    c.city,
    o.order_id,
    o.order_status,
    o.total_amount
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;

SELECT * FROM v_customer_orders WHERE order_status = 'canceled';

-- Q4. Aggregate view per customer.
CREATE OR REPLACE VIEW v_order_stats AS
SELECT
    customer_id,
    COUNT(*)                    AS total_orders,
    ROUND(SUM(total_amount),2)  AS total_spent,
    ROUND(AVG(review_score),2)  AS avg_review_score
FROM orders
GROUP BY customer_id;

SELECT * FROM v_order_stats ORDER BY total_spent DESC;

-- Q5. View on top of another view.
CREATE OR REPLACE VIEW v_high_value_customers AS
SELECT * FROM v_order_stats
WHERE total_spent > 500;

SELECT * FROM v_high_value_customers;

-- Q6. Query a view like a table.
SELECT * FROM v_order_stats ORDER BY total_spent DESC;

-- Q7. Department summary view (hr_db).
USE hr_db;
CREATE OR REPLACE VIEW v_dept_summary AS
SELECT
    d.dept_name,
    COUNT(e.emp_id)           AS headcount,
    ROUND(AVG(e.salary),2)   AS avg_salary,
    MIN(e.salary)             AS min_salary,
    MAX(e.salary)             AS max_salary,
    SUM(e.salary)             AS total_payroll
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

SELECT * FROM v_dept_summary ORDER BY total_payroll DESC;

-- Q8. Updatable view — active employees.
CREATE OR REPLACE VIEW v_active_employees AS
SELECT * FROM employees WHERE is_active = TRUE;

-- Update through the view (updates the base table):
UPDATE v_active_employees SET salary = 82000 WHERE emp_id = 15;
SELECT salary FROM employees WHERE emp_id = 15;  -- verify

-- Q9. WITH CHECK OPTION.
CREATE OR REPLACE VIEW v_engineering AS
SELECT * FROM employees
WHERE dept_id = 1
WITH CHECK OPTION;  -- ensures all writes through view respect dept_id = 1

-- This will SUCCEED (dept_id = 1):
-- INSERT INTO v_engineering (first_name,last_name,dept_id,job_title,salary,hire_date,gender,age,performance)
-- VALUES ('Test','Engineer',1,'Junior Dev',70000,'2024-01-01','M',23,'Meets');

-- This will FAIL — dept_id != 1 violates the WITH CHECK OPTION:
-- INSERT INTO v_engineering (first_name,last_name,dept_id,job_title,salary,hire_date,gender,age,performance)
-- VALUES ('Wrong','Dept',3,'Sales Rep',65000,'2024-01-01','F',25,'Meets');
-- ERROR: CHECK OPTION failed for 'hr_db.v_engineering'

-- Q10. Expert discussion + secure view.
/*
  (a) NON-UPDATABLE VIEW conditions:
      A view is NOT updatable if it uses:
      - Aggregate functions (SUM, COUNT, AVG …)
      - DISTINCT
      - GROUP BY / HAVING
      - UNION / UNION ALL
      - Subqueries in SELECT or FROM
      - Certain JOINs (LEFT JOIN to a nullable table is sometimes allowed)
      - LIMIT (sometimes restricts updatability)

  (b) MATERIALIZED VIEWS:
      A materialized view stores the RESULT of the query physically on disk
      (unlike regular views, which re-execute the query each time).
      MySQL does NOT natively support materialized views (unlike PostgreSQL/Oracle).

  (c) SIMULATING MATERIALIZED VIEWS IN MYSQL:
      Option 1: Create a real table + populate with INSERT INTO … SELECT.
                Refresh manually or via EVENT SCHEDULER.
      Option 2: Use MySQL EVENT SCHEDULER to refresh periodically.

      Example:
      CREATE TABLE mv_dept_summary AS SELECT * FROM v_dept_summary;

      CREATE EVENT refresh_mv_dept
      ON SCHEDULE EVERY 1 HOUR
      DO
      BEGIN
          TRUNCATE TABLE mv_dept_summary;
          INSERT INTO mv_dept_summary SELECT * FROM v_dept_summary;
      END;

  (d) SECURITY — hiding sensitive columns via views:
      Grant users access to the VIEW but not the base table.
      The view exposes only safe columns.
*/

-- Public view hiding salary/PII:
CREATE OR REPLACE VIEW v_public_employee_info AS
SELECT
    emp_id,
    CONCAT(first_name,' ',LEFT(last_name,1),'.') AS display_name,
    job_title,
    dept_id
FROM employees
WHERE is_active = TRUE;

SELECT * FROM v_public_employee_info;
-- Salary, hire_date, gender, age, performance — all hidden from this view.

-- ── KEY TAKEAWAYS ──────────────────────────────────────────
-- • CREATE OR REPLACE VIEW avoids "view already exists" errors.
-- • Views are virtual tables — they store the QUERY, not data.
-- • Views can be queried with WHERE, JOIN, ORDER BY just like tables.
-- • Views stacked on views can get slow — re-executing queries each time.
-- • WITH CHECK OPTION enforces the view filter on writes.
-- • For performance-sensitive use: simulate materialized view with a table + EVENT.
-- ───────────────────────────────────────────────────────────
