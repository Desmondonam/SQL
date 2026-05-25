-- ============================================================
--  SQL INTERVIEW PREP — 14: Triggers
--  Level     : Advanced
--  Dataset   : Inventory & Audit system
-- ============================================================

CREATE DATABASE IF NOT EXISTS inventory_db;
USE inventory_db;

DROP TABLE IF EXISTS audit_log;
DROP TABLE IF EXISTS stock_movements;
DROP TABLE IF EXISTS order_line_items;
DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS inv_products;

CREATE TABLE inv_products (
    product_id   INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(150),
    category     VARCHAR(80),
    unit_price   DECIMAL(10,2),
    reorder_level INT DEFAULT 10   -- alert if stock drops below this
) ENGINE=InnoDB;

CREATE TABLE inventory (
    inv_id       INT PRIMARY KEY AUTO_INCREMENT,
    product_id   INT,
    stock_qty    INT NOT NULL DEFAULT 0,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES inv_products(product_id)
) ENGINE=InnoDB;

CREATE TABLE order_line_items (
    line_id     INT PRIMARY KEY AUTO_INCREMENT,
    order_ref   VARCHAR(20),
    product_id  INT,
    qty_ordered INT,
    unit_price  DECIMAL(10,2),
    line_total  DECIMAL(10,2),
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES inv_products(product_id)
) ENGINE=InnoDB;

CREATE TABLE stock_movements (
    move_id      INT PRIMARY KEY AUTO_INCREMENT,
    product_id   INT,
    move_type    VARCHAR(20),   -- IN (restock) or OUT (sale)
    quantity     INT,
    before_qty   INT,
    after_qty    INT,
    moved_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
    reference    VARCHAR(100)
) ENGINE=InnoDB;

CREATE TABLE audit_log (
    log_id      INT PRIMARY KEY AUTO_INCREMENT,
    table_name  VARCHAR(80),
    operation   VARCHAR(10),   -- INSERT, UPDATE, DELETE
    record_id   INT,
    old_data    TEXT,
    new_data    TEXT,
    changed_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    changed_by  VARCHAR(100) DEFAULT (USER())
) ENGINE=InnoDB;

-- Seed data
INSERT INTO inv_products (product_name, category, unit_price, reorder_level) VALUES
 ('Laptop Pro 15',   'Electronics', 1299.99, 5),
 ('Wireless Mouse',  'Electronics',   29.99, 20),
 ('Office Chair',    'Furniture',    499.99,  3),
 ('Notebook A5',     'Stationery',     4.99, 50),
 ('Mechanical Keyboard','Electronics',89.99, 10);

INSERT INTO inventory (product_id, stock_qty) VALUES
 (1, 25), (2, 80), (3, 12), (4, 200), (5, 45);

-- ─────────────────────────────────────────────────────────────
--  TASKS
-- ─────────────────────────────────────────────────────────────

-- Q1. [EASY] Create an AFTER INSERT trigger on 'order_line_items'
--     called 'trg_calc_line_total' that automatically sets
--     line_total = qty_ordered * unit_price BEFORE the row is saved.
--     (Hint: use BEFORE INSERT instead)



-- Q2. [MEDIUM] Create an AFTER INSERT trigger on 'order_line_items'
--     called 'trg_deduct_stock' that:
--     - Deducts qty_ordered from inventory when an order line is placed
--     - Logs the movement in stock_movements table



-- Q3. [MEDIUM] Create a BEFORE UPDATE trigger on 'inventory' called
--     'trg_log_stock_change' that:
--     - Logs every stock change to audit_log
--     - Stores old stock_qty and new stock_qty as JSON-like text



-- Q4. [MEDIUM] Create an AFTER DELETE trigger on 'order_line_items'
--     called 'trg_restore_stock' that:
--     - Restores qty back to inventory when an order line is deleted (cancelled)
--     - Logs the restoration in stock_movements



-- Q5. [HARD] Create a BEFORE INSERT trigger on 'order_line_items'
--     called 'trg_check_stock' that:
--     - Checks if there is enough stock before the order is placed
--     - If insufficient, raises an error using SIGNAL SQLSTATE
--     - If sufficient, proceeds



-- Q6. [HARD] Create an AFTER UPDATE trigger on inventory
--     'trg_reorder_alert' that:
--     - Checks if new stock_qty falls below reorder_level
--     - If so, inserts a row into a 'reorder_alerts' table
--     (Create reorder_alerts table first)



-- Q7. [HARD] Create a comprehensive AUDIT trigger on 'inv_products':
--     - AFTER UPDATE: log which columns changed (old vs new values)
--     - Use CONCAT to store old/new data as readable text
--     - Include timestamp and MySQL user()



-- Q8. [EXPERT] Write the SQL to SHOW all triggers in the current database.
--     Then write the SQL to DROP a specific trigger.
--     Finally, explain in comments when triggers can cause problems
--     (cascading triggers, performance, hidden business logic).



-- Q9. [EXPERT] Create a trigger that prevents price from being
--     set to less than 1 (BEFORE UPDATE on inv_products).
--     Also prevent DELETE of products that still have stock.



-- Q10. Test all your triggers by running these DML statements:
--      INSERT an order line → verify stock deducted
--      DELETE the order line → verify stock restored
--      UPDATE a product price → verify audit log entry
--      Try ordering more than available → verify error is raised
