-- ============================================================
--  SQL INTERVIEW PREP — 20: Advanced Analytics & Reporting
--  Level     : Expert
--  Dataset   : E-Commerce (reusing ecommerce_db)
--  Covers    : Cohort analysis, Funnel, Retention, YoY, RFM
--  These are FAANG-level SQL interview questions
-- ============================================================

USE ecommerce_db;

-- Add more data for richer analytics
DROP TABLE IF EXISTS user_events;
CREATE TABLE user_events (
    event_id    INT PRIMARY KEY AUTO_INCREMENT,
    customer_id VARCHAR(10),
    event_type  VARCHAR(30),  -- 'page_view','add_to_cart','checkout','purchase'
    event_date  DATE,
    session_id  VARCHAR(40)
);

INSERT INTO user_events (customer_id, event_type, event_date, session_id) VALUES
 ('C001','page_view',  '2023-01-10','S001'),('C001','add_to_cart','2023-01-10','S001'),
 ('C001','checkout',   '2023-01-10','S001'),('C001','purchase',   '2023-01-10','S001'),
 ('C002','page_view',  '2023-01-15','S002'),('C002','add_to_cart','2023-01-15','S002'),
 ('C002','checkout',   '2023-01-15','S002'),
 ('C003','page_view',  '2023-02-01','S003'),('C003','add_to_cart','2023-02-01','S003'),
 ('C003','purchase',   '2023-02-01','S003'),
 ('C004','page_view',  '2023-02-14','S004'),
 ('C005','page_view',  '2023-03-01','S005'),('C005','add_to_cart','2023-03-01','S005'),
 ('C005','checkout',   '2023-03-01','S005'),('C005','purchase',   '2023-03-01','S005'),
 ('C006','page_view',  '2023-03-10','S006'),('C006','add_to_cart','2023-03-10','S006'),
 ('C006','purchase',   '2023-03-10','S006'),
 ('C007','page_view',  '2023-04-05','S007'),('C007','add_to_cart','2023-04-05','S007'),
 ('C007','checkout',   '2023-04-05','S007'),('C007','purchase',   '2023-04-05','S007'),
 ('C008','page_view',  '2023-04-20','S008'),
 ('C009','page_view',  '2023-05-01','S009'),('C009','purchase',   '2023-05-01','S009'),
 ('C010','page_view',  '2023-05-15','S010'),('C010','add_to_cart','2023-05-15','S010'),
 ('C010','checkout',   '2023-05-15','S010'),('C010','purchase',   '2023-05-15','S010');

-- ─────────────────────────────────────────────────────────────
--  TASKS
-- ─────────────────────────────────────────────────────────────

-- Q1. [HARD] CONVERSION FUNNEL ANALYSIS:
--     Count how many unique customers reached each stage:
--     page_view → add_to_cart → checkout → purchase
--     Show: stage, unique_customers, conversion_rate (vs page_view).



-- Q2. [HARD] COHORT ANALYSIS:
--     Group customers by the MONTH of their FIRST purchase (cohort month).
--     For each cohort, show how many customers are in it.
--     (First step of retention analysis.)



-- Q3. [HARD] MONTH-OVER-MONTH REVENUE GROWTH:
--     Using the orders table, show each month's total revenue and
--     the % change from the previous month.



-- Q4. [HARD] YEAR-OVER-YEAR COMPARISON:
--     Compare Jan-Jul 2023 revenue vs Jan-Jul 2022 (simulate 2022 data).
--     Show month, revenue_2023, revenue_2022, yoy_change_pct.
--     (Use CASE + GROUP BY approach.)



-- Q5. [HARD] RUNNING TOTAL + CONTRIBUTION %:
--     Show each month's revenue, running total, and its % contribution
--     to the overall total. Order by month.



-- Q6. [HARD] RFM ANALYSIS (Recency, Frequency, Monetary):
--     For each customer, calculate:
--     R = days since last order (recency — lower is better)
--     F = number of orders (frequency)
--     M = total spend (monetary)
--     Then score each 1-4 using NTILE(4):
--     R_score: NTILE on recency ASC (recent=4, old=1)
--     F_score: NTILE on frequency (high=4)
--     M_score: NTILE on monetary (high=4)
--     Show customer_id, R, F, M, scores, and combined RFM label.



-- Q7. [EXPERT] CUSTOMER RETENTION (Week-1 Retention):
--     Find customers who made a purchase in month 1 (January 2023)
--     AND also made a purchase in month 2 (February 2023).
--     Show: total_jan_buyers, retained_in_feb, retention_rate.



-- Q8. [EXPERT] FIRST AND REPEAT PURCHASE ANALYSIS:
--     For each customer, identify their first order date and
--     whether they ever made a second purchase (is_repeat_buyer).
--     Also show days between first and second purchase.



-- Q9. [EXPERT] PRODUCT AFFINITY:
--     Which pairs of products are most often purchased together
--     (by the same customer, not necessarily same order)?
--     Show product_id_1, product_id_2, co_purchase_count.
--     (Self-join on customer_id.)



-- Q10. [EXPERT] MOVING 3-MONTH AVERAGE REVENUE:
--      Show each month's revenue and a 3-month rolling average.
--      Identify months where revenue is BELOW the 3-month average
--      (potential underperformance signal).
