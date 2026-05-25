-- ============================================================
--  SQL INTERVIEW PREP — 10: Transactions & ACID Properties
--  Level     : Intermediate → Advanced
--  Dataset   : Banking System (classic transaction scenario)
--  Engine    : InnoDB (MySQL) — supports full ACID transactions
-- ============================================================

CREATE DATABASE IF NOT EXISTS bank_db;
USE bank_db;

DROP TABLE IF EXISTS transaction_log;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS customers_bank;

CREATE TABLE customers_bank (
    customer_id  INT PRIMARY KEY AUTO_INCREMENT,
    full_name    VARCHAR(100) NOT NULL,
    email        VARCHAR(150) UNIQUE,
    phone        VARCHAR(20),
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE accounts (
    account_id   INT PRIMARY KEY AUTO_INCREMENT,
    customer_id  INT NOT NULL,
    account_type VARCHAR(20) NOT NULL,  -- savings, checking, loan
    balance      DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    currency     CHAR(3) DEFAULT 'USD',
    status       VARCHAR(20) DEFAULT 'active',  -- active, frozen, closed
    opened_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers_bank(customer_id),
    CONSTRAINT chk_balance CHECK (balance >= 0)
) ENGINE=InnoDB;

CREATE TABLE transaction_log (
    txn_id       INT PRIMARY KEY AUTO_INCREMENT,
    from_acct    INT,
    to_acct      INT,
    amount       DECIMAL(15,2) NOT NULL,
    txn_type     VARCHAR(20),   -- deposit, withdrawal, transfer, fee
    txn_status   VARCHAR(20) DEFAULT 'pending',  -- pending, completed, failed, rolled_back
    notes        VARCHAR(200),
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (from_acct) REFERENCES accounts(account_id),
    FOREIGN KEY (to_acct)   REFERENCES accounts(account_id)
) ENGINE=InnoDB;

-- Seed data
INSERT INTO customers_bank (full_name, email, phone) VALUES
 ('Alice Johnson','alice@email.com','+1-555-0101'),
 ('Bob Smith',    'bob@email.com',  '+1-555-0102'),
 ('Carol White',  'carol@email.com','+1-555-0103'),
 ('David Lee',    'david@email.com','+1-555-0104');

INSERT INTO accounts (customer_id, account_type, balance) VALUES
 (1,'savings',  5000.00),   -- account_id = 1
 (1,'checking', 1500.00),   -- account_id = 2
 (2,'savings',  8000.00),   -- account_id = 3
 (2,'checking',  200.00),   -- account_id = 4
 (3,'savings', 12000.00),   -- account_id = 5
 (4,'savings',   500.00),   -- account_id = 6
 (4,'checking',  100.00);   -- account_id = 7

-- ─────────────────────────────────────────────────────────────
--  TASKS
-- ─────────────────────────────────────────────────────────────

-- Q1. [EASY] Start a transaction and deposit $500 to account 1.
--     Log it to transaction_log. Commit.
--     Show the account balance before and after.



-- Q2. [EASY] Demonstrate a ROLLBACK:
--     Start a transaction, withdraw $200 from account 6 (balance = $500),
--     then ROLLBACK. Show balance was not changed.



-- Q3. [MEDIUM] Transfer $1000 from account 3 to account 4 in a single
--     atomic transaction:
--     Step 1: Deduct $1000 from account 3
--     Step 2: Add $1000 to account 4
--     Step 3: Log both sides to transaction_log
--     Step 4: COMMIT
--     Make sure BOTH operations succeed or BOTH fail.



-- Q4. [MEDIUM] Demonstrate a failed transaction with ROLLBACK:
--     Try to withdraw $600 from account 7 (balance = $100).
--     Check balance first; if insufficient, ROLLBACK and log 'failed'.



-- Q5. [MEDIUM] Use SAVEPOINT:
--     Start a transaction.
--     - Deposit $300 to account 2  → SAVEPOINT sp1
--     - Transfer $500 from acct 2 to acct 3  → SAVEPOINT sp2
--     - Attempt to withdraw $2000 from acct 3 (insufficient)
--     - ROLLBACK TO sp2 (undo the bad withdrawal, keep deposit + transfer)
--     - COMMIT



-- Q6. [HARD] Write a stored procedure called 'safe_transfer' that:
--     - Accepts: from_id, to_id, amount
--     - Checks if from_id has sufficient balance
--     - If yes: performs transfer + logs it + COMMITs
--     - If no:  logs failed attempt + ROLLBACKs
--     Then CALL it with a valid and an invalid scenario.



-- Q7. [HARD] Demonstrate isolation levels:
--     Write the SQL to set the transaction isolation level to
--     READ COMMITTED, then perform a read within a transaction.
--     Explain in comments what "dirty read", "phantom read", and
--     "non-repeatable read" mean.



-- Q8. [HARD] Simulate a bank fee deduction for all accounts with
--     balance > 1000: charge a 0.5% monthly maintenance fee.
--     Do this as a single transaction. COMMIT.
--     Show before and after balances.



-- Q9. [EXPERT] Write a transaction that performs a batch transfer
--     using a cursor/loop (or multiple statements):
--     Transfer $50 from all accounts with balance > 2000 into account 1
--     as a "fund pooling" operation. Log each transfer.



-- Q10. [EXPERT — Theory] Write comments explaining:
--      (a) What ACID stands for and what each property guarantees.
--      (b) The 4 isolation levels in MySQL and what anomalies each prevents.
--      (c) What a deadlock is and how to prevent it.
