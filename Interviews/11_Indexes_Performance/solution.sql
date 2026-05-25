-- ============================================================
--  SQL INTERVIEW PREP — 11: Indexes & Performance  ✅ SOLUTIONS
-- ============================================================
USE perf_db;

-- Q1. EXPLAIN before index.
EXPLAIN SELECT * FROM big_orders WHERE order_date = '2023-06-15';
-- Expected: type = ALL (full table scan), key = NULL (no index used).

-- Q2. Create index on order_date, re-explain.
CREATE INDEX idx_order_date ON big_orders(order_date);
EXPLAIN SELECT * FROM big_orders WHERE order_date = '2023-06-15';
-- Now: type = ref or range, key = idx_order_date. MUCH faster.

-- Q3. Composite index on (status, order_date).
CREATE INDEX idx_status_date ON big_orders(status, order_date);
EXPLAIN SELECT * FROM big_orders
WHERE status = 'delivered' AND order_date BETWEEN '2023-01-01' AND '2023-12-31';
-- key_len shows how many bytes of the index were used.
-- Both columns used → key_len covers both.

-- Q4. Show all indexes.
SHOW INDEX FROM big_orders;
/*
  Columns explained:
  Table      : table name
  Key_name   : index name (PRIMARY, idx_order_date, etc.)
  Seq_in_index: column position in composite index
  Column_name: which column is indexed
  Non_unique : 0 = unique index, 1 = allows duplicates
  Cardinality: estimated distinct values (higher = more selective)
  Index_type : BTREE (default), FULLTEXT, HASH
*/

-- Q5. Covering index — all query columns inside the index.
CREATE INDEX idx_covering_region ON big_orders(region, cust_id, amount);
EXPLAIN SELECT cust_id, amount FROM big_orders WHERE region = 'North';
-- Extra column shows: "Using index" → data fetched entirely from index.
-- No need to read the main table rows — very fast!

-- Q6. Function on column kills index usage.
EXPLAIN SELECT * FROM big_orders WHERE YEAR(order_date) = 2023;
-- type = ALL (full scan) — MySQL can't use index because YEAR() wraps the column.

-- FIX: Use a range instead:
EXPLAIN SELECT * FROM big_orders
WHERE order_date BETWEEN '2023-01-01' AND '2023-12-31';
-- Now uses idx_order_date. Rule: never wrap indexed columns in functions in WHERE.

-- Q7. Optimal composite index for filtered + sorted + limited query.
DROP INDEX idx_order_date  ON big_orders;
DROP INDEX idx_status_date ON big_orders;
DROP INDEX idx_covering_region ON big_orders;

-- Best index: (status, channel, order_date) — filter on status+channel, sort on date.
CREATE INDEX idx_status_channel_date ON big_orders(status, channel, order_date);
EXPLAIN SELECT * FROM big_orders
WHERE status = 'delivered' AND channel = 'web'
ORDER BY order_date DESC
LIMIT 50;
-- MySQL uses index for filtering AND sorting — avoids filesort.

-- Q8. Force a full table scan, then fix it.
-- Full scan query (no index on amount):
EXPLAIN SELECT * FROM big_orders WHERE amount > 900;
-- type = ALL (if amount is not indexed)

-- Fix:
CREATE INDEX idx_amount ON big_orders(amount);
EXPLAIN SELECT * FROM big_orders WHERE amount > 900;
-- Now type = range, uses idx_amount.

-- Q9. Leading wildcard cannot use B-Tree index.
EXPLAIN SELECT * FROM big_customers WHERE email LIKE '%@example.com';
-- type = ALL — B-Tree cannot search with a leading %.
-- To search by domain you'd need a FULLTEXT index or store the domain separately.
-- FULLTEXT alternative:
-- ALTER TABLE big_customers ADD FULLTEXT idx_ft_email (email);
-- SELECT * FROM big_customers WHERE MATCH(email) AGAINST('@example.com');

-- Q10. Unique composite index prevents duplicate orders.
CREATE UNIQUE INDEX uix_cust_prod_date ON big_orders(cust_id, prod_id, order_date);

-- Try inserting a duplicate (will fail):
-- INSERT INTO big_orders (cust_id, prod_id, order_date, status, amount, qty, channel, region)
-- SELECT cust_id, prod_id, order_date, 'pending', 99.99, 1, 'web', 'North'
-- FROM big_orders LIMIT 1;
-- ERROR 1062: Duplicate entry for key 'uix_cust_prod_date'

-- Q11. Theory deep-dive
/*
  ════════════════════════════════════════════════════════
  (a) B-TREE INDEX STRUCTURE
  ════════════════════════════════════════════════════════
  MySQL InnoDB uses B+Tree (Balanced+ Tree) indexes.
  - Tree structure with sorted keys at leaf nodes.
  - Leaf nodes contain either: the full row (clustered) or a pointer to it.
  - Tree depth is log(N) — finding any row takes O(log N) time.
  - Range queries walk adjacent leaf nodes — efficient for BETWEEN, <, >.
  - Equality queries = tree traversal from root to leaf = O(log N).

  ════════════════════════════════════════════════════════
  (b) WHEN NOT TO USE AN INDEX
  ════════════════════════════════════════════════════════
  1. Low cardinality columns: status (4 values), gender (2 values).
     MySQL may ignore the index and scan if > 10-30% rows match.
  2. Small tables (< a few hundred rows): full scan is faster.
  3. Columns rarely used in WHERE/JOIN/ORDER BY.
  4. Very frequent INSERT/UPDATE/DELETE tables: each write updates all indexes.
  5. When function is applied to indexed column in WHERE (kills usage).

  ════════════════════════════════════════════════════════
  (c) CLUSTERED vs NON-CLUSTERED INDEX
  ════════════════════════════════════════════════════════
  Clustered (InnoDB PRIMARY KEY):
  - The table data IS the index; rows stored in PK order.
  - Only ONE clustered index per table.
  - Range scans on PK are extremely fast (data is physically contiguous).

  Non-clustered (Secondary Index):
  - Separate structure storing: indexed columns + PK value.
  - Looking up non-indexed columns requires a "table lookup" via PK.
  - Covering index avoids the second lookup by storing all needed columns.

  ════════════════════════════════════════════════════════
  (d) INDEX SELECTIVITY
  ════════════════════════════════════════════════════════
  Selectivity = COUNT(DISTINCT col) / COUNT(*) — range [0, 1].
  - Selectivity near 1 (e.g., email, UUID) → highly selective → great for indexing.
  - Selectivity near 0 (e.g., boolean, status with few values) → poor for indexing.
  - MySQL's query optimizer uses cardinality estimates to decide whether to use an index.
  - Rule of thumb: index columns used in JOIN ON, WHERE equality/range, ORDER BY.
  - Check selectivity: SELECT COUNT(DISTINCT col)/COUNT(*) FROM table;
*/
