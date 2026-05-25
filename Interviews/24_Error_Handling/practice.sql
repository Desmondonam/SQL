-- ============================================================
--  SQL INTERVIEW PREP — 24: Error Handling in MySQL
--  Level     : Advanced → Expert
--  Dataset   : Banking + Inventory (reusing bank_db concepts)
--  Covers    : DECLARE HANDLER, SIGNAL, RESIGNAL, error logging
-- ============================================================

CREATE DATABASE IF NOT EXISTS error_db;
USE error_db;

DROP TABLE IF EXISTS error_log;
DROP TABLE IF EXISTS accounts_err;
DROP TABLE IF EXISTS transfers_err;

CREATE TABLE accounts_err (
    acct_id    INT PRIMARY KEY AUTO_INCREMENT,
    owner_name VARCHAR(100) NOT NULL,
    balance    DECIMAL(15,2) NOT NULL DEFAULT 0,
    CONSTRAINT chk_bal CHECK (balance >= 0)
) ENGINE=InnoDB;

CREATE TABLE transfers_err (
    txn_id     INT PRIMARY KEY AUTO_INCREMENT,
    from_acct  INT NOT NULL,
    to_acct    INT NOT NULL,
    amount     DECIMAL(15,2) NOT NULL,
    status     VARCHAR(20) DEFAULT 'pending',  -- completed, failed
    error_msg  VARCHAR(500),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (from_acct) REFERENCES accounts_err(acct_id),
    FOREIGN KEY (to_acct)   REFERENCES accounts_err(acct_id)
) ENGINE=InnoDB;

CREATE TABLE error_log (
    error_id   INT PRIMARY KEY AUTO_INCREMENT,
    proc_name  VARCHAR(100),
    error_code INT,
    error_msg  TEXT,
    logged_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    context    VARCHAR(500)
) ENGINE=InnoDB;

INSERT INTO accounts_err (owner_name, balance) VALUES
 ('Alice',  5000.00),
 ('Bob',    1000.00),
 ('Carol', 12000.00),
 ('Dave',    200.00);

-- ─────────────────────────────────────────────────────────────
--  TASKS
-- ─────────────────────────────────────────────────────────────

-- Q1. [MEDIUM] Write a stored procedure 'safe_deposit' that:
--     - Accepts acct_id and amount
--     - Uses DECLARE HANDLER FOR SQLEXCEPTION to catch any error
--     - If successful: updates balance + returns 'success'
--     - If error: logs to error_log + returns 'failed'



-- Q2. [MEDIUM] Write a procedure 'safe_transfer_v2' that:
--     - Accepts from_id, to_id, amount
--     - Validates: from_id exists, to_id exists, sufficient balance
--     - Uses custom SIGNAL for each validation failure
--     - On success: performs transfer atomically
--     - On any error: logs and reports cleanly



-- Q3. [HARD] Demonstrate DECLARE CONTINUE HANDLER vs EXIT HANDLER:
--     Write two versions of a procedure that processes a list of operations.
--     Version A: CONTINUE HANDLER — logs error, continues processing.
--     Version B: EXIT HANDLER — logs error, stops processing.
--     Show the difference in behavior.



-- Q4. [HARD] Use GET DIAGNOSTICS to capture detailed MySQL error info
--     after a statement fails inside a procedure.



-- Q5. [HARD] Write a procedure 'batch_transfer' that:
--     - Transfers fixed amounts to multiple accounts
--     - Uses a cursor to iterate through a list
--     - If any single transfer fails, logs it but continues others
--     - Returns a summary: successful_transfers, failed_transfers



-- Q6. [HARD] Demonstrate RESIGNAL — catch an error, add context, re-raise it.
--     Useful for enriching error messages with procedure names/context.



-- Q7. [EXPERT] Write a robust 'audit_transfer' procedure that:
--     - Catches specific MySQL errors by SQLSTATE code
--     - Error 23000 (duplicate entry) → custom message
--     - Error 45000 (user-defined) → re-raise with context
--     - Generic SQLEXCEPTION → log and return generic error
--     - Uses SAVEPOINT so partial failures can be rolled back granularly



-- Q8. [EXPERT — Theory] Write detailed comments explaining:
--     (a) The difference between CONTINUE, EXIT, and UNDO handlers
--     (b) SQLSTATE codes — what they are and common ones
--     (c) How to propagate errors from nested stored procedures
--     (d) Best practices for error handling in production SQL code
