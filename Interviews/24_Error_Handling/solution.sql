-- ============================================================
--  SQL INTERVIEW PREP — 24: Error Handling  ✅ SOLUTIONS
-- ============================================================
USE error_db;

-- Q1. Safe deposit with SQLEXCEPTION handler.
DROP PROCEDURE IF EXISTS safe_deposit;
DELIMITER $$
CREATE PROCEDURE safe_deposit(IN p_acct INT, IN p_amount DECIMAL(15,2))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            @code = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO error_log (proc_name, error_code, error_msg, context)
        VALUES ('safe_deposit', @code, @msg, CONCAT('acct:',p_acct,' amount:',p_amount));
        ROLLBACK;
        SELECT 'failed' AS result, @msg AS error;
    END;

    START TRANSACTION;
        UPDATE accounts_err SET balance = balance + p_amount WHERE acct_id = p_acct;
        IF ROW_COUNT() = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account not found';
        END IF;
    COMMIT;
    SELECT 'success' AS result, p_amount AS deposited;
END$$
DELIMITER ;

CALL safe_deposit(1, 500);    -- success
CALL safe_deposit(99, 100);   -- fails: account not found

-- Q2. Safe transfer with custom SIGNAL validations.
DROP PROCEDURE IF EXISTS safe_transfer_v2;
DELIMITER $$
CREATE PROCEDURE safe_transfer_v2(IN p_from INT, IN p_to INT, IN p_amount DECIMAL(15,2))
BEGIN
    DECLARE v_from_balance DECIMAL(15,2) DEFAULT -1;
    DECLARE v_to_exists    INT           DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @code = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
        INSERT INTO error_log (proc_name, error_code, error_msg, context)
        VALUES ('safe_transfer_v2', @code, @msg, CONCAT('from:',p_from,' to:',p_to,' amt:',p_amount));
        ROLLBACK;
        SELECT 'failed' AS result, @msg AS error;
    END;

    -- Validate from account
    SELECT balance INTO v_from_balance FROM accounts_err WHERE acct_id = p_from;
    IF v_from_balance < 0 THEN
        SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Source account not found';
    END IF;

    -- Validate sufficient balance
    IF v_from_balance < p_amount THEN
        SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'Insufficient balance';
    END IF;

    -- Validate destination
    SELECT COUNT(*) INTO v_to_exists FROM accounts_err WHERE acct_id = p_to;
    IF v_to_exists = 0 THEN
        SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'Destination account not found';
    END IF;

    -- Execute transfer
    START TRANSACTION;
        UPDATE accounts_err SET balance = balance - p_amount WHERE acct_id = p_from;
        UPDATE accounts_err SET balance = balance + p_amount WHERE acct_id = p_to;
        INSERT INTO transfers_err (from_acct, to_acct, amount, status)
        VALUES (p_from, p_to, p_amount, 'completed');
    COMMIT;
    SELECT 'success' AS result;
END$$
DELIMITER ;

CALL safe_transfer_v2(1, 2, 300);    -- success
CALL safe_transfer_v2(4, 1, 1000);   -- fails: insufficient balance
CALL safe_transfer_v2(99, 1, 100);   -- fails: source not found

-- Q3. CONTINUE vs EXIT handler.
DROP PROCEDURE IF EXISTS demo_continue_handler;
DELIMITER $$
CREATE PROCEDURE demo_continue_handler()
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION   -- continues after error
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @msg = MESSAGE_TEXT;
        INSERT INTO error_log (proc_name, error_msg) VALUES ('demo_continue', @msg);
        SELECT CONCAT('Error caught, continuing: ', @msg) AS notice;
    END;

    -- This will fail (negative balance violates CHECK):
    UPDATE accounts_err SET balance = -999 WHERE acct_id = 1;
    SELECT 'Step 1 done' AS step;  -- This STILL runs with CONTINUE handler!

    UPDATE accounts_err SET balance = balance + 100 WHERE acct_id = 2;
    SELECT 'Step 2 done — procedure completed' AS step;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS demo_exit_handler;
DELIMITER $$
CREATE PROCEDURE demo_exit_handler()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION   -- STOPS on error
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @msg = MESSAGE_TEXT;
        INSERT INTO error_log (proc_name, error_msg) VALUES ('demo_exit', @msg);
        SELECT CONCAT('Error caught, STOPPING: ', @msg) AS notice;
    END;

    UPDATE accounts_err SET balance = -999 WHERE acct_id = 1;   -- fails
    SELECT 'This line is NEVER reached' AS step;  -- skipped!
END$$
DELIMITER ;

CALL demo_continue_handler();
CALL demo_exit_handler();

-- Q4. GET DIAGNOSTICS — detailed error info.
DROP PROCEDURE IF EXISTS demo_diagnostics;
DELIMITER $$
CREATE PROCEDURE demo_diagnostics()
BEGIN
    DECLARE v_errno INT;
    DECLARE v_msg   TEXT;
    DECLARE v_state CHAR(5);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_errno = MYSQL_ERRNO,
            v_msg   = MESSAGE_TEXT,
            v_state = RETURNED_SQLSTATE;
        SELECT v_errno AS error_number, v_state AS sqlstate, v_msg AS message;
    END;

    INSERT INTO accounts_err (acct_id, owner_name, balance) VALUES (1,'Duplicate',0);
    -- error 1062: Duplicate entry for primary key
END$$
DELIMITER ;
CALL demo_diagnostics();

-- Q5. Batch transfer with cursor + CONTINUE handler.
DROP PROCEDURE IF EXISTS batch_transfer;
DELIMITER $$
CREATE PROCEDURE batch_transfer()
BEGIN
    DECLARE done       INT DEFAULT FALSE;
    DECLARE v_acct     INT;
    DECLARE v_amount   DECIMAL(15,2);
    DECLARE v_success  INT DEFAULT 0;
    DECLARE v_fail     INT DEFAULT 0;

    DECLARE cur CURSOR FOR
        SELECT acct_id, 50.00 FROM accounts_err WHERE acct_id IN (1,2,3,4,99);

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SET v_fail = v_fail + 1;
        ROLLBACK;
    END;

    OPEN cur;
    batch_loop: LOOP
        FETCH cur INTO v_acct, v_amount;
        IF done THEN LEAVE batch_loop; END IF;

        START TRANSACTION;
        UPDATE accounts_err SET balance = balance + v_amount WHERE acct_id = v_acct;
        IF ROW_COUNT() > 0 THEN
            SET v_success = v_success + 1;
            COMMIT;
        ELSE
            SET v_fail = v_fail + 1;
            ROLLBACK;
        END IF;
    END LOOP;
    CLOSE cur;

    SELECT v_success AS successful, v_fail AS failed;
END$$
DELIMITER ;
CALL batch_transfer();

-- Q6. RESIGNAL — enrich and re-raise.
DROP PROCEDURE IF EXISTS inner_proc;
DROP PROCEDURE IF EXISTS outer_proc;
DELIMITER $$
CREATE PROCEDURE inner_proc()
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Something failed inside inner_proc';
END$$

CREATE PROCEDURE outer_proc()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @msg = MESSAGE_TEXT;
        -- Add outer context and re-raise:
        RESIGNAL SET MESSAGE_TEXT = CONCAT('outer_proc caught: ', @msg);
    END;
    CALL inner_proc();
END$$
DELIMITER ;
-- CALL outer_proc();  -- Will show: "outer_proc caught: Something failed inside inner_proc"

-- Q7. Audit transfer with specific SQLSTATE handling.
DROP PROCEDURE IF EXISTS audit_transfer;
DELIMITER $$
CREATE PROCEDURE audit_transfer(IN p_from INT, IN p_to INT, IN p_amount DECIMAL(15,2))
BEGIN
    DECLARE EXIT HANDLER FOR SQLSTATE '23000'  -- duplicate entry
    BEGIN
        INSERT INTO error_log (proc_name, error_code, error_msg) VALUES ('audit_transfer',23000,'Duplicate transaction');
        ROLLBACK;
        SELECT 'error: duplicate transaction' AS result;
    END;

    DECLARE EXIT HANDLER FOR SQLSTATE '45000'  -- user-defined
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @msg = MESSAGE_TEXT;
        INSERT INTO error_log (proc_name, error_code, error_msg) VALUES ('audit_transfer',45000,@msg);
        ROLLBACK;
        RESIGNAL;   -- re-raise to caller
    END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @code=MYSQL_ERRNO, @msg=MESSAGE_TEXT;
        INSERT INTO error_log (proc_name, error_code, error_msg) VALUES ('audit_transfer',@code,@msg);
        ROLLBACK;
        SELECT 'error: unexpected failure' AS result;
    END;

    START TRANSACTION;
        SAVEPOINT sp_deduct;
        UPDATE accounts_err SET balance = balance - p_amount WHERE acct_id = p_from;
        IF ROW_COUNT() = 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Source account not found'; END IF;

        SAVEPOINT sp_credit;
        UPDATE accounts_err SET balance = balance + p_amount WHERE acct_id = p_to;
        IF ROW_COUNT() = 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Dest account not found'; END IF;

        INSERT INTO transfers_err (from_acct, to_acct, amount, status) VALUES (p_from, p_to, p_amount,'completed');
    COMMIT;
    SELECT 'success' AS result;
END$$
DELIMITER ;

-- Q8. Theory
/*
(a) HANDLER TYPES:
    CONTINUE : After the handler block runs, execution resumes at the
               statement AFTER the one that caused the error.
    EXIT     : After the handler block runs, execution exits the current
               BEGIN…END block (common — "stop and cleanup").
    UNDO     : NOT supported in MySQL (reserved in standard SQL).
               Would roll back the current atomic block — use SAVEPOINTs instead.

(b) SQLSTATE CODES (5-char):
    '00000' → Success
    '02000' → No data found (cursor exhausted, SELECT INTO found nothing)
    '23000' → Constraint violation (duplicate PK, FK violation, NOT NULL)
    '42000' → Syntax error or access violation
    '45000' → User-defined exception (used with SIGNAL)
    '40001' → Deadlock detected (serialization failure)

(c) PROPAGATING ERRORS FROM NESTED PROCEDURES:
    If inner_proc raises SIGNAL and has no handler → error propagates to caller.
    Caller's EXIT HANDLER will catch it.
    Use RESIGNAL inside a handler to re-raise with added context.
    Without RESIGNAL, the error is swallowed by the handler.

(d) PRODUCTION BEST PRACTICES:
    1. Always use EXIT HANDLER with ROLLBACK for transactions.
    2. Log errors to a dedicated error_log table (persists even after rollback
       if using an out-of-transaction insert — requires a separate connection or
       an autonomous transaction workaround).
    3. Use specific SQLSTATE handlers before generic SQLEXCEPTION.
    4. RESIGNAL to preserve error propagation to the calling application.
    5. Keep transactions short — reduces deadlock window.
    6. Never silently swallow errors — always log or re-raise.
    7. Use GET DIAGNOSTICS to capture full error context.
*/
