-- ============================================================
--  SQL INTERVIEW PREP — 19: Data Manipulation (DML)
--  Level     : Beginner → Advanced
--  Dataset   : Inventory + Product management
--  Covers    : INSERT, UPDATE, DELETE, UPSERT, TRUNCATE, MERGE
-- ============================================================

CREATE DATABASE IF NOT EXISTS dml_db;
USE dml_db;

DROP TABLE IF EXISTS price_history;
DROP TABLE IF EXISTS products_dml;
DROP TABLE IF EXISTS categories_dml;
DROP TABLE IF EXISTS staging_products;

CREATE TABLE categories_dml (
    cat_id    INT PRIMARY KEY AUTO_INCREMENT,
    cat_name  VARCHAR(80) UNIQUE NOT NULL
);

CREATE TABLE products_dml (
    prod_id      INT PRIMARY KEY AUTO_INCREMENT,
    sku          VARCHAR(30) UNIQUE NOT NULL,
    product_name VARCHAR(150) NOT NULL,
    cat_id       INT,
    price        DECIMAL(10,2) NOT NULL,
    stock        INT DEFAULT 0,
    is_active    BOOLEAN DEFAULT TRUE,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (cat_id) REFERENCES categories_dml(cat_id)
) ENGINE=InnoDB;

CREATE TABLE price_history (
    hist_id   INT PRIMARY KEY AUTO_INCREMENT,
    prod_id   INT,
    old_price DECIMAL(10,2),
    new_price DECIMAL(10,2),
    changed_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Staging table for bulk import simulation
CREATE TABLE staging_products (
    sku          VARCHAR(30),
    product_name VARCHAR(150),
    cat_name     VARCHAR(80),
    price        DECIMAL(10,2),
    stock        INT
);

-- ─────────────────────────────────────────────────────────────
--  TASKS
-- ─────────────────────────────────────────────────────────────

-- Q1. [EASY] Insert a single category: 'Electronics'.
--     Then insert 3 more: 'Clothing', 'Books', 'Sports'.



-- Q2. [EASY] Insert multiple products in a single INSERT statement
--     (use multi-row INSERT VALUES syntax). Add at least 5 products.



-- Q3. [EASY] Update the price of product with SKU = 'SKU-001' to 1099.99.



-- Q4. [EASY] Delete a product by SKU = 'SKU-005' (soft delete preferred —
--     set is_active = FALSE instead of hard delete).



-- Q5. [MEDIUM] Bulk insert from staging:
--     First insert staging data, then INSERT INTO products_dml … SELECT from staging.
--     Staging data:
--     ('SKU-010','Wireless Mouse','Electronics',29.99,150)
--     ('SKU-011','Python Cookbook','Books',39.99,80)
--     ('SKU-012','Running Shoes','Sports',89.99,60)
--     Resolve cat_id by joining staging with categories_dml.



-- Q6. [MEDIUM] UPDATE with JOIN:
--     Increase price by 10% for all products in the 'Electronics' category.
--     Use UPDATE … JOIN syntax.



-- Q7. [MEDIUM] Conditional UPDATE using CASE:
--     Apply discounts based on stock level:
--     stock > 100 → reduce price by 15%
--     stock 50-100 → reduce price by 5%
--     stock < 50  → no change



-- Q8. [MEDIUM] DELETE with a subquery:
--     Delete all products in the 'Sports' category that have stock = 0.



-- Q9. [HARD] UPSERT (INSERT … ON DUPLICATE KEY UPDATE):
--     Try to insert a product with SKU='SKU-001'. If it already exists,
--     update its price and stock instead.



-- Q10. [HARD] REPLACE INTO:
--      Insert or completely replace a product row by SKU.
--      What is the difference between REPLACE and INSERT … ON DUPLICATE KEY UPDATE?



-- Q11. [HARD] Log price changes automatically when price is updated.
--      (Without a trigger — do it in a single transaction with two statements.)
--      Update SKU-002's price to 899.99 and log the change.



-- Q12. [HARD] Soft-delete vs Hard-delete:
--      (a) Hard-delete all inactive products (is_active = FALSE).
--      (b) Before deleting, INSERT them into a products_archive table.
--      Create products_archive and move the data.



-- Q13. [EXPERT] UPDATE with window function context:
--      For the top 3 most expensive products in each category,
--      apply a 20% premium price increase.
--      (Hint: Use a subquery with RANK to identify them, then UPDATE.)



-- Q14. [EXPERT] TRUNCATE vs DELETE:
--      (a) Show the difference in SQL.
--      (b) Explain: when does TRUNCATE reset AUTO_INCREMENT? Does DELETE?
--      (c) Can TRUNCATE be rolled back?
--      Write the commands and explain in comments.



-- Q15. [EXPERT] Batch UPDATE with LIMIT:
--      MySQL supports UPDATE … LIMIT n.
--      Update stock = stock + 10 for the 5 cheapest products.
--      Use ORDER BY price ASC LIMIT 5 in the UPDATE.
