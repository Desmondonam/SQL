-- ============================================================
--  SQL INTERVIEW PREP — 17: CASE Statements  ✅ SOLUTIONS
-- ============================================================
USE window_db;

-- Q1. Classify sales by amount.
SELECT emp_name, department, amount,
    CASE
        WHEN amount < 2000             THEN 'Small'
        WHEN amount BETWEEN 2000 AND 7999 THEN 'Medium'
        ELSE 'Large'
    END AS sale_size
FROM employee_sales;

-- Q2. Age group labels (hr_db).
USE hr_db;
SELECT first_name, last_name, age,
    CASE
        WHEN age < 30  THEN 'Junior'
        WHEN age <= 39 THEN 'Mid-Career'
        ELSE 'Senior'
    END AS age_group
FROM employees;

-- Q3. Commission rates by department.
USE window_db;
SELECT
    emp_name, department, amount,
    CASE department
        WHEN 'Electronics' THEN 0.05
        WHEN 'Clothing'    THEN 0.08
        WHEN 'Books'       THEN 0.03
        ELSE 0.02
    END AS commission_rate,
    ROUND(amount * CASE department
        WHEN 'Electronics' THEN 0.05
        WHEN 'Clothing'    THEN 0.08
        WHEN 'Books'       THEN 0.03
        ELSE 0.02 END, 2) AS commission_earned
FROM employee_sales;

-- Q4. PIVOT using conditional aggregation.
SELECT
    emp_name,
    SUM(CASE WHEN department='Electronics' THEN amount ELSE 0 END) AS electronics_total,
    SUM(CASE WHEN department='Clothing'    THEN amount ELSE 0 END) AS clothing_total,
    SUM(CASE WHEN department='Books'       THEN amount ELSE 0 END) AS books_total
FROM employee_sales
GROUP BY emp_name
ORDER BY emp_name;

-- Q5. Multi-condition performance label (hr_db).
USE hr_db;
SELECT
    first_name, last_name, salary, performance,
    CASE
        WHEN salary >= 120000 AND performance = 'Exceeds' THEN 'Top Talent'
        WHEN salary >= 90000                              THEN 'High Earner'
        WHEN performance = 'Exceeds'                     THEN 'High Performer'
        WHEN performance = 'Below'                       THEN 'Needs Improvement'
        ELSE 'Standard'
    END AS performance_label
FROM employees;
-- Note: CASE evaluates conditions in order — first match wins.

-- Q6. Custom ORDER BY with CASE (ecommerce_db).
USE ecommerce_db;
SELECT order_id, order_status, purchase_date
FROM orders
ORDER BY
    CASE order_status
        WHEN 'delivered'  THEN 1
        WHEN 'shipped'    THEN 2
        WHEN 'processing' THEN 3
        WHEN 'canceled'   THEN 4
        ELSE 5
    END,
    purchase_date;

-- Q7. Month-over-month direction using LAG + CASE.
USE window_db;
SELECT
    region, year_month, total_sale,
    LAG(total_sale) OVER (PARTITION BY region ORDER BY year_month) AS prev_month,
    CASE
        WHEN total_sale > LAG(total_sale) OVER (PARTITION BY region ORDER BY year_month) THEN 'UP'
        WHEN total_sale < LAG(total_sale) OVER (PARTITION BY region ORDER BY year_month) THEN 'DOWN'
        WHEN LAG(total_sale) OVER (PARTITION BY region ORDER BY year_month) IS NULL THEN 'FIRST'
        ELSE 'SAME'
    END AS direction
FROM monthly_sales
ORDER BY region, year_month;

-- Q8. Employee scorecard (hr_db).
USE hr_db;
WITH dept_avg AS (
    SELECT dept_id, AVG(salary) AS avg_sal FROM employees GROUP BY dept_id
)
SELECT
    e.first_name, e.last_name,
    (
        CASE WHEN e.performance='Exceeds' THEN 3 ELSE 0 END +
        CASE WHEN e.salary > d.avg_sal    THEN 2 ELSE 0 END +
        CASE WHEN DATEDIFF(CURDATE(),e.hire_date)/365 > 5 THEN 2 ELSE 0 END +
        CASE WHEN e.is_active=TRUE        THEN 2 ELSE 0 END +
        CASE WHEN e.gender='F'            THEN 1 ELSE 0 END
    ) AS total_score,
    CASE
        WHEN (CASE WHEN e.performance='Exceeds' THEN 3 ELSE 0 END +
              CASE WHEN e.salary > d.avg_sal THEN 2 ELSE 0 END +
              CASE WHEN DATEDIFF(CURDATE(),e.hire_date)/365>5 THEN 2 ELSE 0 END +
              CASE WHEN e.is_active=TRUE THEN 2 ELSE 0 END +
              CASE WHEN e.gender='F' THEN 1 ELSE 0 END) >= 8 THEN 'A'
        WHEN (CASE WHEN e.performance='Exceeds' THEN 3 ELSE 0 END +
              CASE WHEN e.salary > d.avg_sal THEN 2 ELSE 0 END +
              CASE WHEN DATEDIFF(CURDATE(),e.hire_date)/365>5 THEN 2 ELSE 0 END +
              CASE WHEN e.is_active=TRUE THEN 2 ELSE 0 END +
              CASE WHEN e.gender='F' THEN 1 ELSE 0 END) >= 5 THEN 'B'
        ELSE 'C'
    END AS grade
FROM employees e
JOIN dept_avg d ON e.dept_id = d.dept_id
ORDER BY total_score DESC;

-- Q9. CASE in HAVING.
USE ecommerce_db;
SELECT payment_type, COUNT(*) AS order_count
FROM orders
GROUP BY payment_type
HAVING
    CASE WHEN payment_type = 'credit_card' THEN COUNT(*) >= 5
         ELSE COUNT(*) >= 2
    END;

-- Q10. Full customer health dashboard.
USE ecommerce_db;
WITH customer_metrics AS (
    SELECT
        customer_id,
        COUNT(*)             AS order_count,
        AVG(total_amount)    AS avg_spend,
        AVG(review_score)    AS avg_review
    FROM orders
    GROUP BY customer_id
)
SELECT
    c.customer_name,
    cm.order_count, cm.avg_spend, cm.avg_review,
    CASE WHEN cm.order_count >= 3 THEN 'High'
         WHEN cm.order_count = 2  THEN 'Medium'
         ELSE 'Low' END AS order_frequency,
    CASE WHEN cm.avg_spend > 400 THEN 'Premium'
         WHEN cm.avg_spend >= 200 THEN 'Standard'
         ELSE 'Budget' END AS spend_tier,
    CASE WHEN cm.avg_review >= 4  THEN 'Happy'
         WHEN cm.avg_review >= 3  THEN 'Neutral'
         ELSE 'Unhappy' END AS satisfaction,
    CASE
        WHEN cm.order_count >= 3 AND cm.avg_spend > 400 AND cm.avg_review >= 4 THEN 'Excellent'
        WHEN cm.order_count = 1 OR cm.avg_review < 3 OR cm.avg_review IS NULL   THEN 'At Risk'
        ELSE 'Good'
    END AS overall_health
FROM customer_metrics cm
JOIN customers c ON cm.customer_id = c.customer_id
ORDER BY overall_health, cm.order_count DESC;

-- ── KEY TAKEAWAYS ──────────────────────────────────────────
-- • Simple CASE:   CASE col WHEN val THEN … END
-- • Searched CASE: CASE WHEN condition THEN … END
-- • First matching WHEN wins — order your conditions carefully.
-- • CASE inside SUM/COUNT = conditional aggregation (=pivot technique).
-- • CASE in ORDER BY = custom sort priority.
-- • CASE in HAVING = conditional filter on grouped data.
-- • Nested/complex CASE = multi-factor scoring, health dashboards.
-- ───────────────────────────────────────────────────────────
