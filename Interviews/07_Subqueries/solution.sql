-- ============================================================
--  SQL INTERVIEW PREP — 07: Subqueries  ✅ SOLUTIONS
-- ============================================================
USE hr_db;

-- Q1. Employees above company average salary.
SELECT emp_id, first_name, last_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- Q2. Employee with the highest salary (no LIMIT).
SELECT * FROM employees
WHERE salary = (SELECT MAX(salary) FROM employees);

-- Q3. Employees in the same department as 'Alice Wang'.
SELECT * FROM employees
WHERE dept_id = (
    SELECT dept_id FROM employees
    WHERE first_name = 'Alice' AND last_name = 'Wang'
);

-- Q4. Each employee's salary vs their department average (correlated subquery).
SELECT
    first_name, last_name, dept_id, salary,
    (SELECT ROUND(AVG(e2.salary),2)
     FROM employees e2
     WHERE e2.dept_id = e1.dept_id) AS dept_avg_salary
FROM employees e1
ORDER BY dept_id;

-- Q5. Departments with above-average mean salary.
SELECT d.dept_name, ROUND(AVG(e.salary),2) AS avg_salary
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > (SELECT AVG(salary) FROM employees);

-- Q6. Employees earning more than EVERY HR employee (ALL).
SELECT first_name, last_name, salary
FROM employees
WHERE salary > ALL (
    SELECT salary FROM employees e
    JOIN departments d ON e.dept_id = d.dept_id
    WHERE d.dept_name = 'HR'
);

-- Q7. Employees earning more than AT LEAST ONE Finance employee (ANY).
SELECT first_name, last_name, salary
FROM employees
WHERE salary > ANY (
    SELECT salary FROM employees e
    JOIN departments d ON e.dept_id = d.dept_id
    WHERE d.dept_name = 'Finance'
);

-- Q8. Employees with NO salary history record (NOT EXISTS).
SELECT emp_id, first_name, last_name
FROM employees e
WHERE NOT EXISTS (
    SELECT 1 FROM salary_history sh
    WHERE sh.emp_id = e.emp_id
);

-- Q9. Departments with at least one 'Exceeds' performer (EXISTS).
SELECT dept_name
FROM departments d
WHERE EXISTS (
    SELECT 1 FROM employees e
    WHERE e.dept_id = d.dept_id
      AND e.performance = 'Exceeds'
);

-- Q10. Dept summary with above/below average flag.
SELECT
    d.dept_name,
    COUNT(e.emp_id)           AS headcount,
    ROUND(AVG(e.salary), 2)  AS avg_salary,
    CASE
        WHEN AVG(e.salary) > (SELECT AVG(salary) FROM employees)
        THEN 'Above Average Dept'
        ELSE 'Below Average Dept'
    END AS salary_flag
FROM departments d
JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

-- Q11. Top 2 earners in each department (correlated count).
SELECT emp_id, first_name, last_name, dept_id, salary
FROM employees e1
WHERE (
    SELECT COUNT(*)
    FROM employees e2
    WHERE e2.dept_id = e1.dept_id
      AND e2.salary > e1.salary
) < 2
ORDER BY dept_id, salary DESC;
-- Logic: "fewer than 2 people earn MORE than me" → I am top-2.

-- Q12. Employees within ±10% of median salary.
SELECT first_name, last_name, salary
FROM employees
WHERE salary BETWEEN
    (SELECT salary FROM employees ORDER BY salary
     LIMIT 1 OFFSET (SELECT CEILING(COUNT(*)/2)-1 FROM employees)) * 0.90
AND
    (SELECT salary FROM employees ORDER BY salary
     LIMIT 1 OFFSET (SELECT CEILING(COUNT(*)/2)-1 FROM employees)) * 1.10;

-- Q13. Customers with above-average order count.
USE ecommerce_db;
SELECT customer_id, COUNT(*) AS order_count
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > (
    SELECT AVG(cnt) FROM (
        SELECT COUNT(*) AS cnt FROM orders GROUP BY customer_id
    ) sub
);

-- Q14. Product with highest total revenue (no LIMIT).
SELECT product_id, SUM(total_amount) AS total_revenue
FROM orders
GROUP BY product_id
HAVING SUM(total_amount) = (
    SELECT MAX(rev) FROM (
        SELECT SUM(total_amount) AS rev FROM orders GROUP BY product_id
    ) sub
);

-- Q15. Orders in top 25% by total_amount.
SELECT *
FROM orders
WHERE total_amount >= (
    SELECT total_amount
    FROM orders
    ORDER BY total_amount DESC
    LIMIT 1 OFFSET (
        SELECT FLOOR(COUNT(*) * 0.25) FROM orders
    )
);

-- ── KEY TAKEAWAYS ──────────────────────────────────────────
-- • Scalar subquery   → returns 1 row, 1 col; used in WHERE/SELECT.
-- • Row subquery      → returns 1 row, multiple cols.
-- • Table subquery    → returns multiple rows; used with IN/ANY/ALL/FROM.
-- • Correlated subquery → references outer query; runs once per outer row.
-- • EXISTS            → returns TRUE if subquery produces any rows.
-- • NOT EXISTS        → anti-join alternative (often faster than NOT IN with NULLs).
-- • ALL / ANY         → compare a value against all/any values from a set.
-- • Subqueries in FROM clause (derived tables) must be aliased.
-- ───────────────────────────────────────────────────────────
