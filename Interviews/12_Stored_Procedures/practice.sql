-- ============================================================
--  SQL INTERVIEW PREP — 12: Stored Procedures & Functions
--  Level     : Advanced
--  Dataset   : HR database (reusing hr_db)
-- ============================================================

USE hr_db;

-- ─────────────────────────────────────────────────────────────
--  TASKS
-- ─────────────────────────────────────────────────────────────

-- Q1. [EASY] Create a stored procedure called 'get_all_employees'
--     that returns all employee records. CALL it.



-- Q2. [EASY] Create a procedure 'get_dept_employees' with an IN parameter
--     dept_id INT. It should return all employees in that department. CALL it.



-- Q3. [MEDIUM] Create a procedure 'get_salary_stats' with an OUT parameter
--     for min_sal, max_sal, avg_sal for a given department.
--     CALL it and display the output variables.



-- Q4. [MEDIUM] Create a procedure 'give_raise' that:
--     - Accepts emp_id and raise_pct (percentage, e.g. 10 = 10%)
--     - Updates the employee salary by raise_pct %
--     - Inserts a record into salary_history
--     - Returns the old and new salary



-- Q5. [MEDIUM] Create a procedure 'hire_employee' that:
--     - Accepts first_name, last_name, dept_id, job_title, salary, hire_date, gender, age
--     - Validates that dept_id exists in the departments table
--     - If valid, inserts the employee and returns the new emp_id
--     - If dept not found, signals an error



-- Q6. [HARD] Create a procedure 'dept_salary_report' that:
--     - Loops through all departments using a CURSOR
--     - For each department, prints dept_name, headcount, avg_salary
--     - (Use a result set or SELECT inside the loop)



-- Q7. [HARD] Create a stored FUNCTION (not procedure) called 'years_of_service'
--     that accepts a hire_date DATE and returns INT (years worked).
--     Use it in a SELECT query.



-- Q8. [HARD] Create a function 'performance_bonus' that:
--     - Accepts salary DECIMAL and performance VARCHAR
--     - Returns bonus amount:
--       Exceeds → 15% of salary
--       Meets   → 8% of salary
--       Below   → 0
--     Use it in a SELECT to show each employee's bonus.



-- Q9. [EXPERT] Create a procedure 'bulk_raise_by_performance' that:
--     - Gives raises to all active employees based on performance:
--       Exceeds → 12%, Meets → 6%, Below → 0%
--     - Logs each change (old salary, new salary, date) to salary_history
--     - Returns a summary: how many employees got raises and total cost increase



-- Q10. [EXPERT] Create a procedure 'transfer_employee' that:
--      - Accepts emp_id, new_dept_id
--      - Checks the employee exists and new dept exists
--      - Moves the employee to the new department
--      - Logs a message (you can use a transfer_log table you create)
--      - Uses a transaction so it's atomic
