-- ============================================================
--  SQL INTERVIEW PREP — 25: Performance Optimization  ✅ SOLUTIONS
-- ============================================================
USE perf_db;

-- Q1. Fix: function wrapping indexed column.
-- SLOW: MONTH() and YEAR() prevent index usage on order_date.
-- FIX: Use a range instead — the index IS used:
SELECT * FROM big_orders
WHERE order_date >= '2023-06-01' AND order_date < '2023-07-01';
EXPLAIN SELECT * FROM big_orders WHERE order_date >= '2023-06-01' AND order_date < '2023-07-01';
-- Rule: Never apply functions to indexed columns in WHERE. Use range predicates.

-- Q2. Fix: implicit type conversion.
-- SLOW: '501' is a VARCHAR — MySQL must cast cust_id (INT) for every row.
-- FIX: pass the correct type:
SELECT * FROM big_orders WHERE cust_id = 501;
-- Rule: always match the data type of the column in WHERE predicates.

-- Q3. Fix: SELECT * with covering index.
-- Only fetch needed columns + add a covering index:
CREATE INDEX idx_delivered_cover ON big_orders(status, order_date, order_id, cust_id, amount);

SELECT order_id, cust_id, amount, order_date
FROM big_orders
WHERE status = 'delivered'
ORDER BY order_date DESC
LIMIT 100;

EXPLAIN SELECT order_id, cust_id, amount, order_date
FROM big_orders WHERE status='delivered' ORDER BY order_date DESC LIMIT 100;
-- Look for "Using index" in Extra — all data served from index, no row lookup.

-- Q4. Fix: NOT IN → NOT EXISTS.
-- NOT IN with NULLs: if big_orders.cust_id has even one NULL, NOT IN returns NO rows.
-- NOT EXISTS is NULL-safe:
SELECT * FROM big_customers c
WHERE NOT EXISTS (
    SELECT 1 FROM big_orders o WHERE o.cust_id = c.cust_id
);
-- Also safer and often faster: the EXISTS stops as soon as one match is found.

-- Q5. Fix: correlated subquery → JOIN + pre-aggregation.
-- SLOW: subquery runs ONCE PER ROW in big_orders.
-- FIX: compute averages once with a JOIN:
WITH cust_avgs AS (
    SELECT cust_id, AVG(amount) AS cust_avg
    FROM big_orders
    GROUP BY cust_id
)
SELECT o.order_id, a.cust_avg
FROM big_orders o
JOIN cust_avgs a ON o.cust_id = a.cust_id
LIMIT 1000;
-- Rule: replace correlated subqueries in SELECT with a pre-aggregated JOIN.

-- Q6. Fix: leading wildcard LIKE.
-- B-Tree index is sorted from left to right — '%something' means no usable prefix.
-- Options:
-- A) Store domain separately and index that column.
-- B) Use FULLTEXT index (for natural language search).
-- C) REVERSE the email and index the reversed column — then search LIKE 'moc.elpmaxe@%':
-- ALTER TABLE big_customers ADD COLUMN email_rev VARCHAR(150) AS (REVERSE(email)) STORED;
-- CREATE INDEX idx_email_rev ON big_customers(email_rev);
-- SELECT * FROM big_customers WHERE email_rev LIKE REVERSE('%@example.com');

-- D) Use a generated column for domain:
ALTER TABLE big_customers
    ADD COLUMN email_domain VARCHAR(100) AS (SUBSTRING_INDEX(email,'@',-1)) STORED;
CREATE INDEX idx_email_domain ON big_customers(email_domain);
SELECT * FROM big_customers WHERE email_domain = 'example.com';

-- Q7. Fix: OR → UNION (allows each branch to use its own index).
CREATE INDEX idx_status ON big_orders(status);
CREATE INDEX idx_region ON big_orders(region);

-- SLOW (single scan, may not use indexes):
-- SELECT * FROM big_orders WHERE status='delivered' OR region='North';

-- FAST (each branch uses its own index):
SELECT * FROM big_orders WHERE status = 'delivered'
UNION
SELECT * FROM big_orders WHERE region = 'North';
EXPLAIN SELECT * FROM big_orders WHERE status='delivered'
UNION SELECT * FROM big_orders WHERE region='North';

-- Q8. Force a specific index.
EXPLAIN SELECT * FROM big_orders WHERE status='delivered' AND channel='web';

-- Force index:
SELECT * FROM big_orders
USE INDEX (idx_status_channel_date)
WHERE status = 'delivered' AND channel = 'web';

-- Ignore a bad index:
SELECT * FROM big_orders
IGNORE INDEX (idx_amount)
WHERE status = 'delivered';

-- Q9. Partitioning by year.
CREATE TABLE big_orders_partitioned (
    order_id    BIGINT NOT NULL,
    cust_id     INT    NOT NULL,
    prod_id     INT    NOT NULL,
    order_date  DATE   NOT NULL,
    status      VARCHAR(20),
    amount      DECIMAL(10,2),
    qty         SMALLINT,
    channel     VARCHAR(30),
    region      VARCHAR(50),
    PRIMARY KEY (order_id, order_date)  -- partition key must be in PK
)
PARTITION BY RANGE (YEAR(order_date)) (
    PARTITION p2021 VALUES LESS THAN (2022),
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION pfuture VALUES LESS THAN MAXVALUE
);

-- Benefits:
-- ✔ Queries filtering by year only scan the relevant partition (partition pruning).
-- ✔ Archiving old data: DROP PARTITION p2021 (instant, no row-by-row delete).
-- ✔ Maintenance: REBUILD/ANALYZE only one partition.
-- Check partition usage: EXPLAIN PARTITIONS SELECT ...

-- Q10. Query profiling.
SET profiling = 1;
SELECT COUNT(*) FROM big_orders WHERE status = 'delivered';
SHOW PROFILES;
SHOW PROFILE FOR QUERY 1;   -- shows: parsing, optimization, execution breakdown

-- JSON format EXPLAIN for detailed plan:
EXPLAIN FORMAT=JSON
SELECT order_id, amount FROM big_orders WHERE status='delivered' AND channel='web' LIMIT 10;
-- Look for: cost_info, used_key_parts, rows_examined_per_scan

-- Q11. Index merge demonstration.
EXPLAIN SELECT * FROM big_orders
WHERE status = 'delivered' OR region = 'North';
-- If MySQL uses both idx_status and idx_region → Extra shows: "Using union(idx_status,idx_region); Using where"
-- This is an "index merge" — MySQL merges results from two indexes.
-- Not always faster than UNION approach — depends on cardinality.

-- Q12. EXPLAIN reference + theory
/*
(a) EXPLAIN KEY COLUMNS:
    type       : Access method — best to worst:
                 system > const > eq_ref > ref > range > index > ALL
                 'ALL' = full table scan = BAD.
    key        : Index actually used. NULL = no index.
    key_len    : Bytes of index used. Longer = more columns used.
    rows       : Estimated rows MySQL will examine (lower = better).
    filtered   : % of rows that pass the WHERE condition (estimate).
    Extra      : Additional info:
                 'Using index'     → Covering index (no row lookup).
                 'Using filesort'  → Extra sort pass required.
                 'Using temporary' → Temp table needed (GROUP BY/ORDER BY).
                 'Using where'     → Filter applied after index.

(b) FILESORT vs USING INDEX:
    "Using filesort" = MySQL must sort data in a temp buffer (bad for large sets).
                       Fix: add an index that includes the ORDER BY column.
    "Using index"    = Sort is done via the index (which is already sorted) = fast.

(c) COMPOSITE vs MULTIPLE SINGLE-COLUMN INDEXES:
    Composite (a,b,c): used for queries filtering on a, a+b, or a+b+c (left prefix rule).
                       Also handles ORDER BY if columns match.
    Multiple singles: each index is separate; MySQL may use index merge but usually slower.
    Rule: create composite indexes matching your most common query patterns (ESR rule:
          Equality cols first, then Sort col, then Range col).

(d) COVERING INDEX:
    An index that contains ALL columns referenced in a SELECT query.
    MySQL can answer the query entirely from the index — no row lookup needed.
    Shown as "Using index" in EXPLAIN Extra.
    Most impactful optimization for read-heavy workloads.
    Create: INDEX(col_in_WHERE, col_in_SELECT_1, col_in_SELECT_2).

(e) QUERY CACHE (deprecated in MySQL 8.0, removed in 8.0.3):
    MySQL used to cache exact SQL text → result set pairs.
    Problem: every write to a table invalidated ALL cached queries for that table.
    At high write rates: cache became a bottleneck (lock contention).
    Replaced by: InnoDB buffer pool, application-level caching (Redis/Memcached).

(f) INNODB BUFFER POOL:
    In-memory cache for InnoDB data pages and index pages.
    Size controlled by: innodb_buffer_pool_size (default 128MB; set to 70-80% of RAM).
    How it helps: keeps frequently-accessed data in RAM → avoids disk I/O.
    Monitor: SHOW STATUS LIKE 'Innodb_buffer_pool_read%';
    High Innodb_buffer_pool_reads_request → most reads served from memory = good.
    High Innodb_buffer_pool_reads → disk reads → buffer pool too small.
*/
