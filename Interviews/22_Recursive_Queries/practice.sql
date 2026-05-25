-- ============================================================
--  SQL INTERVIEW PREP — 22: Recursive Queries
--  Level     : Expert
--  Dataset   : Organization hierarchy + Bill of Materials
--  Covers    : WITH RECURSIVE, hierarchical data traversal
-- ============================================================

CREATE DATABASE IF NOT EXISTS recursive_db;
USE recursive_db;

DROP TABLE IF EXISTS bom;
DROP TABLE IF EXISTS employees_hier;

-- Organization hierarchy
CREATE TABLE employees_hier (
    emp_id      INT PRIMARY KEY,
    emp_name    VARCHAR(80),
    title       VARCHAR(80),
    dept        VARCHAR(50),
    salary      DECIMAL(10,2),
    manager_id  INT,    -- NULL for CEO
    hire_date   DATE
);

INSERT INTO employees_hier VALUES
 (1, 'Sarah Chen',    'CEO',                'Executive', 350000, NULL,  '2015-01-01'),
 (2, 'Marcus Lee',    'VP Engineering',     'Engineering',200000, 1,    '2016-03-15'),
 (3, 'Priya Sharma',  'VP Marketing',       'Marketing',  180000, 1,    '2016-06-01'),
 (4, 'Tom Rivera',    'VP Finance',         'Finance',    190000, 1,    '2017-02-01'),
 (5, 'Amy Zhang',     'Sr. Eng Manager',    'Engineering',150000, 2,    '2017-08-01'),
 (6, 'James Kim',     'Eng Manager',        'Engineering',130000, 2,    '2018-01-15'),
 (7, 'Linda Park',    'Marketing Manager',  'Marketing',  120000, 3,    '2018-05-01'),
 (8, 'Eric Brown',    'Finance Manager',    'Finance',    125000, 4,    '2018-09-01'),
 (9, 'Nina Patel',    'Senior Engineer',    'Engineering',110000, 5,    '2019-02-01'),
 (10,'Carlos Ortiz',  'Senior Engineer',    'Engineering',108000, 5,    '2019-04-15'),
 (11,'Kate Murphy',   'Engineer',           'Engineering', 90000, 6,    '2020-01-01'),
 (12,'Ryan Chang',    'Engineer',           'Engineering', 88000, 6,    '2020-03-01'),
 (13,'Sophia Liu',    'Marketing Analyst',  'Marketing',   75000, 7,    '2020-07-01'),
 (14,'Daniel Torres', 'Financial Analyst',  'Finance',     72000, 8,    '2021-01-01'),
 (15,'Mia Johnson',   'Junior Engineer',    'Engineering', 70000, 11,   '2022-06-01');

-- Bill of Materials (manufacturing parts tree)
CREATE TABLE bom (
    component_id   INT PRIMARY KEY,
    component_name VARCHAR(100),
    parent_id      INT,      -- NULL = top-level product
    quantity       INT,      -- quantity of this component needed per parent
    unit_cost      DECIMAL(10,2)
);

INSERT INTO bom VALUES
 (1, 'Laptop Computer', NULL, 1,  0.00),
 (2, 'Motherboard',     1,    1,  280.00),
 (3, 'CPU',             2,    1,  350.00),
 (4, 'RAM Module',      2,    2,   40.00),
 (5, 'SSD Storage',     2,    1,   80.00),
 (6, 'Display Assembly',1,    1,  150.00),
 (7, 'LCD Panel',       6,    1,   90.00),
 (8, 'Backlight',       7,    1,   20.00),
 (9, 'Battery Pack',    1,    1,   60.00),
 (10,'Battery Cell',    9,    6,    8.00),
 (11,'Keyboard',        1,    1,   35.00),
 (12,'Key Switch',      11,   80,   0.30),
 (13,'Chassis',         1,    1,   45.00),
 (14,'Hinge Assembly',  13,   2,   12.00);

-- ─────────────────────────────────────────────────────────────
--  TASKS
-- ─────────────────────────────────────────────────────────────

-- Q1. [MEDIUM] Write a recursive CTE to show the complete org hierarchy.
--     Show: emp_name, title, level (CEO=1), and manager's name.
--     Sort by level, then by emp_name within each level.



-- Q2. [MEDIUM] Show the full reporting chain (path) for each employee.
--     e.g. "Sarah Chen > Marcus Lee > Amy Zhang > Nina Patel"



-- Q3. [HARD] Find all direct and indirect reports of 'Marcus Lee' (VP Eng).
--     Show: emp_name, title, level (relative to Marcus = level 1).



-- Q4. [HARD] Count the total number of people each manager is responsible for
--     (entire subtree — direct + indirect reports).



-- Q5. [HARD] Find the deepest level of the hierarchy.
--     Who is the deepest employee? Show their full path.



-- Q6. [HARD] Bill of Materials explosion:
--     Show all components needed to build one Laptop Computer,
--     at ALL levels (direct parts + sub-parts of sub-parts).
--     Show: component_name, level, path, cumulative unit_cost.



-- Q7. [EXPERT] Calculate the total cost to build one Laptop Computer,
--     considering quantities at each level.
--     (Recursive quantity multiplication: parent_qty * component_qty at each level)



-- Q8. [EXPERT] Generate a date series from 2023-01-01 to 2023-12-31
--     using a recursive CTE. Then count how many employees were hired
--     each month in 2019–2022.



-- Q9. [EXPERT] Find employees who are in the SAME reporting chain
--     (either one manages the other, directly or indirectly).
--     Example: Sarah → Marcus → Amy → Nina. All of these are in Nina's chain.



-- Q10. [EXPERT] Detect if there are any CYCLES in the org hierarchy
--      (a rare but real data quality problem where manager_id loops back).
--      Add a path-tracking approach to detect cycles before they cause infinite loops.
