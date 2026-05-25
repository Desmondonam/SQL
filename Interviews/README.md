# 🎯 SQL Interview Preparation — Complete Study Pack

> **50 files · 25 topics · Beginner → Expert · Pure MySQL**
> Each folder = one topic, with a `practice.sql` (you solve) and `solution.sql` (check your work).

---

## 📁 Folder Structure

| # | Folder | Topic | Level | Key Dataset |
|---|--------|-------|-------|-------------|
| 01 | `01_Basic_SELECT` | SELECT, aliases, computed cols, CASE | 🟢 Beginner | Netflix titles (Kaggle-inspired) |
| 02 | `02_Filtering_WHERE` | WHERE, AND/OR, IN, BETWEEN, LIKE, IS NULL | 🟢 Beginner | Olist E-Commerce (Kaggle-inspired) |
| 03 | `03_Sorting_Limiting` | ORDER BY, LIMIT, OFFSET, pagination | 🟢 Beginner | Stack Overflow Q&A |
| 04 | `04_Aggregate_Functions` | COUNT, SUM, AVG, MIN, MAX, COUNT DISTINCT | 🟡 Intermediate | HR/Employee dataset |
| 05 | `05_GROUP_BY_HAVING` | GROUP BY, HAVING, conditional aggregation | 🟡 Intermediate | Sales by region |
| 06 | `06_JOINS` | INNER, LEFT, RIGHT, SELF, CROSS JOIN | 🟡 Intermediate | Northwind (classic) |
| 07 | `07_Subqueries` | Scalar, correlated, EXISTS, ALL, ANY | 🟡 Intermediate | HR + E-Commerce |
| 08 | `08_Window_Functions` | ROW_NUMBER, RANK, LAG, LEAD, running totals | 🔴 Advanced | Sales performance |
| 09 | `09_CTEs` | WITH, multiple CTEs, recursive CTEs | 🔴 Advanced | GitHub repos (GH Archive) |
| 10 | `10_Transactions` | BEGIN, COMMIT, ROLLBACK, SAVEPOINT, ACID | 🟡 Intermediate | Banking system |
| 11 | `11_Indexes_Performance` | CREATE INDEX, EXPLAIN, covering index | 🔴 Advanced | Large orders table |
| 12 | `12_Stored_Procedures` | IN/OUT params, cursors, loops, SIGNAL | 🔴 Advanced | HR database |
| 13 | `13_Views` | CREATE VIEW, updatable views, WITH CHECK | 🟡 Intermediate | E-Commerce + HR |
| 14 | `14_Triggers` | BEFORE/AFTER INSERT/UPDATE/DELETE | 🔴 Advanced | Inventory audit |
| 15 | `15_String_Functions` | CONCAT, SUBSTRING, REGEXP_REPLACE, SOUNDEX | 🟡 Intermediate | Customer contacts |
| 16 | `16_Date_Time_Functions` | DATE_FORMAT, DATEDIFF, TIMESTAMPDIFF, DATE_ADD | 🟡 Intermediate | SaaS subscriptions |
| 17 | `17_CASE_Statements` | Simple/searched CASE, pivot, ORDER BY CASE | 🟡 Intermediate | Sales + HR |
| 18 | `18_Set_Operations` | UNION, UNION ALL, INTERSECT, EXCEPT | 🟡 Intermediate | Multi-region catalogs |
| 19 | `19_Data_Manipulation` | INSERT, UPDATE, DELETE, UPSERT, TRUNCATE | 🟢 Beginner+ | Product inventory |
| 20 | `20_Advanced_Analytics` | Funnel, cohort, RFM, retention, YoY | 🔵 Expert | E-Commerce analytics |
| 21 | `21_Database_Design` | Normalization (1NF/2NF/3NF), ERD → SQL | 🔵 Expert | Social media platform |
| 22 | `22_Recursive_Queries` | WITH RECURSIVE, org hierarchy, BOM | 🔵 Expert | Org tree + Manufacturing |
| 23 | `23_JSON_Functions` | JSON_EXTRACT, JSON_TABLE, JSON_ARRAYAGG | 🔴 Advanced | API logs + attributes |
| 24 | `24_Error_Handling` | DECLARE HANDLER, SIGNAL, RESIGNAL | 🔴 Advanced | Banking transfers |
| 25 | `25_Performance_Optimization` | EXPLAIN, index tuning, partitioning | 🔵 Expert | Large-scale orders |

---

## 🚀 How to Use This Pack

### Step 1 — Set up MySQL
Make sure you have MySQL 8.0+ running locally. Each practice file includes the full
`CREATE DATABASE`, `CREATE TABLE`, and `INSERT` statements — just run and go.

### Step 2 — Work through each topic
1. Open `practice.sql` — read the setup block and run it first.
2. Read each question (Q1, Q2, …).
3. Write your SQL answer below the question comment.
4. Run it and verify results.
5. When stuck or done — open `solution.sql` to compare.

### Step 3 — Study the KEY TAKEAWAYS
Every `solution.sql` ends with a `-- ── KEY TAKEAWAYS ──` block summarizing
the most important concepts. Review these even if you got the answer right.

---

## 📚 Data Sources & Inspiration

| Dataset | Source |
|---------|--------|
| Netflix Movies & TV Shows | [Kaggle](https://www.kaggle.com/datasets/shivamb/netflix-shows) |
| Brazilian E-Commerce (Olist) | [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) |
| Stack Overflow | [Stack Exchange Data Explorer](https://data.stackexchange.com/) |
| HR Analytics | [Kaggle](https://www.kaggle.com/datasets/rhuebner/human-resources-data-set) |
| Northwind Database | [GitHub – Microsoft SQL Samples](https://github.com/Microsoft/sql-server-samples) |
| GH Archive (GitHub events) | [gharchive.org](https://www.gharchive.org/) |
| Oracle HR Schema | Oracle sample schemas |

All data in these files is **synthetic/inspired** — safe to use for practice.

---

## 🎓 Recommended Study Path

### Week 1 — Foundations
- `01` Basic SELECT
- `02` Filtering
- `03` Sorting & Limiting
- `04` Aggregates
- `05` GROUP BY & HAVING

### Week 2 — Core SQL
- `06` JOINs ← **most tested topic**
- `07` Subqueries
- `17` CASE Statements
- `18` Set Operations
- `19` Data Manipulation

### Week 3 — Advanced
- `08` Window Functions ← **#1 FAANG topic**
- `09` CTEs
- `15` String Functions
- `16` Date & Time Functions
- `16` Views & Triggers

### Week 4 — Expert Level
- `10` Transactions & ACID
- `11` Indexes & Performance
- `20` Advanced Analytics
- `21` Database Design
- `22` Recursive Queries
- `25` Performance Optimization

---

## 💡 Common Interview Question Types

### 🟢 Beginner (Junior roles)
- Write a query to find the top N records
- Filter rows based on multiple conditions
- Count/sum/average across groups

### 🟡 Intermediate (Mid-level roles)
- Multi-table JOINs with aggregation
- Find records that exist in one table but not another
- Write date-based filtering and calculations

### 🔴 Advanced (Senior roles)
- Window functions: ranking, running totals, lag/lead
- CTEs for multi-step data transformations
- Optimize a slow query using EXPLAIN + indexing
- Stored procedures with error handling

### 🔵 Expert (Staff/Principal roles)
- Design a normalized schema from business requirements
- Recursive hierarchy traversal (org chart, BOM)
- Cohort analysis, retention, funnel analytics
- Partitioning strategy for large tables
- Transaction isolation levels and deadlock prevention

---

## ⚡ Quick Reference Cheat Sheet

```sql
-- ── Ranking ──────────────────────────────────────────────
ROW_NUMBER() OVER (PARTITION BY dept ORDER BY salary DESC)
RANK()        OVER (...)   -- gaps on ties
DENSE_RANK()  OVER (...)   -- no gaps

-- ── Running Total ─────────────────────────────────────────
SUM(amount) OVER (ORDER BY date ROWS UNBOUNDED PRECEDING)

-- ── Previous/Next Row ─────────────────────────────────────
LAG(col, 1) OVER (PARTITION BY group ORDER BY date)
LEAD(col, 1) OVER (...)

-- ── Moving Average ────────────────────────────────────────
AVG(col) OVER (ORDER BY date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)

-- ── Anti-Join (NOT IN alternative) ───────────────────────
SELECT * FROM a LEFT JOIN b ON a.id = b.id WHERE b.id IS NULL

-- ── UPSERT ────────────────────────────────────────────────
INSERT INTO t (id, val) VALUES (1, 'x')
ON DUPLICATE KEY UPDATE val = VALUES(val);

-- ── Pivot (conditional aggregation) ──────────────────────
SUM(CASE WHEN category = 'A' THEN amount ELSE 0 END) AS cat_a

-- ── Date Range ────────────────────────────────────────────
WHERE date BETWEEN '2023-01-01' AND '2023-12-31'
WHERE date >= '2023-01-01' AND date < '2024-01-01'  -- preferred

-- ── Recursive CTE ─────────────────────────────────────────
WITH RECURSIVE cte AS (
  SELECT id, 1 AS lvl FROM t WHERE parent IS NULL  -- anchor
  UNION ALL
  SELECT t.id, cte.lvl+1 FROM t JOIN cte ON t.parent = cte.id  -- step
)
SELECT * FROM cte;
```

---

## 🏆 Top 10 Most-Asked SQL Interview Questions

1. **Find the Nth highest salary** (subquery / DENSE_RANK)
2. **Find duplicate records** (GROUP BY HAVING COUNT > 1)
3. **Delete duplicates, keep one** (CTE + ROW_NUMBER)
4. **Find employees earning above department average** (correlated subquery / window)
5. **Running total of sales** (SUM OVER)
6. **First and last purchase per customer** (FIRST_VALUE / MIN-MAX + ROW_NUMBER)
7. **Month-over-month growth %** (LAG + division)
8. **Customers who never ordered** (LEFT JOIN + IS NULL / NOT EXISTS)
9. **Hierarchical data traversal** (WITH RECURSIVE)
10. **Pivot rows to columns** (CASE inside SUM GROUP BY)

All 10 of these are covered in this study pack. Good luck! 🚀

---

*Generated for SQL interview preparation. All datasets are synthetic/inspired by real public datasets.*
