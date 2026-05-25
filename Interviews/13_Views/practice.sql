-- ============================================================
--  SQL INTERVIEW PREP — 13: Views
--  Level     : Intermediate → Advanced
--  Dataset   : E-Commerce + HR databases
-- ============================================================

USE ecommerce_db;

-- ─────────────────────────────────────────────────────────────
--  TASKS
-- ─────────────────────────────────────────────────────────────

-- Q1. [EASY] Create a VIEW called 'v_delivered_orders' that shows
--     only delivered orders with: order_id, customer_id, product_id,
--     purchase_date, total_amount.



-- Q2. [EASY] Create a VIEW 'v_product_summary' that shows:
--     product_id, category, product_name, price, stock_qty
--     only for products in 'Electronics' or 'Books'.



-- Q3. [MEDIUM] Create a view 'v_customer_orders' that JOINs
--     customers with their orders, showing:
--     customer_name, city, order_id, order_status, total_amount.



-- Q4. [MEDIUM] Create a view 'v_order_stats' that shows
--     aggregate stats per customer:
--     customer_id, total_orders, total_spent, avg_review_score.



-- Q5. [MEDIUM] Create a view 'v_high_value_customers' that uses
--     'v_order_stats' (views can reference other views!) to show
--     only customers who have spent more than $500.



-- Q6. [MEDIUM] Query the view: show all customers from v_order_stats
--     sorted by total_spent DESC. Notice — you use it just like a table!



-- Q7. [HARD] (Switch to hr_db)
--     CREATE a view 'v_dept_summary' in hr_db that shows:
--     dept_name, headcount, avg_salary, min_salary, max_salary,
--     total_payroll. Join departments and employees.



-- Q8. [HARD] Demonstrate an UPDATABLE VIEW:
--     Create a view 'v_active_employees' (hr_db) that shows only
--     active employees. Then UPDATE a salary through the view.
--     (Views are updatable if they meet certain criteria — no GROUP BY,
--     no DISTINCT, no aggregates, based on single table.)



-- Q9. [HARD] Use WITH CHECK OPTION:
--     Create a view 'v_engineering' that shows Engineering dept employees.
--     Add WITH CHECK OPTION so INSERTs through the view are validated.
--     Try inserting an employee with a different dept_id — it should fail.



-- Q10. [EXPERT] Discuss in comments:
--      (a) What makes a view NON-updatable?
--      (b) What is a MATERIALIZED VIEW and does MySQL support it natively?
--      (c) How to simulate a materialized view in MySQL.
--      (d) Security benefit: how views can hide sensitive columns.
--      Then create a view 'v_public_employee_info' that shows
--      only name, job_title, dept_id — hiding salary and other PII.
