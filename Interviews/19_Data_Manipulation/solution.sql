-- ============================================================
--  SQL INTERVIEW PREP — 19: Data Manipulation (DML)  ✅ SOLUTIONS
-- ============================================================
USE dml_db;

-- Q1. Insert categories.
INSERT INTO categories_dml (cat_name) VALUES ('Electronics');
INSERT INTO categories_dml (cat_name) VALUES ('Clothing'),('Books'),('Sports');

-- Q2. Multi-row product INSERT.
INSERT INTO products_dml (sku, product_name, cat_id, price, stock) VALUES
 ('SKU-001','Laptop Pro 15',          1, 1299.99, 25),
 ('SKU-002','Wireless Headphones',    1,  249.99, 80),
 ('SKU-003','Winter Jacket',          2,  189.90, 40),
 ('SKU-004','SQL Mastery Book',       3,   59.90, 150),
 ('SKU-005','Running Shoes',          4,  119.90, 60);

-- Q3. Update price by SKU.
UPDATE products_dml
SET price = 1099.99
WHERE sku = 'SKU-001';

-- Q4. Soft delete (set is_active = FALSE).
UPDATE products_dml SET is_active = FALSE WHERE sku = 'SKU-005';
-- Hard delete would be: DELETE FROM products_dml WHERE sku = 'SKU-005';
-- Always prefer soft delete to preserve history and support recovery.

-- Q5. Bulk insert from staging via SELECT.
INSERT INTO staging_products VALUES
 ('SKU-010','Wireless Mouse',  'Electronics', 29.99,150),
 ('SKU-011','Python Cookbook', 'Books',        39.99, 80),
 ('SKU-012','Running Shoes',   'Sports',       89.99, 60);

INSERT INTO products_dml (sku, product_name, cat_id, price, stock)
SELECT s.sku, s.product_name, c.cat_id, s.price, s.stock
FROM staging_products s
JOIN categories_dml c ON s.cat_name = c.cat_name
WHERE s.sku NOT IN (SELECT sku FROM products_dml);  -- avoid duplicates

-- Q6. UPDATE with JOIN — 10% price increase for Electronics.
UPDATE products_dml p
JOIN categories_dml c ON p.cat_id = c.cat_id
SET p.price = ROUND(p.price * 1.10, 2)
WHERE c.cat_name = 'Electronics';

-- Q7. Conditional UPDATE using CASE.
UPDATE products_dml
SET price = CASE
    WHEN stock > 100 THEN ROUND(price * 0.85, 2)
    WHEN stock >= 50 THEN ROUND(price * 0.95, 2)
    ELSE price
END;

-- Q8. DELETE with subquery.
DELETE FROM products_dml
WHERE cat_id = (SELECT cat_id FROM categories_dml WHERE cat_name = 'Sports')
  AND stock = 0;

-- Q9. UPSERT — insert or update on duplicate key.
INSERT INTO products_dml (sku, product_name, cat_id, price, stock)
VALUES ('SKU-001','Laptop Pro 15 (Updated)',1, 1149.99, 30)
ON DUPLICATE KEY UPDATE
    price = VALUES(price),
    stock = VALUES(stock),
    updated_at = NOW();
-- If SKU-001 exists: updates price, stock, updated_at.
-- If SKU-001 is new: inserts the row.

-- Q10. REPLACE INTO.
REPLACE INTO products_dml (sku, product_name, cat_id, price, stock)
VALUES ('SKU-002','Wireless Headphones Elite',1, 279.99, 70);
/*
  REPLACE vs INSERT … ON DUPLICATE KEY UPDATE:
  REPLACE = DELETE existing row + INSERT new row → AUTO_INCREMENT increases, FKs cascade-delete.
  ON DUPLICATE KEY UPDATE = only updates specific columns → same row_id, no cascade.
  Prefer ON DUPLICATE KEY UPDATE unless full row replacement is intended.
*/

-- Q11. Log price change manually (in transaction).
START TRANSACTION;
    -- Log old price
    INSERT INTO price_history (prod_id, old_price, new_price)
    SELECT prod_id, price, 899.99
    FROM products_dml
    WHERE sku = 'SKU-002';

    -- Apply price change
    UPDATE products_dml SET price = 899.99 WHERE sku = 'SKU-002';
COMMIT;

SELECT * FROM price_history;

-- Q12. Soft-delete cleanup → archive before hard delete.
CREATE TABLE IF NOT EXISTS products_archive LIKE products_dml;

-- Move inactive products to archive:
INSERT INTO products_archive
SELECT * FROM products_dml WHERE is_active = FALSE;

-- Verify moved correctly:
SELECT COUNT(*) AS archived_count FROM products_archive;

-- Now hard delete:
DELETE FROM products_dml WHERE is_active = FALSE;

-- Q13. Update top 3 most expensive per category by 20%.
UPDATE products_dml p
JOIN (
    SELECT prod_id
    FROM (
        SELECT prod_id,
               RANK() OVER (PARTITION BY cat_id ORDER BY price DESC) AS rnk
        FROM products_dml
        WHERE is_active = TRUE
    ) ranked
    WHERE rnk <= 3
) top_products ON p.prod_id = top_products.prod_id
SET p.price = ROUND(p.price * 1.20, 2);

-- Q14. TRUNCATE vs DELETE.
-- DELETE removes rows one by one, logs each row, respects WHERE, can be rolled back:
-- DELETE FROM staging_products;        -- all rows, logged, rollback-able

-- TRUNCATE drops and recreates the table structure (DDL under the hood):
TRUNCATE TABLE staging_products;
/*
  TRUNCATE:
  ✔ Much faster on large tables (no row-by-row logging).
  ✔ Resets AUTO_INCREMENT counter to 1.
  ✔ Cannot have a WHERE clause.
  ✘ Cannot be rolled back in MySQL (it's DDL, not DML).
  ✘ Cannot be used if there are FK constraints referencing the table.

  DELETE:
  ✔ Supports WHERE.
  ✔ Can be rolled back.
  ✔ Fires AFTER DELETE triggers.
  ✘ Slower for large tables (individual row logging).
  ✘ Does NOT reset AUTO_INCREMENT.
*/

-- Q15. UPDATE with LIMIT — stock bump for 5 cheapest products.
UPDATE products_dml
SET stock = stock + 10
ORDER BY price ASC
LIMIT 5;

SELECT prod_id, sku, price, stock FROM products_dml ORDER BY price ASC LIMIT 5;

-- ── KEY TAKEAWAYS ──────────────────────────────────────────
-- • INSERT … VALUES (…),(…) → multi-row insert in one statement (faster).
-- • INSERT INTO … SELECT → copy/transform data from another table.
-- • UPDATE … JOIN → update based on values from another table.
-- • UPDATE … CASE → conditional updates in one pass.
-- • ON DUPLICATE KEY UPDATE → upsert; safer than REPLACE.
-- • Soft delete (is_active=FALSE) preserves history; hard delete is permanent.
-- • TRUNCATE = fast wipe + resets sequence; DELETE = surgical, rollback-able.
-- • Always run a SELECT with the same WHERE before a DELETE to verify scope.
-- ───────────────────────────────────────────────────────────
