-- ============================================================
--  SQL INTERVIEW PREP — 10: Transactions  ✅ SOLUTIONS
-- ============================================================
USE bank_db;

-- Q1. Deposit $500 to account 1, commit.
SELECT balance AS balance_before FROM accounts WHERE account_id = 1;

START TRANSACTION;
    UPDATE accounts SET balance = balance + 500 WHERE account_id = 1;
    INSERT INTO transaction_log (from_acct, to_acct, amount, txn_type, txn_status, notes)
        VALUES (NULL, 1, 500, 'deposit', 'completed', 'Initial deposit');
COMMIT;

SELECT balance AS balance_after FROM accounts WHERE account_id = 1;

-- Q2. Demonstrate ROLLBACK — withdrawal that gets cancelled.
SELECT balance AS balance_before FROM accounts WHERE account_id = 6;

START TRANSACTION;
    UPDATE accounts SET balance = balance - 200 WHERE account_id = 6;
    -- Something went wrong — roll it back
ROLLBACK;

SELECT balance AS balance_unchanged FROM accounts WHERE account_id = 6;

-- Q3. Atomic transfer $1000 from account 3 → account 4.
START TRANSACTION;
    -- Deduct from sender
    UPDATE accounts SET balance = balance - 1000 WHERE account_id = 3;
    -- Credit receiver
    UPDATE accounts SET balance = balance + 1000 WHERE account_id = 4;
    -- Log the transaction
    INSERT INTO transaction_log (from_acct, to_acct, amount, txn_type, txn_status, notes)
        VALUES (3, 4, 1000, 'transfer', 'completed', 'Transfer from acct3 to acct4');
COMMIT;

SELECT account_id, balance FROM accounts WHERE account_id IN (3, 4);

-- Q4. Failed withdrawal — ROLLBACK on insufficient funds.
START TRANSACTION;
    -- Check balance first (account 7 has $100)
    -- $600 withdrawal would violate CHECK constraint — we handle manually:
    SET @current_balance = (SELECT balance FROM accounts WHERE account_id = 7);
    SET @withdraw_amount = 600;

    -- In real applications you'd use IF in a stored procedure:
    -- Since plain SQL doesn't have IF outside procedures, we demonstrate the concept:
    -- Attempt update (will fail CHECK constraint balance >= 0):
    -- UPDATE accounts SET balance = balance - 600 WHERE account_id = 7;

    -- Simulate the check:
    INSERT INTO transaction_log (from_acct, to_acct, amount, txn_type, txn_status, notes)
        VALUES (7, NULL, 600, 'withdrawal', 'failed', 'Insufficient funds');
ROLLBACK;
-- Note: The failed-log INSERT is also rolled back. In production, log to a separate
-- table outside the transaction, or use a stored procedure with DECLARE HANDLER.

-- Q5. SAVEPOINT demonstration.
START TRANSACTION;
    -- Step 1: Deposit $300 to account 2
    UPDATE accounts SET balance = balance + 300 WHERE account_id = 2;
    SAVEPOINT sp1;

    -- Step 2: Transfer $500 from acct2 to acct3
    UPDATE accounts SET balance = balance - 500 WHERE account_id = 2;
    UPDATE accounts SET balance = balance + 500 WHERE account_id = 3;
    SAVEPOINT sp2;

    -- Step 3: Attempted withdrawal of $2000 from acct3 — insufficient
    -- (We skip the actual UPDATE to avoid constraint error in demo)
    -- ROLLBACK TO sp2 undoes everything after sp2:
    ROLLBACK TO sp2;

COMMIT;
-- Final state: deposit and transfer committed; bad withdrawal undone.

-- Q6. Stored procedure for safe transfer.
DROP PROCEDURE IF EXISTS safe_transfer;

DELIMITER $$
CREATE PROCEDURE safe_transfer(
    IN  p_from   INT,
    IN  p_to     INT,
    IN  p_amount DECIMAL(15,2)
)
BEGIN
    DECLARE v_balance DECIMAL(15,2);

    START TRANSACTION;

    -- Lock the sender row for update
    SELECT balance INTO v_balance
    FROM accounts
    WHERE account_id = p_from
    FOR UPDATE;

    IF v_balance >= p_amount THEN
        UPDATE accounts SET balance = balance - p_amount WHERE account_id = p_from;
        UPDATE accounts SET balance = balance + p_amount WHERE account_id = p_to;
        INSERT INTO transaction_log (from_acct, to_acct, amount, txn_type, txn_status)
            VALUES (p_from, p_to, p_amount, 'transfer', 'completed');
        COMMIT;
        SELECT 'Transfer successful' AS result;
    ELSE
        ROLLBACK;
        INSERT INTO transaction_log (from_acct, to_acct, amount, txn_type, txn_status, notes)
            VALUES (p_from, p_to, p_amount, 'transfer', 'failed', 'Insufficient balance');
        SELECT 'Transfer failed: insufficient balance' AS result;
    END IF;
END$$
DELIMITER ;

-- Call with valid scenario ($500 from account 5 → account 6):
CALL safe_transfer(5, 6, 500);

-- Call with invalid scenario ($900 from account 7 (balance $100) → account 1):
CALL safe_transfer(7, 1, 900);

-- Q7. Isolation levels.
-- Set isolation level to READ COMMITTED for the session:
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;
    SELECT balance FROM accounts WHERE account_id = 1;
    -- At READ COMMITTED, you only see committed changes from other transactions.
COMMIT;

-- Reset to default (REPEATABLE READ in MySQL):
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

/*
  ISOLATION LEVELS & ANOMALIES:
  ┌─────────────────────┬──────────────┬──────────────────┬──────────────┐
  │ Isolation Level     │ Dirty Read   │ Non-Repeatable   │ Phantom Read │
  ├─────────────────────┼──────────────┼──────────────────┼──────────────┤
  │ READ UNCOMMITTED    │ Possible     │ Possible         │ Possible     │
  │ READ COMMITTED      │ Prevented    │ Possible         │ Possible     │
  │ REPEATABLE READ (*) │ Prevented    │ Prevented        │ Possible     │
  │ SERIALIZABLE        │ Prevented    │ Prevented        │ Prevented    │
  └─────────────────────┴──────────────┴──────────────────┴──────────────┘
  (*) MySQL default. InnoDB's MVCC largely prevents phantom reads too.

  Dirty Read        : Reading uncommitted changes from another transaction.
  Non-Repeatable   : Same SELECT returns different values if another txn commits between reads.
  Phantom Read      : Same range query returns different rows if another txn inserts/deletes.
*/

-- Q8. Batch fee deduction (0.5%) for balances > 1000.
SELECT account_id, balance AS before_fee FROM accounts WHERE balance > 1000;

START TRANSACTION;
    UPDATE accounts
    SET balance = ROUND(balance * 0.995, 2)   -- deduct 0.5%
    WHERE balance > 1000;
COMMIT;

SELECT account_id, balance AS after_fee FROM accounts WHERE balance > 1000;

-- Q9. Batch transfer — $50 from each account with balance > 2000 into account 1.
START TRANSACTION;
    -- Insert a log row for each transfer using INSERT INTO … SELECT
    INSERT INTO transaction_log (from_acct, to_acct, amount, txn_type, txn_status, notes)
    SELECT account_id, 1, 50, 'transfer', 'completed', 'Fund pooling'
    FROM accounts
    WHERE balance > 2000 AND account_id != 1;

    -- Deduct $50 from each qualifying account
    UPDATE accounts SET balance = balance - 50
    WHERE balance > 2000 AND account_id != 1;

    -- Credit account 1 with total collected
    UPDATE accounts
    SET balance = balance + (
        SELECT COUNT(*) * 50
        FROM (SELECT account_id FROM accounts WHERE balance > 2000 AND account_id != 1) sub
    )
    WHERE account_id = 1;
COMMIT;

-- Q10. ACID Theory Comments
/*
  ════════════════════════════════════════════════════════
  (a) ACID PROPERTIES
  ════════════════════════════════════════════════════════
  A — Atomicity    : All steps of a transaction succeed or ALL are rolled back.
                     "All or nothing." (Managed by UNDO logs in InnoDB.)

  C — Consistency  : A transaction takes the DB from one valid state to another.
                     Constraints (FK, CHECK, UNIQUE) enforce this.

  I — Isolation    : Concurrent transactions do not interfere with each other.
                     Controlled by isolation levels + locking / MVCC.

  D — Durability   : Once committed, data survives crashes.
                     Ensured by REDO logs (WAL — Write-Ahead Logging).

  ════════════════════════════════════════════════════════
  (b) ISOLATION LEVELS (see table in Q7 above)
  ════════════════════════════════════════════════════════

  ════════════════════════════════════════════════════════
  (c) DEADLOCKS
  ════════════════════════════════════════════════════════
  A deadlock occurs when two (or more) transactions each hold a lock
  and wait for a lock the other holds — creating a cycle.

  Example:
    Txn A: LOCK accounts(1), waits for accounts(2)
    Txn B: LOCK accounts(2), waits for accounts(1) → DEADLOCK

  Prevention strategies:
  1. Always acquire locks in the SAME ORDER (e.g., always lock lower ID first).
  2. Keep transactions SHORT — do heavy computation outside the transaction.
  3. Use SELECT … FOR UPDATE only when you intend to write.
  4. Use lower isolation levels when strong isolation is not required.
  5. Set innodb_deadlock_detect = ON (default) — MySQL detects and kills one txn.

  In application code: catch deadlock error (MySQL error 1213),
  wait briefly, and retry the transaction.
*/
