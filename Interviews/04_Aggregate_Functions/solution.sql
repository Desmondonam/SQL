-- ============================================================
--  SQL INTERVIEW PREP — 04: Aggregate Functions  ✅ SOLUTIONS
-- ============================================================
USE hr_db;

-- Q1. Total number of employees.
SELECT COUNT(*) AS total_employees FROM employees;

-- Q2. Highest salary.
SELECT MAX(salary) AS highest_salary FROM employees;

-- Q3. Lowest salary.
SELECT MIN(salary) AS lowest_salary FROM employees;

-- Q4. Average salary of active employees only.
SELECT AVG(salary) AS avg_salary FROM employees WHERE is_active = TRUE;

-- Q5. Total payroll.
SELECT SUM(salary) AS total_payroll FROM employees;

-- Q6. Number of distinct job titles.
SELECT COUNT(DISTINCT job_title) AS unique_job_titles FROM employees;

-- Q7. Active vs Inactive employee count in one query.
SELECT
    COUNT(CASE WHEN is_active = TRUE  THEN 1 END) AS active_employees,
    COUNT(CASE WHEN is_active = FALSE THEN 1 END) AS inactive_employees
FROM employees;
-- Alternative using SUM:
-- SUM(is_active) AS active, SUM(1 - is_active) AS inactive

-- Q8. Average age by gender.
SELECT gender, ROUND(AVG(age), 1) AS avg_age
FROM employees
GROUP BY gender;

-- Q9. Salary range (max - min).
SELECT MAX(salary) - MIN(salary) AS salary_range FROM employees;

-- Q10. Percentage of female employees.
SELECT
    ROUND(COUNT(CASE WHEN gender = 'F' THEN 1 END) / COUNT(*), 4) AS female_pct
FROM employees;
-- Or: SUM(gender = 'F') / COUNT(*) — MySQL treats TRUE=1

-- Q11. Employee count by performance category.
SELECT performance, COUNT(*) AS employee_count
FROM employees
GROUP BY performance
ORDER BY employee_count DESC;

-- Q12. Total and average department budget.
SELECT
    SUM(budget)  AS total_budget,
    AVG(budget)  AS avg_budget
FROM departments;

-- Q13. Gap between max salary and average salary.
SELECT
    MAX(salary)              AS max_salary,
    ROUND(AVG(salary), 2)   AS avg_salary,
    MAX(salary) - AVG(salary) AS above_average_gap
FROM employees;

-- Q14. Employees hired before 2020.
SELECT COUNT(*) AS hired_before_2020
FROM employees
WHERE hire_date < '2020-01-01';

-- Q15. Aggregates for active employees in one query.
SELECT
    COUNT(*)            AS headcount,
    ROUND(AVG(salary),2) AS avg_salary,
    MIN(salary)         AS min_salary,
    MAX(salary)         AS max_salary
FROM employees
WHERE is_active = TRUE;

-- ── KEY TAKEAWAYS ──────────────────────────────────────────
-- • COUNT(*) counts all rows; COUNT(col) skips NULLs.
-- • COUNT(DISTINCT col) counts unique non-null values.
-- • SUM / AVG / MIN / MAX all ignore NULL values.
-- • CASE WHEN inside an aggregate = conditional aggregation
--   (great for pivot-like results in one pass).
-- • ROUND(value, decimals) controls decimal precision.
-- ───────────────────────────────────────────────────────────
