-- ============================================================
--  SQL INTERVIEW PREP — 07: Subqueries
--  Level     : Intermediate → Advanced
--  Dataset   : HR + E-Commerce (reusing hr_db & ecommerce_db)
-- ============================================================

USE hr_db;

-- ─────────────────────────────────────────────────────────────
--  TASKS
-- ─────────────────────────────────────────────────────────────

-- Q1. [EASY] Find all employees whose salary is above the COMPANY average.
--     (Scalar subquery in WHERE)



-- Q2. [EASY] Find the employee(s) with the HIGHEST salary.
--     (Use a subquery — do NOT use LIMIT/ORDER BY.)



-- Q3. [MEDIUM] Find all employees who work in the same department as 'Alice Wang'.
--     Do NOT hardcode the department ID.



-- Q4. [MEDIUM] Show each employee's salary and the average salary of their department.
--     (Correlated subquery in SELECT)



-- Q5. [MEDIUM] Find departments whose average salary is above the company-wide average.
--     (Subquery in HAVING)



-- Q6. [MEDIUM] Find employees who earn MORE than every employee in the 'HR' department.
--     (ALL operator with subquery)



-- Q7. [MEDIUM] Find employees who earn MORE than AT LEAST ONE employee in Finance.
--     (ANY/SOME operator with subquery)



-- Q8. [HARD] Find employees who have NOT had a salary raise recorded in salary_history.
--     (NOT EXISTS pattern)



-- Q9. [HARD] Show departments where at least one employee has performance = 'Exceeds'.
--     (EXISTS pattern)



-- Q10. [HARD] For each department, show:
--      dept_name, headcount, avg_salary, and a flag:
--      'Above Average Dept' if avg_salary > company avg, else 'Below Average Dept'.
--      Use a subquery for the company average.



-- Q11. [HARD] Find the top 2 earners in each department.
--      (Correlated subquery counting how many earn more.)



-- Q12. [EXPERT] Show all employees whose salary falls within ±10% of the
--      company median salary.
--      (Median: subquery using LIMIT/OFFSET trick in MySQL.)
--      Hint: Median row = CEILING(COUNT(*)/2)



-- Q13. [EXPERT] (Using ecommerce_db)
--      Switch: USE ecommerce_db;
--      Find customers who have placed MORE orders than the average number
--      of orders per customer.



-- Q14. [EXPERT] (Still ecommerce_db)
--      Find the product that generated the highest total revenue
--      (total_amount SUM) without using LIMIT. Use a subquery.



-- Q15. [EXPERT] (Still ecommerce_db)
--      Find orders where total_amount is in the TOP 25% of all orders.
--      Use a subquery to calculate the 75th percentile threshold.
--      Hint: PERCENTILE using count logic.
