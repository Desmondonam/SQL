-- ============================================================
--  SQL INTERVIEW PREP — 11: Indexes & Query Performance
--  Level     : Advanced
--  Dataset   : Large-scale e-commerce orders (simulated)
--  Tools     : EXPLAIN, SHOW INDEX, CREATE INDEX
-- ============================================================

CREATE DATABASE IF NOT EXISTS perf_db;
USE perf_db;

-- ── Setup: Large-ish dataset for meaningful index demos ──
DROP TABLE IF EXISTS big_orders;
DROP TABLE IF EXISTS big_customers;
DROP TABLE IF EXISTS big_products;

CREATE TABLE big_customers (
    cust_id    INT PRIMARY KEY AUTO_INCREMENT,
    email      VARCHAR(150) UNIQUE,
    name       VARCHAR(100),
    city       VARCHAR(80),
    country    VARCHAR(50),
    tier       VARCHAR(20)    -- bronze, silver, gold, platinum
) ENGINE=InnoDB;

CREATE TABLE big_products (
    prod_id    INT PRIMARY KEY AUTO_INCREMENT,
    sku        VARCHAR(30) UNIQUE,
    name       VARCHAR(150),
    category   VARCHAR(80),
    price      DECIMAL(10,2),
    brand      VARCHAR(80)
) ENGINE=InnoDB;

CREATE TABLE big_orders (
    order_id     BIGINT PRIMARY KEY AUTO_INCREMENT,
    cust_id      INT NOT NULL,
    prod_id      INT NOT NULL,
    order_date   DATE NOT NULL,
    status       VARCHAR(20),   -- pending, shipped, delivered, returned
    amount       DECIMAL(10,2),
    qty          SMALLINT,
    channel      VARCHAR(30),   -- web, mobile, store
    region       VARCHAR(50),
    FOREIGN KEY (cust_id) REFERENCES big_customers(cust_id),
    FOREIGN KEY (prod_id) REFERENCES big_products(prod_id)
) ENGINE=InnoDB;

-- Populate with synthetic data using a stored procedure
DELIMITER $$
CREATE PROCEDURE populate_perf_db()
BEGIN
    DECLARE i INT DEFAULT 1;

    -- Customers
    WHILE i <= 1000 DO
        INSERT IGNORE INTO big_customers (email, name, city, country, tier)
        VALUES (
            CONCAT('user',i,'@example.com'),
            CONCAT('Customer ',i),
            ELT(1 + (i MOD 5), 'New York','London','Tokyo','Paris','Sydney'),
            ELT(1 + (i MOD 5), 'USA','UK','Japan','France','Australia'),
            ELT(1 + (i MOD 4), 'bronze','silver','gold','platinum')
        );
        SET i = i + 1;
    END WHILE;

    -- Products
    SET i = 1;
    WHILE i <= 200 DO
        INSERT IGNORE INTO big_products (sku, name, category, price, brand)
        VALUES (
            CONCAT('SKU-',LPAD(i,5,'0')),
            CONCAT('Product ',i),
            ELT(1 + (i MOD 6), 'Electronics','Clothing','Books','Sports','Beauty','Home'),
            ROUND(10 + RAND() * 990, 2),
            ELT(1 + (i MOD 8), 'BrandA','BrandB','BrandC','BrandD','BrandE','BrandF','BrandG','BrandH')
        );
        SET i = i + 1;
    END WHILE;

    -- Orders
    SET i = 1;
    WHILE i <= 10000 DO
        INSERT INTO big_orders (cust_id, prod_id, order_date, status, amount, qty, channel, region)
        VALUES (
            1 + (i MOD 1000),
            1 + (i MOD 200),
            DATE_ADD('2022-01-01', INTERVAL FLOOR(RAND()*730) DAY),
            ELT(1 + (i MOD 4), 'pending','shipped','delivered','returned'),
            ROUND(10 + RAND() * 990, 2),
            1 + FLOOR(RAND() * 5),
            ELT(1 + (i MOD 3), 'web','mobile','store'),
            ELT(1 + (i MOD 5), 'North','South','East','West','Central')
        );
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;

CALL populate_perf_db();
DROP PROCEDURE IF EXISTS populate_perf_db;

-- ─────────────────────────────────────────────────────────────
--  TASKS
-- ─────────────────────────────────────────────────────────────

-- Q1. [EASY] Use EXPLAIN to see how MySQL plans this query.
--     Is it using an index? What is the type column showing?
EXPLAIN SELECT * FROM big_orders WHERE order_date = '2023-06-15';



-- Q2. [EASY] Create a single-column index on big_orders.order_date.
--     Then run EXPLAIN again. What changed?



-- Q3. [MEDIUM] Create a composite index on (status, order_date).
--     Run EXPLAIN on a query that filters by status AND order_date.
--     What does key_len tell you?



-- Q4. [MEDIUM] Show all indexes on big_orders using SHOW INDEX.
--     What information does each column tell you?



-- Q5. [MEDIUM] Create a covering index on big_orders for the query:
--     SELECT cust_id, amount FROM big_orders WHERE region = 'North';
--     A covering index means all needed columns are IN the index.
--     Create it and EXPLAIN the query — look for "Using index" in Extra.



-- Q6. [MEDIUM] Demonstrate a query that CANNOT use an index efficiently:
--     SELECT * FROM big_orders WHERE YEAR(order_date) = 2023;
--     Why? How would you rewrite it to use the index?



-- Q7. [HARD] DROP the indexes you created (keep only PRIMARY KEY).
--     Then create the BEST index to optimise this query:
--     SELECT * FROM big_orders
--     WHERE status = 'delivered' AND channel = 'web'
--     ORDER BY order_date DESC
--     LIMIT 50;
--     Explain your choice.



-- Q8. [HARD] Write and EXPLAIN a query that has a full table scan (type=ALL).
--     Then fix it with an appropriate index.



-- Q9. [HARD] Explain why the following query won't use a prefix index
--     on customer email well — and what index would help:
--     SELECT * FROM big_customers WHERE email LIKE '%@example.com';



-- Q10. [EXPERT] Create a UNIQUE index on (cust_id, prod_id, order_date)
--      to prevent duplicate orders on the same day.
--      What happens when you try to insert a duplicate?



-- Q11. [EXPERT — Theory] Write detailed comments explaining:
--      (a) B-Tree index structure and how range queries use it
--      (b) When NOT to use an index (low cardinality, small tables, etc.)
--      (c) The difference between clustered and non-clustered indexes
--      (d) What "index selectivity" means and why it matters
