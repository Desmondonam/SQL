-- ============================================================
--  SQL INTERVIEW PREP — 08: Window Functions  ✅ SOLUTIONS
-- ============================================================
USE window_db;

-- Q1. ROW_NUMBER over all sales by date.
SELECT
    sale_id, emp_name, sale_date, amount,
    ROW_NUMBER() OVER (ORDER BY sale_date) AS row_num
FROM employee_sales;

-- Q2. RANK by amount DESC.
SELECT
    sale_id, emp_name, amount,
    RANK() OVER (ORDER BY amount DESC) AS sale_rank
FROM employee_sales;
-- Ties share a rank; next rank skips (e.g., 1,2,2,4…)

-- Q3. DENSE_RANK by amount DESC.
SELECT
    sale_id, emp_name, amount,
    DENSE_RANK() OVER (ORDER BY amount DESC) AS dense_sale_rank
FROM employee_sales;
-- Ties share a rank; next rank does NOT skip (e.g., 1,2,2,3…)

-- Q4. Rank employees by total sales within each department.
SELECT
    emp_name, department,
    SUM(amount) AS total_sales,
    RANK() OVER (PARTITION BY department ORDER BY SUM(amount) DESC) AS dept_rank
FROM employee_sales
GROUP BY emp_name, department;

-- Q5. Running total (cumulative sum) by sale_date.
SELECT
    sale_id, emp_name, sale_date, amount,
    SUM(amount) OVER (ORDER BY sale_date
                      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM employee_sales;

-- Q6. LAG and LEAD — previous and next sale by the same employee.
SELECT
    emp_name, sale_date, amount,
    LAG(amount,  1) OVER (PARTITION BY emp_name ORDER BY sale_date) AS prev_sale,
    LEAD(amount, 1) OVER (PARTITION BY emp_name ORDER BY sale_date) AS next_sale
FROM employee_sales;

-- Q7. NTILE(4) — divide by total sales into quartiles.
SELECT
    emp_name,
    SUM(amount) AS total_sales,
    NTILE(4) OVER (ORDER BY SUM(amount)) AS quartile
FROM employee_sales
GROUP BY emp_name;

-- Q8. 3-month moving average per region.
SELECT
    region, year_month, total_sale,
    ROUND(AVG(total_sale) OVER (
        PARTITION BY region
        ORDER BY year_month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg_3m
FROM monthly_sales
ORDER BY region, year_month;

-- Q9. First and last sale per employee.
SELECT
    emp_name, sale_date, amount,
    FIRST_VALUE(amount) OVER (
        PARTITION BY emp_name ORDER BY sale_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS first_sale,
    LAST_VALUE(amount) OVER (
        PARTITION BY emp_name ORDER BY sale_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_sale
FROM employee_sales;

-- Q10. Each sale as % of department total.
SELECT
    emp_name, department, sale_date, amount,
    ROUND(100.0 * amount /
        SUM(amount) OVER (PARTITION BY department), 2) AS pct_of_dept
FROM employee_sales
ORDER BY department, pct_of_dept DESC;

-- Q11. Month-over-month change per region.
SELECT
    region, year_month, total_sale,
    LAG(total_sale) OVER (PARTITION BY region ORDER BY year_month) AS prev_month,
    ROUND(100.0 * (total_sale -
        LAG(total_sale) OVER (PARTITION BY region ORDER BY year_month)) /
        NULLIF(LAG(total_sale) OVER (PARTITION BY region ORDER BY year_month), 0), 2) AS change_pct
FROM monthly_sales
ORDER BY region, year_month;

-- Q12. Top 2 sales per employee using ROW_NUMBER.
SELECT * FROM (
    SELECT
        emp_name, sale_date, amount,
        ROW_NUMBER() OVER (PARTITION BY emp_name ORDER BY amount DESC) AS rn
    FROM employee_sales
) ranked
WHERE rn <= 2
ORDER BY emp_name, rn;

-- Q13. Running total per region per month.
SELECT
    region, year_month, total_sale,
    SUM(total_sale) OVER (
        PARTITION BY region
        ORDER BY year_month
        ROWS UNBOUNDED PRECEDING
    ) AS cumulative_sale
FROM monthly_sales
ORDER BY region, year_month;

-- Q14. Top region per month (rank = 1).
SELECT region, year_month, total_sale, monthly_rank
FROM (
    SELECT
        region, year_month, total_sale,
        RANK() OVER (PARTITION BY year_month ORDER BY total_sale DESC) AS monthly_rank
    FROM monthly_sales
) ranked
WHERE monthly_rank = 1
ORDER BY year_month;

-- Q15. Year-to-date (YTD) cumulative sales per region.
SELECT
    region, year_month, total_sale,
    SUM(total_sale) OVER (
        PARTITION BY region, YEAR(year_month)
        ORDER BY year_month
        ROWS UNBOUNDED PRECEDING
    ) AS ytd_total
FROM monthly_sales
ORDER BY region, year_month;

-- ── KEY TAKEAWAYS ──────────────────────────────────────────
-- • Window functions use OVER() — they do NOT collapse rows.
-- • PARTITION BY = "reset the window" for each group.
-- • ORDER BY inside OVER() controls the logical ordering.
-- • ROW_NUMBER → unique; RANK → gaps on ties; DENSE_RANK → no gaps.
-- • LAG(col,n) / LEAD(col,n) → access n rows behind/ahead.
-- • ROWS BETWEEN … AND … defines the frame of rows in the window.
-- • UNBOUNDED PRECEDING = from start; CURRENT ROW = current row.
-- • Wrap window queries in a subquery to filter on window results.
-- ───────────────────────────────────────────────────────────
