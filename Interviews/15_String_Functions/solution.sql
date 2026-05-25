-- ============================================================
--  SQL INTERVIEW PREP — 15: String Functions  ✅ SOLUTIONS
-- ============================================================
USE string_db;

-- Q1. UPPER and LOWER.
SELECT full_name, UPPER(full_name) AS upper_name, LOWER(full_name) AS lower_name
FROM contacts;

-- Q2. TRIM whitespace + length comparison.
SELECT
    full_name,
    LENGTH(full_name)        AS raw_length,
    LENGTH(TRIM(full_name))  AS trimmed_length,
    TRIM(full_name)          AS cleaned_name
FROM contacts;

-- Q3. Split first and last name.
SELECT
    full_name,
    TRIM(SUBSTRING_INDEX(TRIM(full_name),' ', 1))  AS first_name,
    TRIM(SUBSTRING_INDEX(TRIM(full_name),' ',-1))  AS last_name
FROM contacts;
-- SUBSTRING_INDEX(str, delim, 1) → everything before first delimiter
-- SUBSTRING_INDEX(str, delim,-1) → everything after last delimiter

-- Q4. Extract email domain.
SELECT
    email,
    SUBSTRING_INDEX(email, '@', -1) AS domain
FROM contacts;

-- Q5. Remove non-digits from phone using REGEXP_REPLACE.
SELECT
    phone,
    REGEXP_REPLACE(phone, '[^0-9]', '') AS digits_only
FROM contacts;

-- Q6. Split city_state into city and state.
SELECT
    city_state,
    TRIM(SUBSTRING_INDEX(city_state, ',', 1))  AS city,
    TRIM(SUBSTRING_INDEX(city_state, ',',-1))  AS state_country
FROM contacts;

-- Q7. Contacts with 'vip' tag using FIND_IN_SET.
SELECT contact_id, full_name, tags
FROM contacts
WHERE FIND_IN_SET('vip', tags) > 0;
-- FIND_IN_SET(needle, comma_separated_string) → position (0 if not found)

-- Q8. Username = everything before @.
SELECT
    email,
    SUBSTRING_INDEX(email, '@', 1) AS username
FROM contacts;

-- Q9. Parse pipe-delimited raw_imports.
SELECT
    raw_data,
    -- Clean name: trim whitespace, convert to title-like (CONCAT trick)
    TRIM(SUBSTRING_INDEX(TRIM(raw_data), '|', 1))                              AS clean_name,
    LOWER(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(TRIM(raw_data),'|',2),'|',-1))) AS clean_email,
    REGEXP_REPLACE(TRIM(SUBSTRING_INDEX(TRIM(raw_data), '|', -1)), '[^0-9]','') AS clean_phone
FROM raw_imports;

-- Q10. Formatted mailing label.
SELECT
    contact_id,
    CONCAT_WS(CHAR(10),
        TRIM(full_name),
        address,
        city_state
    ) AS mailing_label
FROM contacts;
-- CHAR(10) = newline character

-- Q11. Emails with non-standard TLD (not .com, .org, .net).
SELECT contact_id, full_name, email
FROM contacts
WHERE email NOT REGEXP '\\.(com|org|net)$';

-- Q12. Collapse multiple spaces + normalise name.
-- Remove extra spaces using REGEXP_REPLACE, then we can display:
SELECT
    full_name                                            AS original,
    REGEXP_REPLACE(TRIM(full_name), '\\s+', ' ')        AS cleaned
FROM contacts;
-- True title-case in MySQL requires a custom function (not built-in).
-- A common interview trick:
SELECT CONCAT(
    UPPER(SUBSTR(TRIM(full_name),1,1)),
    LOWER(SUBSTR(TRIM(full_name),2))
) AS quasi_title_case
FROM contacts;

-- Q13. Count tags per contact.
SELECT
    full_name,
    tags,
    LENGTH(tags) - LENGTH(REPLACE(tags, ',', '')) + 1 AS tag_count
FROM contacts;
-- Logic: subtract length without commas from total → count of commas = count of tags - 1

-- Q14. Position of @ in email.
SELECT
    email,
    LOCATE('@', email)   AS at_position,
    POSITION('@' IN email) AS at_position_alt   -- same result
FROM contacts;

-- Q15. SOUNDEX — find names that sound like 'Alice'.
SELECT
    full_name,
    SOUNDEX(SUBSTRING_INDEX(full_name,' ',1)) AS soundex_code
FROM contacts
WHERE SOUNDEX(SUBSTRING_INDEX(TRIM(full_name),' ',1)) = SOUNDEX('Alice');

-- ── KEY TAKEAWAYS ──────────────────────────────────────────
-- • UPPER/LOWER      → case conversion.
-- • TRIM/LTRIM/RTRIM → remove whitespace.
-- • LENGTH vs CHAR_LENGTH → bytes vs characters (different for UTF-8 multibyte).
-- • SUBSTRING_INDEX(str, delim, n) → split strings.
-- • CONCAT / CONCAT_WS → concatenate (CONCAT_WS ignores NULLs).
-- • FIND_IN_SET(needle, list) → search comma-separated lists.
-- • REGEXP_REPLACE → powerful pattern-based replacement.
-- • LOCATE / POSITION → find substring position.
-- • SOUNDEX → phonetic matching (useful for fuzzy name search).
-- ───────────────────────────────────────────────────────────
