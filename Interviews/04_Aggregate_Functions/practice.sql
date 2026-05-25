-- ============================================================
--  SQL INTERVIEW PREP — 04: Aggregate Functions
--  Level     : Beginner → Intermediate
--  Dataset   : HR / Employee dataset
--              Inspired by Oracle HR schema & Kaggle HR Analytics
--              https://www.kaggle.com/datasets/rhuebner/human-resources-data-set
-- ============================================================

CREATE DATABASE IF NOT EXISTS hr_db;
USE hr_db;

DROP TABLE IF EXISTS salary_history;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
    dept_id    INT PRIMARY KEY,
    dept_name  VARCHAR(80),
    location   VARCHAR(80),
    budget     DECIMAL(12,2)
);

CREATE TABLE employees (
    emp_id       INT PRIMARY KEY AUTO_INCREMENT,
    first_name   VARCHAR(50),
    last_name    VARCHAR(50),
    dept_id      INT,
    job_title    VARCHAR(80),
    salary       DECIMAL(10,2),
    hire_date    DATE,
    gender       CHAR(1),      -- 'M' or 'F'
    age          INT,
    performance  VARCHAR(20),  -- 'Exceeds','Meets','Below'
    is_active    BOOLEAN DEFAULT TRUE
);

CREATE TABLE salary_history (
    hist_id    INT PRIMARY KEY AUTO_INCREMENT,
    emp_id     INT,
    salary     DECIMAL(10,2),
    from_date  DATE,
    to_date    DATE
);

INSERT INTO departments VALUES
 (1,'Engineering',   'San Francisco', 2000000),
 (2,'Marketing',     'New York',       800000),
 (3,'Sales',         'Chicago',       1200000),
 (4,'HR',            'Austin',         400000),
 (5,'Finance',       'Boston',         900000),
 (6,'Data Science',  'Seattle',       1500000);

INSERT INTO employees (first_name,last_name,dept_id,job_title,salary,hire_date,gender,age,performance,is_active) VALUES
 ('Alice','Wang',      1,'Senior Engineer',   120000,'2018-03-15','F',32,'Exceeds',TRUE),
 ('Bob',  'Martinez',  1,'Junior Engineer',    75000,'2021-07-01','M',26,'Meets',  TRUE),
 ('Carol','Johnson',   1,'Lead Engineer',     155000,'2015-09-10','F',38,'Exceeds',TRUE),
 ('David','Lee',       2,'Marketing Manager', 110000,'2017-01-20','M',40,'Meets',  TRUE),
 ('Eva',  'Brown',     2,'Marketing Analyst',  70000,'2020-05-15','F',29,'Meets',  TRUE),
 ('Frank','Garcia',    3,'Sales Executive',    90000,'2019-08-01','M',34,'Exceeds',TRUE),
 ('Grace','Harris',    3,'Sales Executive',    88000,'2019-11-15','F',31,'Meets',  TRUE),
 ('Henry','Clark',     3,'Sales Manager',     130000,'2016-04-01','M',45,'Exceeds',TRUE),
 ('Iris', 'Lewis',     4,'HR Specialist',      65000,'2020-02-28','F',27,'Below',  TRUE),
 ('Jack', 'Robinson',  4,'HR Manager',         95000,'2018-06-10','M',36,'Meets',  TRUE),
 ('Kate', 'Walker',    5,'Financial Analyst',  85000,'2019-03-20','F',33,'Meets',  TRUE),
 ('Liam', 'Hall',      5,'Finance Manager',   140000,'2014-11-01','M',48,'Exceeds',TRUE),
 ('Mia',  'Young',     6,'Data Scientist',    115000,'2020-01-15','F',30,'Exceeds',TRUE),
 ('Noah', 'King',      6,'ML Engineer',       125000,'2019-09-01','M',29,'Exceeds',TRUE),
 ('Olivia','Scott',    6,'Data Analyst',       80000,'2021-04-10','F',25,'Meets',  TRUE),
 ('Paul', 'Green',     1,'DevOps Engineer',    105000,'2018-07-15','M',35,'Meets',  TRUE),
 ('Quinn','Adams',     2,'Content Creator',    60000,'2022-01-10','F',24,'Below',  TRUE),
 ('Ryan', 'Nelson',    3,'Sales Executive',    92000,'2020-10-01','M',28,'Meets',  TRUE),
 ('Sara', 'Carter',    5,'Senior Analyst',    100000,'2017-08-20','F',37,'Exceeds',FALSE),
 ('Tom',  'Mitchell',  1,'Intern Engineer',    45000,'2023-06-01','M',22,'Meets',  TRUE);

INSERT INTO salary_history (emp_id,salary,from_date,to_date) VALUES
 (1, 90000,'2018-03-15','2020-01-01'),(1,105000,'2020-01-01','2022-01-01'),(1,120000,'2022-01-01',NULL),
 (3,120000,'2015-09-10','2018-01-01'),(3,140000,'2018-01-01','2021-01-01'),(3,155000,'2021-01-01',NULL),
 (8,100000,'2016-04-01','2019-01-01'),(8,115000,'2019-01-01','2022-01-01'),(8,130000,'2022-01-01',NULL);

-- ─────────────────────────────────────────────────────────────
--  TASKS
-- ─────────────────────────────────────────────────────────────

-- Q1. [EASY] Count the total number of employees.



-- Q2. [EASY] Find the highest salary in the company.



-- Q3. [EASY] Find the lowest salary in the company.



-- Q4. [EASY] Calculate the average salary of all active employees.



-- Q5. [EASY] What is the total salary payroll for the entire company?



-- Q6. [MEDIUM] Count how many DISTINCT job titles exist in the company.



-- Q7. [MEDIUM] Find the total number of active vs inactive employees.
--     (Hint: COUNT with a condition — COUNT(CASE WHEN…))



-- Q8. [MEDIUM] What is the average age of male vs female employees?
--     Show gender and avg_age.



-- Q9. [MEDIUM] Find the salary range (MAX - MIN) across all employees.
--     Call this column salary_range.



-- Q10. [MEDIUM] What percentage of employees are female?
--      Show as a decimal (e.g., 0.55 = 55%).



-- Q11. [HARD] Count how many employees are in each performance category
--      ('Exceeds', 'Meets', 'Below') using a SINGLE query.
--      Show performance and employee_count.



-- Q12. [HARD] What is the total budget of all departments combined?
--      What is the average budget per department?



-- Q13. [HARD] Find the difference between the highest and average salary
--      (call it "above_average_gap"). How much more do top earners make?



-- Q14. [HARD] Count employees hired before 2020.



-- Q15. [HARD] Among active employees only, find the:
--      - Total headcount
--      - Average salary
--      - Minimum salary
--      - Maximum salary
--      In a single query with aliases.
