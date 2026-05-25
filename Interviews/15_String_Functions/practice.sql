-- ============================================================
--  SQL INTERVIEW PREP — 15: String Functions
--  Level     : Intermediate
--  Dataset   : Customer contact & product data (mixed real tasks)
-- ============================================================

CREATE DATABASE IF NOT EXISTS string_db;
USE string_db;

DROP TABLE IF EXISTS contacts;
DROP TABLE IF EXISTS raw_imports;

CREATE TABLE contacts (
    contact_id   INT PRIMARY KEY AUTO_INCREMENT,
    full_name    VARCHAR(150),
    email        VARCHAR(200),
    phone        VARCHAR(30),
    address      VARCHAR(250),
    city_state   VARCHAR(100),   -- e.g. "New York, NY"
    tags         VARCHAR(200)    -- comma-separated: "vip,newsletter,promo"
);

CREATE TABLE raw_imports (
    row_id       INT PRIMARY KEY AUTO_INCREMENT,
    raw_data     VARCHAR(300)    -- messy data: "  ALICE JOHNSON | alice@example.com | +1 (555) 123-4567 "
);

INSERT INTO contacts (full_name, email, phone, address, city_state, tags) VALUES
 ('Alice Johnson',   'alice.johnson@gmail.com',   '+1-555-101-2020', '123 Maple St',  'New York, NY',     'vip,newsletter'),
 ('Bob   Smith',     'BOB.SMITH@HOTMAIL.COM',     '(555) 202-3030',  '456 Oak Ave',   'Los Angeles, CA',  'promo'),
 ('carol white',     'carol_white@yahoo.com',     '555.303.4040',    '789 Pine Rd',   'Chicago, IL',      'newsletter,promo,vip'),
 ('DAVID LEE',       'd.lee@company.org',          '+44 20 7946 0958','10 Downing St', 'London, UK',       'vip'),
 ('Eva María García','eva.garcia@empresa.es',     '+34 91 555 1234', 'Calle Mayor 1', 'Madrid, Spain',    'newsletter'),
 ('  Frank  Wu  ',   'frank.wu@startup.io',       '1.888.404.5050',  '1600 Amphitheatre Pkwy','Mountain View, CA','vip,promo'),
 ('Grace O''Brien',  'grace.obrien@email.co.uk',  '07700 900123',    '5 Abbey Road',  'London, UK',       'newsletter'),
 ('Henry Patel',     'hpatel@tech.in',             '+91 98765 43210', '42 Gandhi Nagar','Mumbai, India',   'promo'),
 ('Iris-Anne Kim',   'iris.kim@korea.kr',          '010-1234-5678',   '88 Gangnam-daero','Seoul, Korea',   'vip,newsletter'),
 ('Jack Müller',     'j.mueller@deutsch.de',       '+49 30 12345678', 'Unter den Linden 1','Berlin, Germany','promo');

INSERT INTO raw_imports (raw_data) VALUES
 ('  ALICE JOHNSON | alice@example.com | +1 (555) 123-4567 '),
 ('BOB SMITH|bob@example.com|555-987-6543'),
 ('  Carol White | carol@example.com | (415) 000-1111  '),
 ('DAVID LEE|david@example.com|+44 20 9999 0000');

-- ─────────────────────────────────────────────────────────────
--  TASKS
-- ─────────────────────────────────────────────────────────────

-- Q1. [EASY] Show full_name in UPPERCASE and in lowercase for all contacts.



-- Q2. [EASY] Trim whitespace from full_name (contacts have padded spaces).
--     Show the raw length vs trimmed length.
--     Functions: TRIM, LENGTH, CHAR_LENGTH.



-- Q3. [EASY] Extract the FIRST name and LAST name separately from full_name.
--     Assume format: "First Last" (split on first space).
--     Functions: SUBSTRING_INDEX.



-- Q4. [MEDIUM] Show each contact's email domain (part after @).
--     e.g. 'alice.johnson@gmail.com' → 'gmail.com'



-- Q5. [MEDIUM] Standardise phone numbers: remove all non-digit characters.
--     Show only digits. (Use REGEXP_REPLACE)
--     Expected: '+1-555-101-2020' → '15551012020'



-- Q6. [MEDIUM] Extract city and state/country from city_state column.
--     city_state = 'New York, NY' → city='New York', state='NY'



-- Q7. [MEDIUM] Show contacts whose tags contain 'vip'.
--     The tags column is comma-separated. Use FIND_IN_SET.



-- Q8. [MEDIUM] Generate a username from the email:
--     Take everything before the @ sign.
--     e.g. 'alice.johnson@gmail.com' → 'alice.johnson'



-- Q9. [HARD] Parse the raw_imports table:
--     Split raw_data (pipe-delimited "Name|Email|Phone") into
--     clean_name, clean_email, clean_phone columns.
--     Also trim and proper-case the name.
--     Functions: TRIM, SUBSTRING_INDEX, CONCAT, UPPER, LOWER.



-- Q10. [HARD] Create a formatted mailing label for each contact:
--      Line 1: Full name (title case — first letter of each word capitalised)
--      Line 2: Address
--      Line 3: City_State
--      Combined as a single string with newlines (\n).
--      Hint: CONCAT_WS and CHAR(10) for newline.



-- Q11. [HARD] Find contacts whose email has an unusual TLD
--      (not .com, .org, .net). Use REGEXP.



-- Q12. [EXPERT] Replace all occurrences of multiple spaces in full_name
--      with a single space, and convert to proper Title Case.
--      (Use REGEXP_REPLACE for spaces, then CONCAT + string manipulation.)



-- Q13. [EXPERT] Count how many tags each contact has (comma-separated).
--      Hint: LENGTH(tags) - LENGTH(REPLACE(tags,',','')) + 1



-- Q14. Show the POSITION of '@' in each email address (LOCATE / POSITION).



-- Q15. Show contacts whose full_name SOUNDS LIKE 'Alice' using SOUNDEX.
--      Also show the SOUNDEX code for each name.
