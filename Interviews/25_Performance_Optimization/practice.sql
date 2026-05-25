-- ============================================================
--  SQL INTERVIEW PREP — 25: Performance Optimization
--  Level     : Expert
--  Dataset   : Multi-table analytics (reusing perf_db + others)
--  Covers    : Query rewriting, EXPLAIN analysis, index tuning,
--              partitioning, query hints, profiling
-- ============================================================

USE perf_db;

-- ─────────────────────────────────────────────────────────────
--  TASKS — Each task presents a SLOW query.
--  Your job: identify the problem and rewrite/fix it.
-- ─────────────────────────────────────────────────────────────

-- Q1. [HARD] SLOW QUERY — Function on indexed column.
--     The following query does a full table scan even though order_date is indexed.
--     Identify WHY and rewrite it:

-- SLOW:
SELECT * FROM big_orders WHERE MONTH(order_date) = 6 AND YEAR(order_date) = 2023;

-- YOUR REWRITE:



-- Q2. [HARD] SLOW QUERY — Implicit type conversion.
--     The cust_id column is INT. This query does a full scan:

-- SLOW:
SELECT * FROM big_orders WHERE cust_id = '501';

-- Explain why and write the correct version:



-- Q3. [HARD] SLOW QUERY — SELECT * on a wide table.
--     This is fetching 10,000 rows with all columns unnecessarily.
--     Rewrite to only fetch what's needed:

-- SLOW:
SELECT * FROM big_orders WHERE status = 'delivered' ORDER BY order_date DESC LIMIT 100;

-- YOUR REWRITE (assume app needs: order_id, cust_id, amount, order_date):



-- Q4. [HARD] SLOW QUERY — NOT IN with NULLs.
--     This query may produce wrong results AND is slow.

-- SLOW:
SELECT * FROM big_customers
WHERE cust_id NOT IN (SELECT cust_id FROM big_orders);

-- Rewrite using NOT EXISTS:



-- Q5. [HARD] SLOW QUERY — Correlated subquery in SELECT running once per row.

-- SLOW:
SELECT o.order_id,
       (SELECT AVG(amount) FROM big_orders WHERE cust_id = o.cust_id) AS cust_avg
FROM big_orders o
LIMIT 1000;

-- Rewrite using a JOIN or CTE to compute avg ONCE per customer:



-- Q6. [HARD] SLOW QUERY — LIKE with leading wildcard.

-- SLOW:
SELECT * FROM big_customers WHERE email LIKE '%@example.com';

-- Explain why this can't use a B-Tree index.
-- Propose an alternative approach.



-- Q7. [HARD] SLOW QUERY — OR on different columns preventing index use.

-- SLOW:
SELECT * FROM big_orders WHERE status = 'delivered' OR region = 'North';

-- Rewrite using UNION to allow each condition to use its own index:



-- Q8. [HARD] SLOW QUERY — Forcing MySQL to use a specific index.
--     Sometimes the optimizer makes a bad choice. Use index hints.

EXPLAIN SELECT * FROM big_orders WHERE status = 'delivered' AND channel = 'web';
-- If it's not using idx_status_channel_date, force it:



-- Q9. [EXPERT] Partitioning:
--     Design a partitioned version of big_orders by YEAR(order_date).
--     Create the partitioned table and explain benefits.



-- Q10. [EXPERT] Profiling a query:
--      Enable profiling, run a query, then show the profile breakdown.
--      Also show how to use EXPLAIN FORMAT=JSON for detailed plan info.



-- Q11. [EXPERT] Write a query that demonstrates index merge:
--      Create separate indexes on status and region.
--      Run a query that uses BOTH in an OR condition.
--      EXPLAIN to see if MySQL uses "index_merge".



-- Q12. [EXPERT — Theory] Write detailed comments on:
--      (a) What EXPLAIN columns mean: type, key, rows, Extra
--      (b) The difference between "Using filesort" and "Using index"
--      (c) When to use a composite index vs multiple single-column indexes
--      (d) What "covering index" means and when it helps most
--      (e) How MySQL's Query Cache worked (deprecated) and why
--      (f) The role of the InnoDB buffer pool in query performance
