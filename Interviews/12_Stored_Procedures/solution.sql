-- ============================================================
--  SQL INTERVIEW PREP — 12: Stored Procedures  ✅ SOLUTIONS
-- ============================================================
USE hr_db;

-- Q1. Simple procedure — all employees.
DROP PROCEDURE IF EXISTS get_all_employees;
DELIMITER $$
CREATE PROCEDURE get_all_employees()
BEGIN
    SELECT * FROM employees ORDER BY emp_id;
END$$
DELIMITER ;
CALL get_all_employees();

-- Q2. Procedure with IN parameter.
DROP PROCEDURE IF EXISTS get_dept_employees;
DELIMITER $$
CREATE PROCEDURE get_dept_employees(IN p_dept_id INT)
BEGIN
    SELECT emp_id, first_name, last_name, job_title, salary
    FROM employees
    WHERE dept_id = p_dept_id
    ORDER BY salary DESC;
END$$
DELIMITER ;
CALL get_dept_employees(1);   -- Engineering
CALL get_dept_employees(6);   -- Data Science

-- Q3. Procedure with OUT parameters.
DROP PROCEDURE IF EXISTS get_salary_stats;
DELIMITER $$
CREATE PROCEDURE get_salary_stats(
    IN  p_dept_id INT,
    OUT p_min_sal DECIMAL(10,2),
    OUT p_max_sal DECIMAL(10,2),
    OUT p_avg_sal DECIMAL(10,2)
)
BEGIN
    SELECT MIN(salary), MAX(salary), ROUND(AVG(salary),2)
    INTO   p_min_sal, p_max_sal, p_avg_sal
    FROM   employees
    WHERE  dept_id = p_dept_id;
END$$
DELIMITER ;

CALL get_salary_stats(1, @min, @max, @avg);
SELECT @min AS min_salary, @max AS max_salary, @avg AS avg_salary;

-- Q4. Give raise + log to salary_history.
DROP PROCEDURE IF EXISTS give_raise;
DELIMITER $$
CREATE PROCEDURE give_raise(IN p_emp_id INT, IN p_raise_pct DECIMAL(5,2))
BEGIN
    DECLARE v_old_salary DECIMAL(10,2);
    DECLARE v_new_salary DECIMAL(10,2);

    SELECT salary INTO v_old_salary FROM employees WHERE emp_id = p_emp_id;

    SET v_new_salary = ROUND(v_old_salary * (1 + p_raise_pct / 100), 2);

    START TRANSACTION;
        UPDATE employees SET salary = v_new_salary WHERE emp_id = p_emp_id;

        INSERT INTO salary_history (emp_id, salary, from_date, to_date)
        VALUES (p_emp_id, v_old_salary, CURDATE(), NULL);

        -- Close previous open history record
        UPDATE salary_history
        SET to_date = CURDATE()
        WHERE emp_id = p_emp_id AND to_date IS NULL AND salary = v_old_salary;
    COMMIT;

    SELECT v_old_salary AS old_salary, v_new_salary AS new_salary,
           ROUND(v_new_salary - v_old_salary, 2) AS raise_amount;
END$$
DELIMITER ;

CALL give_raise(1, 10);   -- 10% raise for emp_id 1

-- Q5. Hire employee with validation.
DROP PROCEDURE IF EXISTS hire_employee;
DELIMITER $$
CREATE PROCEDURE hire_employee(
    IN p_first VARCHAR(50), IN p_last VARCHAR(50),
    IN p_dept  INT,         IN p_title VARCHAR(80),
    IN p_sal   DECIMAL(10,2), IN p_hire DATE,
    IN p_gender CHAR(1),    IN p_age INT
)
BEGIN
    DECLARE dept_exists INT DEFAULT 0;
    SELECT COUNT(*) INTO dept_exists FROM departments WHERE dept_id = p_dept;

    IF dept_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Department does not exist';
    ELSE
        INSERT INTO employees (first_name,last_name,dept_id,job_title,salary,hire_date,gender,age,performance)
        VALUES (p_first,p_last,p_dept,p_title,p_sal,p_hire,p_gender,p_age,'Meets');

        SELECT LAST_INSERT_ID() AS new_emp_id;
    END IF;
END$$
DELIMITER ;

CALL hire_employee('Zara','Adams',1,'Engineer II',95000,'2024-01-15','F',27);
-- CALL hire_employee('Bad','Hire',99,'Unknown',0,'2024-01-15','M',30); -- triggers error

-- Q6. Cursor loop over departments.
DROP PROCEDURE IF EXISTS dept_salary_report;
DELIMITER $$
CREATE PROCEDURE dept_salary_report()
BEGIN
    DECLARE done   INT DEFAULT FALSE;
    DECLARE v_dept INT;
    DECLARE v_name VARCHAR(80);
    DECLARE cur CURSOR FOR SELECT dept_id, dept_name FROM departments;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;
    dept_loop: LOOP
        FETCH cur INTO v_dept, v_name;
        IF done THEN LEAVE dept_loop; END IF;

        SELECT v_name AS department,
               COUNT(*) AS headcount,
               ROUND(AVG(salary),2) AS avg_salary
        FROM employees
        WHERE dept_id = v_dept;
    END LOOP;
    CLOSE cur;
END$$
DELIMITER ;

CALL dept_salary_report();

-- Q7. Stored FUNCTION — years of service.
DROP FUNCTION IF EXISTS years_of_service;
DELIMITER $$
CREATE FUNCTION years_of_service(p_hire_date DATE) RETURNS INT
DETERMINISTIC
BEGIN
    RETURN FLOOR(DATEDIFF(CURDATE(), p_hire_date) / 365);
END$$
DELIMITER ;

SELECT first_name, last_name, hire_date,
       years_of_service(hire_date) AS years_served
FROM employees
ORDER BY years_served DESC;

-- Q8. Function for performance bonus.
DROP FUNCTION IF EXISTS performance_bonus;
DELIMITER $$
CREATE FUNCTION performance_bonus(p_salary DECIMAL(10,2), p_perf VARCHAR(20))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN CASE p_perf
        WHEN 'Exceeds' THEN ROUND(p_salary * 0.15, 2)
        WHEN 'Meets'   THEN ROUND(p_salary * 0.08, 2)
        ELSE 0.00
    END;
END$$
DELIMITER ;

SELECT first_name, last_name, salary, performance,
       performance_bonus(salary, performance) AS bonus
FROM employees
ORDER BY bonus DESC;

-- Q9. Bulk raise by performance + summary.
DROP PROCEDURE IF EXISTS bulk_raise_by_performance;
DELIMITER $$
CREATE PROCEDURE bulk_raise_by_performance()
BEGIN
    DECLARE v_count INT DEFAULT 0;
    DECLARE v_cost  DECIMAL(12,2) DEFAULT 0;

    START TRANSACTION;
        -- Log old salaries (simplified: for employees getting a raise)
        INSERT INTO salary_history (emp_id, salary, from_date, to_date)
        SELECT emp_id, salary, CURDATE(), NULL
        FROM employees
        WHERE is_active = TRUE AND performance IN ('Exceeds','Meets');

        -- Apply raises
        UPDATE employees
        SET salary = CASE performance
            WHEN 'Exceeds' THEN ROUND(salary * 1.12, 2)
            WHEN 'Meets'   THEN ROUND(salary * 1.06, 2)
            ELSE salary
        END
        WHERE is_active = TRUE;

        -- Capture summary
        SELECT COUNT(*), SUM(salary * CASE performance WHEN 'Exceeds' THEN 0.12 WHEN 'Meets' THEN 0.06 ELSE 0 END)
        INTO v_count, v_cost
        FROM employees WHERE is_active = TRUE AND performance != 'Below';
    COMMIT;

    SELECT v_count AS employees_raised, ROUND(v_cost,2) AS total_additional_cost;
END$$
DELIMITER ;

CALL bulk_raise_by_performance();

-- Q10. Transfer employee (atomic, with logging).
DROP TABLE IF EXISTS transfer_log;
CREATE TABLE transfer_log (
    log_id     INT PRIMARY KEY AUTO_INCREMENT,
    emp_id     INT,
    old_dept   INT,
    new_dept   INT,
    xfer_date  DATE DEFAULT (CURDATE()),
    notes      VARCHAR(200)
);

DROP PROCEDURE IF EXISTS transfer_employee;
DELIMITER $$
CREATE PROCEDURE transfer_employee(IN p_emp_id INT, IN p_new_dept INT)
BEGIN
    DECLARE v_old_dept  INT;
    DECLARE emp_exists  INT DEFAULT 0;
    DECLARE dept_exists INT DEFAULT 0;

    SELECT COUNT(*) INTO emp_exists  FROM employees  WHERE emp_id  = p_emp_id;
    SELECT COUNT(*) INTO dept_exists FROM departments WHERE dept_id = p_new_dept;

    IF emp_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee not found';
    ELSEIF dept_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Target department not found';
    ELSE
        SELECT dept_id INTO v_old_dept FROM employees WHERE emp_id = p_emp_id;

        START TRANSACTION;
            UPDATE employees SET dept_id = p_new_dept WHERE emp_id = p_emp_id;
            INSERT INTO transfer_log (emp_id, old_dept, new_dept, notes)
                VALUES (p_emp_id, v_old_dept, p_new_dept, 'Department transfer');
        COMMIT;

        SELECT CONCAT('Employee ',p_emp_id,' transferred from dept ',v_old_dept,' to ',p_new_dept) AS result;
    END IF;
END$$
DELIMITER ;

CALL transfer_employee(5, 6);   -- Transfer Eve to Data Science

-- ── KEY TAKEAWAYS ──────────────────────────────────────────
-- • DELIMITER $$ avoids confusion with ; inside procedure body.
-- • IN = input param; OUT = output param; INOUT = both.
-- • DECLARE variables BEFORE any executable statements.
-- • FUNCTION returns a value; PROCEDURE does not (but can use OUT params).
-- • CURSOR + LOOP = row-by-row processing (avoid for large sets — use set-based SQL).
-- • SIGNAL SQLSTATE raises a user-defined error.
-- • CONTINUE HANDLER FOR NOT FOUND handles cursor exhaustion.
-- ───────────────────────────────────────────────────────────
