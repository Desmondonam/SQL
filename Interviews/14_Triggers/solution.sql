-- ============================================================
--  SQL INTERVIEW PREP — 14: Triggers  ✅ SOLUTIONS
-- ============================================================
USE inventory_db;

-- Q1. BEFORE INSERT to auto-calculate line_total.
DROP TRIGGER IF EXISTS trg_calc_line_total;
DELIMITER $$
CREATE TRIGGER trg_calc_line_total
BEFORE INSERT ON order_line_items
FOR EACH ROW
BEGIN
    SET NEW.line_total = NEW.qty_ordered * NEW.unit_price;
END$$
DELIMITER ;

-- Q2. AFTER INSERT to deduct stock + log movement.
DROP TRIGGER IF EXISTS trg_deduct_stock;
DELIMITER $$
CREATE TRIGGER trg_deduct_stock
AFTER INSERT ON order_line_items
FOR EACH ROW
BEGIN
    DECLARE v_before INT;
    SELECT stock_qty INTO v_before FROM inventory WHERE product_id = NEW.product_id;

    UPDATE inventory
    SET stock_qty = stock_qty - NEW.qty_ordered
    WHERE product_id = NEW.product_id;

    INSERT INTO stock_movements (product_id, move_type, quantity, before_qty, after_qty, reference)
    VALUES (NEW.product_id, 'OUT', NEW.qty_ordered, v_before, v_before - NEW.qty_ordered, NEW.order_ref);
END$$
DELIMITER ;

-- Q3. BEFORE UPDATE on inventory — log to audit.
DROP TRIGGER IF EXISTS trg_log_stock_change;
DELIMITER $$
CREATE TRIGGER trg_log_stock_change
BEFORE UPDATE ON inventory
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, operation, record_id, old_data, new_data)
    VALUES (
        'inventory',
        'UPDATE',
        OLD.inv_id,
        CONCAT('stock_qty:', OLD.stock_qty),
        CONCAT('stock_qty:', NEW.stock_qty)
    );
END$$
DELIMITER ;

-- Q4. AFTER DELETE — restore stock + log.
DROP TRIGGER IF EXISTS trg_restore_stock;
DELIMITER $$
CREATE TRIGGER trg_restore_stock
AFTER DELETE ON order_line_items
FOR EACH ROW
BEGIN
    DECLARE v_before INT;
    SELECT stock_qty INTO v_before FROM inventory WHERE product_id = OLD.product_id;

    UPDATE inventory
    SET stock_qty = stock_qty + OLD.qty_ordered
    WHERE product_id = OLD.product_id;

    INSERT INTO stock_movements (product_id, move_type, quantity, before_qty, after_qty, reference)
    VALUES (OLD.product_id, 'IN', OLD.qty_ordered, v_before, v_before + OLD.qty_ordered,
            CONCAT('Cancelled order:', OLD.order_ref));
END$$
DELIMITER ;

-- Q5. BEFORE INSERT — check sufficient stock.
DROP TRIGGER IF EXISTS trg_check_stock;
DELIMITER $$
CREATE TRIGGER trg_check_stock
BEFORE INSERT ON order_line_items
FOR EACH ROW
BEGIN
    DECLARE v_available INT;
    SELECT stock_qty INTO v_available FROM inventory WHERE product_id = NEW.product_id;

    IF v_available < NEW.qty_ordered THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient stock for this order';
    END IF;
END$$
DELIMITER ;

-- Q6. AFTER UPDATE on inventory — reorder alert.
DROP TABLE IF EXISTS reorder_alerts;
CREATE TABLE reorder_alerts (
    alert_id    INT PRIMARY KEY AUTO_INCREMENT,
    product_id  INT,
    current_qty INT,
    reorder_lvl INT,
    alerted_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

DROP TRIGGER IF EXISTS trg_reorder_alert;
DELIMITER $$
CREATE TRIGGER trg_reorder_alert
AFTER UPDATE ON inventory
FOR EACH ROW
BEGIN
    DECLARE v_reorder INT;
    SELECT reorder_level INTO v_reorder FROM inv_products WHERE product_id = NEW.product_id;

    IF NEW.stock_qty < v_reorder AND OLD.stock_qty >= v_reorder THEN
        INSERT INTO reorder_alerts (product_id, current_qty, reorder_lvl)
        VALUES (NEW.product_id, NEW.stock_qty, v_reorder);
    END IF;
END$$
DELIMITER ;

-- Q7. Comprehensive audit trigger on inv_products.
DROP TRIGGER IF EXISTS trg_product_audit;
DELIMITER $$
CREATE TRIGGER trg_product_audit
AFTER UPDATE ON inv_products
FOR EACH ROW
BEGIN
    DECLARE v_changes TEXT DEFAULT '';

    IF OLD.product_name != NEW.product_name THEN
        SET v_changes = CONCAT(v_changes, 'name:', OLD.product_name, '->', NEW.product_name, '; ');
    END IF;
    IF OLD.unit_price != NEW.unit_price THEN
        SET v_changes = CONCAT(v_changes, 'price:', OLD.unit_price, '->', NEW.unit_price, '; ');
    END IF;
    IF OLD.reorder_level != NEW.reorder_level THEN
        SET v_changes = CONCAT(v_changes, 'reorder_level:', OLD.reorder_level, '->', NEW.reorder_level, '; ');
    END IF;

    IF v_changes != '' THEN
        INSERT INTO audit_log (table_name, operation, record_id, old_data, new_data)
        VALUES ('inv_products', 'UPDATE', OLD.product_id, v_changes, USER());
    END IF;
END$$
DELIMITER ;

-- Q8. Show and drop triggers.
SHOW TRIGGERS FROM inventory_db;
-- DROP TRIGGER IF EXISTS trg_calc_line_total;  -- example drop

/*
  TRIGGER PITFALLS:
  1. Cascading triggers: trigger on table A fires → modifies table B
     which has a trigger → modifies table C … can become infinite loops.
  2. Hidden business logic: triggers are invisible to application developers
     reading only the application code — causes debugging nightmares.
  3. Performance: triggers fire on EVERY qualifying DML — a high-volume
     table with complex triggers can severely degrade throughput.
  4. Replication: triggers may not replicate consistently in MySQL
     row-based vs statement-based replication modes.
  5. Error handling: an error inside a trigger rolls back the entire
     DML statement, which may surprise callers.
  Best practice: keep triggers simple; document them well; prefer
  application-level logic or stored procedures for complex rules.
*/

-- Q9. Prevent bad price + prevent deletion of stocked products.
DROP TRIGGER IF EXISTS trg_protect_price;
DELIMITER $$
CREATE TRIGGER trg_protect_price
BEFORE UPDATE ON inv_products
FOR EACH ROW
BEGIN
    IF NEW.unit_price < 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Price cannot be less than 1';
    END IF;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS trg_prevent_delete_stocked;
DELIMITER $$
CREATE TRIGGER trg_prevent_delete_stocked
BEFORE DELETE ON inv_products
FOR EACH ROW
BEGIN
    DECLARE v_qty INT DEFAULT 0;
    SELECT COALESCE(stock_qty,0) INTO v_qty FROM inventory WHERE product_id = OLD.product_id;
    IF v_qty > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot delete a product with existing stock';
    END IF;
END$$
DELIMITER ;

-- Q10. Integration tests.
-- a) Insert order line → stock deducted automatically
INSERT INTO order_line_items (order_ref, product_id, qty_ordered, unit_price)
VALUES ('ORD-001', 2, 5, 29.99);
-- line_total auto-set; stock_qty of product 2 drops from 80 → 75

SELECT stock_qty FROM inventory WHERE product_id = 2;   -- expect 75
SELECT * FROM stock_movements WHERE product_id = 2;

-- b) Delete order line → stock restored
DELETE FROM order_line_items WHERE order_ref = 'ORD-001';
SELECT stock_qty FROM inventory WHERE product_id = 2;   -- expect 80 again

-- c) Update product price → audit logged
UPDATE inv_products SET unit_price = 34.99 WHERE product_id = 2;
SELECT * FROM audit_log;

-- d) Try ordering more than available (product 1 has 25):
-- INSERT INTO order_line_items (order_ref, product_id, qty_ordered, unit_price)
-- VALUES ('ORD-002', 1, 100, 1299.99);
-- ERROR: Insufficient stock for this order

-- ── KEY TAKEAWAYS ──────────────────────────────────────────
-- • BEFORE trigger: runs before DML; can modify NEW.col values.
-- • AFTER trigger: runs after DML; sees final values.
-- • NEW = new row values (INSERT/UPDATE); OLD = old row values (UPDATE/DELETE).
-- • Use SIGNAL SQLSTATE to raise a custom error and abort the DML.
-- • FOR EACH ROW means trigger fires once per affected row.
-- • Triggers are per-table, per-event (INSERT/UPDATE/DELETE), per-timing (BEFORE/AFTER).
-- ───────────────────────────────────────────────────────────
