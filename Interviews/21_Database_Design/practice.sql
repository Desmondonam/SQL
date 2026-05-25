-- ============================================================
--  SQL INTERVIEW PREP — 21: Database Design & Normalization
--  Level     : Expert
--  Scenario  : Design a Social Media platform schema from scratch
--  Covers    : ERD → SQL, 1NF/2NF/3NF, constraints, design patterns
-- ============================================================

CREATE DATABASE IF NOT EXISTS design_db;
USE design_db;

-- ─────────────────────────────────────────────────────────────
--  PART A — NORMALIZATION EXERCISES
-- ─────────────────────────────────────────────────────────────

-- The following UNNORMALIZED table contains all data in one place.
-- Your job is to normalize it.

DROP TABLE IF EXISTS unnormalized_orders;
CREATE TABLE unnormalized_orders (
    order_id       INT,
    customer_name  VARCHAR(100),
    customer_email VARCHAR(150),
    customer_city  VARCHAR(80),
    product_1      VARCHAR(100),
    product_1_qty  INT,
    product_1_price DECIMAL(10,2),
    product_2      VARCHAR(100),
    product_2_qty  INT,
    product_2_price DECIMAL(10,2),
    product_3      VARCHAR(100),
    product_3_qty  INT,
    product_3_price DECIMAL(10,2),
    salesperson    VARCHAR(100),
    sales_region   VARCHAR(50),
    order_date     DATE
);

INSERT INTO unnormalized_orders VALUES
 (1,'Alice Johnson','alice@email.com','New York','Laptop',1,999.99,'Mouse',2,29.99, NULL,NULL,NULL,'Bob Smith','East','2023-01-10'),
 (2,'Alice Johnson','alice@email.com','New York','Keyboard',1,79.99,NULL,NULL,NULL,NULL,NULL,NULL,'Bob Smith','East','2023-02-15'),
 (3,'Carol White',  'carol@email.com','Chicago', 'Monitor',1,399.99,'Mouse',1,29.99,'Webcam',1,89.99,'Eve Davis','Central','2023-01-20');

-- Q1. [HARD] Identify all 1NF violations in unnormalized_orders.
--     Then create a 1NF version: no repeating groups.



-- Q2. [HARD] From your 1NF version, identify 2NF violations (partial dependencies).
--     Create a 2NF version: separate tables removing partial dependencies.
--     (A 2NF issue occurs when a non-key column depends on PART of a composite key.)



-- Q3. [HARD] From your 2NF version, identify 3NF violations (transitive dependencies).
--     Create a 3NF version: remove transitive dependencies.
--     (A 3NF issue is when a non-key column depends on another non-key column.)



-- ─────────────────────────────────────────────────────────────
--  PART B — DESIGN FROM SCRATCH: Social Media Platform
-- ─────────────────────────────────────────────────────────────

-- Requirements:
-- 1. Users can create posts (text, image, video)
-- 2. Users can follow other users
-- 3. Posts can have likes and comments
-- 4. Comments can have replies (nested)
-- 5. Posts can have multiple tags (hashtags)
-- 6. Users can send direct messages to each other
-- 7. Users have a profile with bio, avatar, etc.

-- Q4. [EXPERT] Design and CREATE all tables for this platform.
--     Include: primary keys, foreign keys, constraints, indexes.
--     Think about: junction tables for M:M relationships,
--     self-referencing for follows + comment replies.



-- Q5. [EXPERT] Insert sample data into your schema (at least 5 users,
--     10 posts, 5 follows, 20 likes, 10 comments).



-- Q6. [EXPERT] Write queries to answer common product questions:
--     (a) Top 5 most-followed users
--     (b) Most liked post in the last 30 days
--     (c) Users who follow each other (mutual follows)
--     (d) Top 10 trending hashtags



-- Q7. [EXPERT — Theory] Answer in comments:
--     (a) What is a surrogate key vs a natural key? When to use each?
--     (b) When would you choose to DENORMALIZE a table? Give examples.
--     (c) What is referential integrity and how does MySQL enforce it?
--     (d) Explain the difference between BCNF and 3NF.
--     (e) Design pattern: soft deletes — pros and cons.
