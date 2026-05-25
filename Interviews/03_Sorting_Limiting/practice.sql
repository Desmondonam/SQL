-- ============================================================
--  SQL INTERVIEW PREP — 03: Sorting & Limiting Results
--  Level     : Beginner → Intermediate
--  Dataset   : Stack Overflow-inspired Q&A platform
--              Inspired by: https://data.stackexchange.com/
-- ============================================================

CREATE DATABASE IF NOT EXISTS stackoverflow_db;
USE stackoverflow_db;

DROP TABLE IF EXISTS answers;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS tags;

CREATE TABLE users (
    user_id        INT PRIMARY KEY AUTO_INCREMENT,
    username       VARCHAR(80)  NOT NULL,
    reputation     INT          DEFAULT 0,
    location       VARCHAR(100),
    joined_date    DATE,
    badge_count    INT          DEFAULT 0,
    answer_count   INT          DEFAULT 0,
    question_count INT          DEFAULT 0
);

CREATE TABLE questions (
    question_id    INT PRIMARY KEY AUTO_INCREMENT,
    user_id        INT,
    title          VARCHAR(300),
    body           TEXT,
    score          INT          DEFAULT 0,
    view_count     INT          DEFAULT 0,
    answer_count   INT          DEFAULT 0,
    created_at     DATETIME,
    tags           VARCHAR(200)
);

CREATE TABLE answers (
    answer_id      INT PRIMARY KEY AUTO_INCREMENT,
    question_id    INT,
    user_id        INT,
    body           TEXT,
    score          INT          DEFAULT 0,
    is_accepted    BOOLEAN      DEFAULT FALSE,
    created_at     DATETIME
);

INSERT INTO users (username, reputation, location, joined_date, badge_count, answer_count, question_count) VALUES
 ('jon_skeet',      1500000,'London, UK',        '2008-09-26',10000, 35000, 50),
 ('gordon_linoff',   900000,'New York, USA',      '2012-01-15', 5000, 78000,  5),
 ('VonC',            650000,'Paris, France',      '2008-08-14', 4500, 55000, 30),
 ('anubhava',        500000,'Bangalore, India',   '2011-03-22', 3000, 40000, 10),
 ('Mark_Byers',      410000,'Oslo, Norway',       '2009-06-10', 2500, 33000,  8),
 ('CommonsWare',     400000,'Philadelphia, USA',  '2009-01-01', 2200, 28000, 15),
 ('paxdiablo',       380000,'Canberra, Australia','2008-10-01', 2100, 26000, 20),
 ('CMS',             340000,'Madrid, Spain',      '2009-03-15', 1800, 22000, 12),
 ('SLaks',           330000,'New York, USA',      '2009-09-01', 1700, 20000,  7),
 ('Blorgbeard',      280000,'Cape Town, SA',      '2010-07-20', 1200, 18000, 40),
 ('alice_dev',        15000,'Toronto, Canada',    '2018-05-12',  300,   800, 120),
 ('bob_codes',         8500,'Lagos, Nigeria',     '2019-11-03',  150,   400, 200),
 ('carol_sql',        22000,'Berlin, Germany',    '2017-08-25',  450,  1200,  90),
 ('dave_python',       5000,'Sydney, Australia',  '2021-02-14',  100,   200, 300),
 ('eve_data',         35000,'Tokyo, Japan',       '2016-04-01',  700,  2500,  60);

INSERT INTO questions (user_id, title, score, view_count, answer_count, created_at, tags) VALUES
 (11,'How do I reverse a string in Python?',              450,  85000, 12,'2023-01-05 10:00:00','python,string'),
 (12,'What is the difference between LEFT JOIN and INNER JOIN?',1200,250000,18,'2022-06-10 14:30:00','sql,mysql,joins'),
 (13,'How to optimise a slow SQL query?',                 890, 180000, 15,'2022-09-15 09:15:00','sql,performance,indexing'),
 (14,'Python list vs tuple — when to use which?',         320,  60000,  8,'2023-03-01 16:45:00','python,data-structures'),
 (15,'Explain window functions in SQL with examples',     1500, 320000, 20,'2021-11-20 11:00:00','sql,mysql,window-functions'),
 (11,'How do I merge two dictionaries in Python 3?',      780, 140000, 10,'2023-02-18 08:30:00','python,dict'),
 (12,'What is a CTE and how do I use it?',                660, 115000, 14,'2022-08-05 13:00:00','sql,cte,mysql'),
 (13,'How to handle NULL values in SQL?',                 540,  90000, 11,'2022-12-01 10:45:00','sql,null'),
 (14,'Best way to paginate SQL results?',                 430,  75000,  9,'2023-01-28 15:30:00','sql,pagination'),
 (15,'What is a stored procedure and when to use it?',    380,  62000,  7,'2023-04-10 09:00:00','sql,stored-procedures'),
 (1, 'How does Git rebase work?',                         920, 195000, 16,'2021-05-14 12:00:00','git,version-control'),
 (2, 'Difference between GROUP BY and ORDER BY?',         710, 130000, 13,'2022-03-22 11:30:00','sql,group-by,order-by'),
 (3, 'What is database normalisation?',                   600, 100000, 11,'2022-07-08 14:00:00','sql,database-design'),
 (4, 'How to use CASE WHEN in SQL?',                      850, 165000, 17,'2022-01-30 10:15:00','sql,case-when'),
 (5, 'Explain ACID properties in databases',              940, 200000, 19,'2021-08-25 09:30:00','databases,transactions,acid');

INSERT INTO answers (question_id, user_id, score, is_accepted, created_at) VALUES
 (1, 1, 380, TRUE,  '2023-01-05 10:45:00'),
 (1, 2, 120, FALSE, '2023-01-05 11:00:00'),
 (2, 3, 950, TRUE,  '2022-06-10 15:00:00'),
 (2, 1, 300, FALSE, '2022-06-10 15:30:00'),
 (3, 2, 780, TRUE,  '2022-09-15 10:00:00'),
 (4, 4,  90, FALSE, '2023-03-01 17:15:00'),
 (5, 1,1200, TRUE,  '2021-11-20 12:00:00'),
 (5, 5, 350, FALSE, '2021-11-20 13:00:00'),
 (6, 2, 650, TRUE,  '2023-02-18 09:00:00'),
 (7, 3, 540, TRUE,  '2022-08-05 14:00:00'),
 (8, 6, 480, TRUE,  '2022-12-01 11:30:00'),
 (9, 7, 400, TRUE,  '2023-01-28 16:00:00'),
 (10,8, 320, TRUE,  '2023-04-10 10:00:00'),
 (11,1, 870, TRUE,  '2021-05-14 12:30:00'),
 (15,9, 820, TRUE,  '2021-08-25 10:00:00');

-- ─────────────────────────────────────────────────────────────
--  TASKS
-- ─────────────────────────────────────────────────────────────

-- Q1. [EASY] List all users sorted by reputation in DESCENDING order.



-- Q2. [EASY] Show the top 5 highest-reputation users.



-- Q3. [EASY] List all questions sorted by view_count ASC (least viewed first).



-- Q4. [EASY] Show the 3 most recently asked questions.



-- Q5. [MEDIUM] Show questions sorted FIRST by answer_count DESC,
--     then by score DESC as a tiebreaker.



-- Q6. [MEDIUM] Implement pagination: show page 2 of questions (page size = 5),
--     ordered by created_at DESC.
--     Hint: LIMIT and OFFSET.



-- Q7. [MEDIUM] Show the top 3 users by answer_count.
--     In case of a tie, sort alphabetically by username.



-- Q8. [MEDIUM] List all answers ordered by score DESC. Show only the
--     top 5 highest-scoring answers.



-- Q9. [HARD] Find the top 10 questions by view_count. Display:
--     question_id, title, view_count, score.



-- Q10. [HARD] Show the BOTTOM 5 questions (lowest score),
--      but exclude questions with score = 0. Order by score ASC.
