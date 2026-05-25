-- ============================================================
--  SQL INTERVIEW PREP — 09: Common Table Expressions (CTEs)
--  Level     : Advanced
--  Dataset   : GitHub-inspired Repositories & Contributions
--              Inspired by GH Archive: https://www.gharchive.org/
-- ============================================================

CREATE DATABASE IF NOT EXISTS github_db;
USE github_db;

DROP TABLE IF EXISTS pull_requests;
DROP TABLE IF EXISTS commits;
DROP TABLE IF EXISTS repo_stars;
DROP TABLE IF EXISTS repositories;
DROP TABLE IF EXISTS gh_users;

CREATE TABLE gh_users (
    user_id    INT PRIMARY KEY,
    username   VARCHAR(80),
    joined     DATE,
    country    VARCHAR(80),
    followers  INT DEFAULT 0,
    plan       VARCHAR(20) DEFAULT 'free'  -- free, pro, enterprise
);

CREATE TABLE repositories (
    repo_id      INT PRIMARY KEY,
    owner_id     INT,
    repo_name    VARCHAR(100),
    language     VARCHAR(50),
    stars        INT DEFAULT 0,
    forks        INT DEFAULT 0,
    created_date DATE,
    is_private   BOOLEAN DEFAULT FALSE,
    topic        VARCHAR(80)
);

CREATE TABLE commits (
    commit_id   INT PRIMARY KEY,
    repo_id     INT,
    user_id     INT,
    commit_date DATE,
    additions   INT DEFAULT 0,
    deletions   INT DEFAULT 0,
    message     VARCHAR(200)
);

CREATE TABLE repo_stars (
    repo_id   INT,
    user_id   INT,
    starred_at DATE,
    PRIMARY KEY (repo_id, user_id)
);

CREATE TABLE pull_requests (
    pr_id        INT PRIMARY KEY,
    repo_id      INT,
    author_id    INT,
    reviewer_id  INT,
    title        VARCHAR(200),
    status       VARCHAR(20),   -- open, merged, closed
    created_at   DATE,
    merged_at    DATE,
    lines_added  INT,
    lines_removed INT
);

INSERT INTO gh_users VALUES
 (1,'torvalds',   '2011-09-04','Finland',  180000,'free'),
 (2,'gvanrossum', '2012-03-15','USA',       50000,'pro'),
 (3,'dhh',        '2008-06-01','USA',       40000,'free'),
 (4,'yyx990803',  '2015-02-14','China',    100000,'pro'),
 (5,'sindresorhus','2012-11-20','Norway',   70000,'free'),
 (6,'kentcdodds', '2013-07-10','USA',       50000,'pro'),
 (7,'addyosmani', '2011-05-05','UK',        45000,'enterprise'),
 (8,'paulirish',  '2009-08-12','USA',       30000,'free'),
 (9,'alice_dev',  '2020-01-15','Brazil',     1200,'free'),
 (10,'bob_codes', '2019-06-20','India',      3400,'free'),
 (11,'carol_eng', '2021-03-08','Germany',    2100,'pro'),
 (12,'dave_ml',   '2022-09-01','Canada',      800,'free');

INSERT INTO repositories VALUES
 (1, 1,'linux',           'C',          160000,52000,'1991-10-05',FALSE,'os'),
 (2, 2,'cpython',         'Python',      55000, 28000,'1991-01-20',FALSE,'language'),
 (3, 3,'rails',           'Ruby',        52000, 21000,'2004-07-19',FALSE,'web-framework'),
 (4, 4,'vue',             'JavaScript', 205000, 33000,'2013-07-29',FALSE,'frontend'),
 (5, 5,'sindre-utils',    'JavaScript',  12000,  1800,'2012-12-01',FALSE,'utilities'),
 (6, 6,'testing-library', 'JavaScript',  17000,  2200,'2015-09-10',FALSE,'testing'),
 (7, 7,'workbox',         'JavaScript',  11000,  1500,'2017-03-22',FALSE,'pwa'),
 (8, 9,'my-first-project','Python',        120,    15,'2022-03-15',FALSE,'practice'),
 (9,10,'sql-notes',       'SQL',           340,    42,'2021-08-20',FALSE,'learning'),
 (10,11,'ml-playground',  'Python',        890,   110,'2022-11-05',FALSE,'machine-learning'),
 (11,12,'blog-site',      'JavaScript',    230,    28,'2023-01-10',FALSE,'web'),
 (12, 1,'subsurface',     'C++',          2100,   450,'2012-09-05',FALSE,'diving');

INSERT INTO commits VALUES
 (1, 1,1,'2023-01-10',150, 30,'Initial kernel patch'),
 (2, 1,1,'2023-01-15', 80, 20,'Fix memory leak'),
 (3, 2,2,'2023-01-12',200, 50,'Add async support'),
 (4, 4,4,'2023-01-20',320, 80,'New reactivity system'),
 (5, 4,4,'2023-02-01',180, 40,'Performance improvements'),
 (6, 8,9,'2023-02-10', 50, 10,'First commit'),
 (7, 9,10,'2023-02-15', 30,  5,'Add SQL joins notes'),
 (8, 1,9,'2023-02-20', 20,  5,'Fix typo in comment'),
 (9, 4,11,'2023-03-01',100, 25,'Implement new feature'),
 (10,10,11,'2023-03-10',200, 60,'Train classification model'),
 (11, 2,10,'2023-03-15', 40, 15,'Update docs'),
 (12, 6,6,'2023-03-20',160, 35,'Add new test cases'),
 (13, 1,1,'2023-04-01',300, 70,'Major refactor'),
 (14, 4,4,'2023-04-10',250, 60,'Vue 3.3 release prep'),
 (15,11,12,'2023-04-15', 80, 20,'Add dark mode');

INSERT INTO pull_requests VALUES
 (1, 1, 9,1,'Fix typo in docs',      'merged','2023-02-18','2023-02-20',   5,  2),
 (2, 4,11,4,'New component feature', 'merged','2023-02-28','2023-03-05', 200, 30),
 (3, 2,10,2,'Add type hints',        'merged','2023-03-12','2023-03-18',  80, 10),
 (4,10,11,2,'Add CNN model',         'open',  '2023-03-08', NULL,        350, 50),
 (5, 6,12,6,'New button component',  'closed','2023-03-25', NULL,         40, 10),
 (6, 4, 9,4,'Fix mobile rendering',  'merged','2023-04-05','2023-04-10',  60, 15),
 (7, 1,10,1,'Improve scheduler',     'merged','2023-04-08','2023-04-15', 180, 45),
 (8, 9,12,10,'Reformat SQL examples','open',  '2023-04-20', NULL,         25,  5);

-- ─────────────────────────────────────────────────────────────
--  TASKS
-- ─────────────────────────────────────────────────────────────

-- Q1. [EASY] Write a CTE that calculates each user's total commits.
--     Then SELECT from it to show users with more than 1 commit.



-- Q2. [EASY] Write a CTE to find each repo's total stars from repo_stars table.
--     Note: The repositories table has a 'stars' column — for this exercise,
--     add 3 rows to repo_stars and count from that.
--     (Add: INSERT INTO repo_stars VALUES (1,9,'2023-01-20'),(4,9,'2023-01-25'),(4,10,'2023-02-01');)



-- Q3. [MEDIUM] Use TWO CTEs:
--     - CTE 1: total commits per user
--     - CTE 2: total PRs merged per user
--     Then JOIN them to show users with both commits and merged PRs.



-- Q4. [MEDIUM] Use a CTE to find repos with more than 1000 stars,
--     then join to gh_users to show owner username and follower count.



-- Q5. [MEDIUM] CTE to calculate avg lines_added per merged PR per repo.
--     Show only repos where avg > 100 lines added.



-- Q6. [HARD] Using a CTE, find the most active contributor
--     (by commit count) for each repository.
--     Show repo_name, contributor username, commit_count.



-- Q7. [HARD] Calculate the 30-day rolling commit count per user
--     using a CTE + self-join or window function inside the CTE.



-- Q8. [HARD] Write a CTE chain to compute:
--     Step 1: total contributions (commits + PRs) per user
--     Step 2: rank users by contributions
--     Step 3: show only top 5 contributors



-- Q9. [EXPERT] RECURSIVE CTE: Generate a number series from 1 to 10.
--     Show: n, n*n AS square, n*n*n AS cube.



-- Q10. [EXPERT] RECURSIVE CTE: Model a simple org hierarchy.
--      Create a manager_tree table and traverse it recursively
--      to show each employee's level and full reporting path.
--      (Setup + recursive traversal)

-- Setup for Q10:
DROP TABLE IF EXISTS org_tree;
CREATE TABLE org_tree (
    emp_id     INT PRIMARY KEY,
    emp_name   VARCHAR(80),
    manager_id INT   -- NULL for CEO
);
INSERT INTO org_tree VALUES
 (1,'CEO Alice',    NULL),
 (2,'VP Bob',       1),
 (3,'VP Carol',     1),
 (4,'Manager Dave', 2),
 (5,'Manager Eve',  2),
 (6,'Manager Frank',3),
 (7,'Eng Grace',    4),
 (8,'Eng Henry',    4),
 (9,'Eng Iris',     5),
 (10,'Analyst Jack',6);

-- Now write the recursive CTE to show:
-- emp_name, level (CEO=1, VP=2, Manager=3, Eng/Analyst=4),
-- full path like: 'CEO Alice > VP Bob > Manager Dave > Eng Grace'
