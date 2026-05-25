-- ============================================================
--  SQL INTERVIEW PREP — 16: Date & Time Functions
--  Level     : Intermediate → Advanced
--  Dataset   : Events & Subscription management
--              (Real-world SaaS subscription data patterns)
-- ============================================================

CREATE DATABASE IF NOT EXISTS datetime_db;
USE datetime_db;

DROP TABLE IF EXISTS subscriptions;
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS deliveries;

CREATE TABLE subscriptions (
    sub_id        INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100),
    plan          VARCHAR(20),     -- monthly, yearly, trial
    started_at    DATETIME,
    ends_at       DATETIME,
    cancelled_at  DATETIME,        -- NULL if still active
    trial_days    INT DEFAULT 0
);

CREATE TABLE events (
    event_id      INT PRIMARY KEY AUTO_INCREMENT,
    event_name    VARCHAR(150),
    host_city     VARCHAR(80),
    start_dt      DATETIME,
    end_dt        DATETIME,
    capacity      INT,
    registered    INT
);

CREATE TABLE deliveries (
    delivery_id   INT PRIMARY KEY AUTO_INCREMENT,
    order_ref     VARCHAR(20),
    ordered_at    DATETIME,
    shipped_at    DATETIME,
    delivered_at  DATETIME,
    promised_days INT        -- SLA: should be delivered within N days
);

INSERT INTO subscriptions (customer_name, plan, started_at, ends_at, cancelled_at, trial_days) VALUES
 ('Alice',  'yearly',  '2023-01-15 09:00:00','2024-01-15 09:00:00', NULL,                     0),
 ('Bob',    'monthly', '2023-03-01 10:30:00','2023-04-01 10:30:00', '2023-03-20 15:00:00',     0),
 ('Carol',  'trial',   '2023-06-10 08:00:00','2023-06-24 08:00:00', '2023-06-22 12:00:00',    14),
 ('Dave',   'yearly',  '2022-07-04 00:00:00','2023-07-04 00:00:00', NULL,                      0),
 ('Eve',    'monthly', '2023-09-01 09:00:00','2023-10-01 09:00:00', NULL,                      0),
 ('Frank',  'trial',   '2023-10-15 14:00:00','2023-10-29 14:00:00', NULL,                     14),
 ('Grace',  'yearly',  '2021-12-01 00:00:00','2022-12-01 00:00:00', '2022-05-15 10:00:00',     0),
 ('Henry',  'monthly', '2023-11-01 08:00:00','2023-12-01 08:00:00', NULL,                      0),
 ('Iris',   'yearly',  '2023-02-14 12:00:00','2024-02-14 12:00:00', NULL,                      0),
 ('Jack',   'monthly', '2023-12-01 00:00:00','2024-01-01 00:00:00', NULL,                      0);

INSERT INTO events (event_name, host_city, start_dt, end_dt, capacity, registered) VALUES
 ('SQL Summit 2023',    'New York',  '2023-06-15 09:00:00','2023-06-16 18:00:00',500,478),
 ('Data Conf Spring',   'London',   '2023-04-20 10:00:00','2023-04-21 17:00:00',300,302),
 ('ML Expo Fall',       'Tokyo',    '2023-10-05 09:00:00','2023-10-07 18:00:00',1000,850),
 ('DevOps Day',         'Berlin',   '2023-11-22 08:00:00','2023-11-22 20:00:00',200,190),
 ('Cloud Hackathon',    'Sydney',   '2024-01-12 08:00:00','2024-01-14 20:00:00',150,130),
 ('AI Workshop',        'Toronto',  '2024-03-08 09:00:00','2024-03-08 17:00:00',50, 45),
 ('Analytics Summit',   'Singapore','2024-05-20 09:00:00','2024-05-21 18:00:00',400,380);

INSERT INTO deliveries (order_ref, ordered_at, shipped_at, delivered_at, promised_days) VALUES
 ('ORD-001','2023-01-10 08:00:00','2023-01-11 14:00:00','2023-01-13 10:00:00',3),
 ('ORD-002','2023-02-15 09:30:00','2023-02-16 10:00:00','2023-02-22 16:00:00',5),
 ('ORD-003','2023-03-20 10:00:00','2023-03-20 18:00:00','2023-03-23 11:00:00',3),
 ('ORD-004','2023-04-01 07:00:00','2023-04-02 09:00:00', NULL,                2),
 ('ORD-005','2023-05-10 11:00:00','2023-05-11 12:00:00','2023-05-13 09:00:00',2),
 ('ORD-006','2023-06-25 15:00:00','2023-06-26 08:00:00','2023-06-27 14:00:00',2),
 ('ORD-007','2023-08-14 09:00:00','2023-08-14 20:00:00','2023-08-18 10:00:00',3),
 ('ORD-008','2023-09-05 10:00:00', NULL,                 NULL,                5);

-- ─────────────────────────────────────────────────────────────
--  TASKS
-- ─────────────────────────────────────────────────────────────

-- Q1. [EASY] Show the current date, time, and datetime.
--     Functions: NOW(), CURDATE(), CURTIME().



-- Q2. [EASY] Show each subscription's start year, month, and day separately.
--     Functions: YEAR(), MONTH(), DAY().



-- Q3. [EASY] How many days has each subscription been running?
--     Use DATEDIFF(ends_at, started_at).



-- Q4. [MEDIUM] Format started_at as 'January 15, 2023' style.
--     Functions: DATE_FORMAT().



-- Q5. [MEDIUM] Show subscriptions that expire (ends_at) within the next
--     30 days from today. (Assume today is 2023-12-01 for consistency.)
--     Functions: CURDATE(), DATE_ADD().



-- Q6. [MEDIUM] Calculate the number of MONTHS between started_at and ends_at.
--     Functions: TIMESTAMPDIFF(MONTH, ...).



-- Q7. [MEDIUM] Show each event's duration in hours.
--     Functions: TIMESTAMPDIFF(HOUR, start_dt, end_dt).



-- Q8. [MEDIUM] In the deliveries table, calculate:
--     - Days from ordered to shipped
--     - Days from shipped to delivered
--     - Total delivery days (order to delivery)
--     Show SLA breach: YES if total_days > promised_days.



-- Q9. [HARD] Group subscriptions by quarter (Q1, Q2, Q3, Q4)
--     of their start date. Show quarter, count, and plan breakdown.
--     Functions: QUARTER(), YEAR().



-- Q10. [HARD] Find subscriptions that were cancelled within their
--      first 7 days (early churners).
--      DATEDIFF(cancelled_at, started_at) <= 7.



-- Q11. [HARD] Show each delivery's ordered day of week (Monday=2, ...).
--      Are most orders placed on weekdays vs weekends?
--      Functions: DAYOFWEEK(), DAYNAME().



-- Q12. [HARD] Show a monthly breakdown of new subscriptions.
--      For each year-month, count how many subs started.



-- Q13. [EXPERT] Calculate AGE of each subscription in years, months, days.
--      Use PERIOD_DIFF or TIMESTAMPDIFF.
--      Show: customer_name, years_active, months_active, days_active.



-- Q14. [EXPERT] For each delivery, calculate if it was delivered on time.
--      Add days from ordered_at to get the deadline, compare to delivered_at.
--      Mark as 'On Time', 'Late', or 'Pending'.



-- Q15. [EXPERT] Show the number of active subscriptions for each day
--      in January 2023. (A subscription is "active" if started_at <=day
--      AND ends_at > day AND cancelled_at IS NULL or cancelled_at > day.)
--      Hint: Generate date series using a recursive CTE.
