-- ============================================================
--  SQL INTERVIEW PREP — 08: Window Functions
--  Level     : Advanced
--  Dataset   : Sales Performance dataset
--              (Window functions are one of the most-tested
--               advanced SQL topics in FAANG/tech interviews)
-- ============================================================

CREATE DATABASE IF NOT EXISTS window_db;
USE window_db;

DROP TABLE IF EXISTS monthly_sales;
DROP TABLE IF EXISTS employee_sales;

CREATE TABLE employee_sales (
    sale_id     INT PRIMARY KEY AUTO_INCREMENT,
    emp_name    VARCHAR(80),
    department  VARCHAR(50),
    region      VARCHAR(50),
    sale_date   DATE,
    amount      DECIMAL(10,2)
);

INSERT INTO employee_sales (emp_name,department,region,sale_date,amount) VALUES
 ('Alice',  'Electronics','North','2023-01-05',  8500),
 ('Bob',    'Electronics','North','2023-01-12',  4200),
 ('Carol',  'Clothing',   'South','2023-01-15',  3100),
 ('Dave',   'Books',      'East', '2023-01-20',  1200),
 ('Alice',  'Electronics','North','2023-02-01',  9100),
 ('Bob',    'Electronics','North','2023-02-07',  5300),
 ('Carol',  'Clothing',   'South','2023-02-10',  4800),
 ('Dave',   'Books',      'East', '2023-02-14',  2100),
 ('Eve',    'Clothing',   'West', '2023-02-20',  6200),
 ('Frank',  'Electronics','South','2023-03-01',  7800),
 ('Alice',  'Electronics','North','2023-03-08', 12000),
 ('Bob',    'Clothing',   'North','2023-03-15',  3900),
 ('Carol',  'Clothing',   'South','2023-03-22',  5500),
 ('Dave',   'Books',      'East', '2023-03-28',  1800),
 ('Eve',    'Electronics','West', '2023-04-01',  9500),
 ('Frank',  'Clothing',   'South','2023-04-10',  4100),
 ('Alice',  'Books',      'North','2023-04-15',  1100),
 ('Bob',    'Electronics','North','2023-04-22',  7600),
 ('Carol',  'Electronics','South','2023-05-01',  8900),
 ('Dave',   'Clothing',   'East', '2023-05-10',  3300),
 ('Eve',    'Books',      'West', '2023-05-15',   950),
 ('Frank',  'Electronics','South','2023-06-01', 11000),
 ('Alice',  'Clothing',   'North','2023-06-10',  2700),
 ('Bob',    'Books',      'North','2023-06-18',   750),
 ('Carol',  'Electronics','South','2023-07-01',  9800);

CREATE TABLE monthly_sales (
    year_month DATE,    -- first day of month, e.g. 2023-01-01
    region     VARCHAR(50),
    total_sale DECIMAL(12,2)
);

INSERT INTO monthly_sales VALUES
 ('2023-01-01','North',22700),('2023-01-01','South',15300),('2023-01-01','East', 9800),('2023-01-01','West', 5200),
 ('2023-02-01','North',25100),('2023-02-01','South',16800),('2023-02-01','East',11200),('2023-02-01','West', 8400),
 ('2023-03-01','North',28500),('2023-03-01','South',18900),('2023-03-01','East',10600),('2023-03-01','West',12300),
 ('2023-04-01','North',21300),('2023-04-01','South',20100),('2023-04-01','East', 9100),('2023-04-01','West',14800),
 ('2023-05-01','North',19800),('2023-05-01','South',22700),('2023-05-01','East',11500),('2023-05-01','West',16200),
 ('2023-06-01','North',24600),('2023-06-01','South',25300),('2023-06-01','East',13800),('2023-06-01','West',18900),
 ('2023-07-01','North',27900),('2023-07-01','South',27100),('2023-07-01','East',15200),('2023-07-01','West',21400);

-- ─────────────────────────────────────────────────────────────
--  TASKS
-- ─────────────────────────────────────────────────────────────

-- Q1. [EASY] Assign a sequential row number to each sale, ordered by sale_date.
--     Show sale_id, emp_name, sale_date, amount, row_num.



-- Q2. [EASY] Rank all sales by amount DESC.
--     Show RANK() — ties get the same rank and the next rank skips.



-- Q3. [EASY] DENSE_RANK all sales by amount DESC.
--     Show DENSE_RANK() — ties get same rank, next rank does NOT skip.



-- Q4. [MEDIUM] Rank employees by total sales within each department.
--     Show emp_name, department, total_sales, dept_rank.



-- Q5. [MEDIUM] Show each sale's running total (cumulative SUM) of amount
--     ordered by sale_date. Window: ROWS UNBOUNDED PRECEDING.



-- Q6. [MEDIUM] For each sale, show the PREVIOUS sale amount by the same
--     employee (LAG) and the NEXT sale amount (LEAD).



-- Q7. [MEDIUM] Divide all employees (by total sales) into 4 equal groups
--     (quartiles) using NTILE(4).



-- Q8. [HARD] Calculate a 3-month MOVING AVERAGE of total_sale per region
--     in monthly_sales. Order by region, year_month.
--     Window: current row + 2 preceding.



-- Q9. [HARD] For each sale, show:
--     - The FIRST sale amount ever made by that employee (FIRST_VALUE)
--     - The LAST sale amount made by that employee so far (LAST_VALUE)
--     Partition by emp_name, order by sale_date.



-- Q10. [HARD] Show the percentage each sale contributes to the department's
--      total sales. (amount / SUM(amount) OVER dept partition)



-- Q11. [HARD] Find month-over-month change in total_sale per region.
--      Show region, year_month, total_sale, prev_month_sale, change_pct.



-- Q12. [EXPERT] Find the top-2 sales by amount for each employee
--      using ROW_NUMBER() — handle duplicates fairly.



-- Q13. [EXPERT] Calculate the running total per region per month,
--      resetting at the start of each region partition.
--      Show region, year_month, total_sale, cumulative_sale.



-- Q14. [EXPERT] For each month in monthly_sales, show the region ranked #1
--      in total_sale (using RANK and filtering = 1).



-- Q15. [EXPERT] Calculate year-to-date (YTD) cumulative sales per region.
--      Show region, year_month, total_sale, ytd_total.
--      Window: PARTITION BY region, YEAR(year_month), ORDER BY year_month.
