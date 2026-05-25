-- ============================================================
--  SQL INTERVIEW PREP — 17: CASE Statements
--  Level     : Intermediate → Advanced
--  Dataset   : Sales + HR data (reusing window_db and hr_db)
--              CASE is one of the most-used tools in SQL analytics
-- ============================================================

USE window_db;

-- ─────────────────────────────────────────────────────────────
--  TASKS
-- ─────────────────────────────────────────────────────────────

-- Q1. [EASY] Classify each sale by amount:
--     < 2000 = 'Small', 2000–7999 = 'Medium', >= 8000 = 'Large'



-- Q2. [EASY] In hr_db.employees, label each employee's age group:
--     < 30 = 'Junior', 30-39 = 'Mid-Career', 40+ = 'Senior'



-- Q3. [MEDIUM] In employee_sales, show each sale with a commission rate:
--     Electronics → 5%
--     Clothing    → 8%
--     Books       → 3%
--     Show: emp_name, department, amount, commission_rate, commission_earned.



-- Q4. [MEDIUM] PIVOT the employee_sales table:
--     Show each employee with total sales per department in separate columns:
--     emp_name | electronics_total | clothing_total | books_total
--     (Use CASE inside SUM for conditional aggregation = pivot)



-- Q5. [MEDIUM] In hr_db.employees, show performance_label:
--     salary >= 120000 AND performance = 'Exceeds' → 'Top Talent'
--     salary >= 90000                              → 'High Earner'
--     performance = 'Exceeds'                      → 'High Performer'
--     performance = 'Below'                        → 'Needs Improvement'
--     ELSE                                         → 'Standard'



-- Q6. [MEDIUM] Use CASE in ORDER BY to sort:
--     Delivered orders first, then Shipped, then Processing, then Canceled.
--     (ecommerce_db.orders)



-- Q7. [HARD] In monthly_sales, calculate month-over-month direction:
--     Show: region, year_month, total_sale,
--     direction: 'UP' if higher than previous month, 'DOWN' if lower, 'SAME' if equal.
--     (Use LAG inside CASE)



-- Q8. [HARD] Create a CASE-based scorecard for each employee in hr_db:
--     Score 0-10 based on:
--     +3 if performance = 'Exceeds'
--     +2 if salary > dept average
--     +2 if years_of_service > 5
--     +2 if is_active = TRUE
--     +1 if gender = 'F' (diversity bonus)
--     Show: emp_name, total_score, grade (8-10='A', 5-7='B', <5='C')



-- Q9. [HARD] CASE in HAVING:
--     In ecommerce_db.orders, group by payment_type.
--     Show groups where: if payment_type = 'credit_card' then at least 5 orders,
--                        else at least 2 orders.



-- Q10. [EXPERT] Build a full customer health dashboard using CASE:
--      Using ecommerce_db.orders + customers, calculate per customer:
--      - order_frequency: 'High' (>=3 orders), 'Medium' (2), 'Low' (1)
--      - avg_spend_tier:  'Premium' (avg>400), 'Standard' (avg 200-400), 'Budget' (<200)
--      - satisfaction:    'Happy' (avg review>=4), 'Neutral' (3-3.9), 'Unhappy' (<3 or NULL)
--      - overall_health:  'Excellent' if all High+Premium+Happy,
--                         'At Risk' if any Unhappy or Low,
--                         'Good' otherwise
