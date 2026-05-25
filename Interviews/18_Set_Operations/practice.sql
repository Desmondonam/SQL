-- ============================================================
--  SQL INTERVIEW PREP — 18: Set Operations
--  Level     : Intermediate → Advanced
--  Dataset   : Multi-region sales & product catalog
--  Covers    : UNION, UNION ALL, INTERSECT (via JOIN), EXCEPT (via NOT IN/LEFT JOIN)
--  Note      : MySQL supports UNION/UNION ALL natively.
--              INTERSECT and EXCEPT are MySQL 8.0.31+ supported.
-- ============================================================

CREATE DATABASE IF NOT EXISTS sets_db;
USE sets_db;

DROP TABLE IF EXISTS sales_q1;
DROP TABLE IF EXISTS sales_q2;
DROP TABLE IF EXISTS sales_q3;
DROP TABLE IF EXISTS catalog_global;
DROP TABLE IF EXISTS catalog_us;
DROP TABLE IF EXISTS catalog_eu;

-- Quarterly sales (same structure — great for UNION)
CREATE TABLE sales_q1 (
    sale_id     INT PRIMARY KEY,
    customer    VARCHAR(80),
    product_cat VARCHAR(50),
    region      VARCHAR(30),
    amount      DECIMAL(10,2),
    sale_date   DATE
);

CREATE TABLE sales_q2 LIKE sales_q1;
CREATE TABLE sales_q3 LIKE sales_q1;

INSERT INTO sales_q1 VALUES
 (1,'Alice','Electronics','North',8500,'2023-01-15'),
 (2,'Bob',  'Clothing',   'South',3200,'2023-01-22'),
 (3,'Carol','Books',      'East', 1100,'2023-02-05'),
 (4,'Dave', 'Electronics','West', 6700,'2023-02-18'),
 (5,'Eve',  'Clothing',   'North',4800,'2023-03-10');

INSERT INTO sales_q2 VALUES
 (6, 'Alice','Clothing',   'North',2900,'2023-04-05'),
 (7, 'Frank','Electronics','South',9200,'2023-04-18'),
 (8, 'Bob',  'Books',      'South',1800,'2023-05-02'),
 (9, 'Carol','Electronics','East', 7500,'2023-05-20'),
 (10,'Grace','Clothing',   'West', 5100,'2023-06-11');

INSERT INTO sales_q3 VALUES
 (11,'Dave', 'Books',      'West',  950,'2023-07-08'),
 (12,'Alice','Electronics','North',11000,'2023-07-22'),
 (13,'Frank','Clothing',   'South', 4200,'2023-08-05'),
 (14,'Bob',  'Electronics','East',  8800,'2023-08-19'),
 (15,'Eve',  'Books',      'West',  1300,'2023-09-12');

-- Product catalogs (different regional availability)
CREATE TABLE catalog_us (product_sku VARCHAR(20), product_name VARCHAR(100), price_usd DECIMAL(10,2));
CREATE TABLE catalog_eu (product_sku VARCHAR(20), product_name VARCHAR(100), price_eur DECIMAL(10,2));

INSERT INTO catalog_us VALUES
 ('SKU-001','iPhone 15',        999.00),('SKU-002','Galaxy S24',     849.00),
 ('SKU-003','MacBook Pro 14',  1999.00),('SKU-004','Dell XPS 15',   1799.00),
 ('SKU-005','AirPods Pro',      249.00),('SKU-006','Logitech MX',     99.00),
 ('SKU-007','US Exclusive Model',599.00),('SKU-008','Kindle Scribe',  340.00);

INSERT INTO catalog_eu VALUES
 ('SKU-001','iPhone 15',        949.00),('SKU-002','Galaxy S24',     799.00),
 ('SKU-003','MacBook Pro 14',  2199.00),('SKU-004','Dell XPS 15',   1699.00),
 ('SKU-005','AirPods Pro',      279.00),('SKU-009','EU Exclusive Model',449.00),
 ('SKU-010','Kindle Paperwhite',149.00),('SKU-011','Sony WH-1000XM5', 349.00);

-- ─────────────────────────────────────────────────────────────
--  TASKS
-- ─────────────────────────────────────────────────────────────

-- Q1. [EASY] UNION: Combine all sales from Q1, Q2, and Q3 into one result set.
--     Remove duplicates (though there are none here since sale_ids differ).



-- Q2. [EASY] UNION ALL: Combine all three quarters. Explain when to use
--     UNION ALL vs UNION.



-- Q3. [MEDIUM] UNION with aggregation: Show total sales per region
--     combining all three quarters. Use UNION ALL inside a subquery.



-- Q4. [MEDIUM] Get all UNIQUE customers who bought in Q1 OR Q2
--     (appear in either table). Use UNION.



-- Q5. [MEDIUM] INTERSECT (MySQL 8.0.31+): Find SKUs available in BOTH
--     catalog_us AND catalog_eu.
--     Alternative: Use INNER JOIN if your MySQL is older.



-- Q6. [MEDIUM] EXCEPT (MySQL 8.0.31+): Find SKUs in catalog_us but NOT in catalog_eu.
--     Alternative: LEFT JOIN + IS NULL pattern.



-- Q7. [MEDIUM] Find SKUs in catalog_eu but NOT in catalog_us.
--     (Set difference in the opposite direction.)



-- Q8. [HARD] Show each customer's total spend across ALL quarters combined.
--     Use UNION ALL + GROUP BY in a derived table.



-- Q9. [HARD] Customers who appear in ALL THREE quarters (Q1 AND Q2 AND Q3).
--     Use INTERSECT (or triple INNER JOIN on customer name).



-- Q10. [HARD] Find customers who bought in Q1 but NOT in Q3 (lapsed customers).
--      Use EXCEPT or NOT IN / NOT EXISTS approach.



-- Q11. [EXPERT] Write a query that shows the symmetric difference:
--      SKUs that are in catalog_us OR catalog_eu but NOT in BOTH.
--      (US-only + EU-only, excluding shared SKUs.)
--      Show product_sku, product_name, and which catalog it belongs to.



-- Q12. [EXPERT] UNION with different column counts: pad with NULL or literal values.
--      Combine: all Q1 sales (show quarter='Q1')
--              all Q2 sales (show quarter='Q2')
--              A summary row: customer='ALL', amount=total across all, quarter='TOTAL'
