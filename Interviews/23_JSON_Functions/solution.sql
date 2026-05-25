-- ============================================================
--  SQL INTERVIEW PREP — 23: JSON Functions  ✅ SOLUTIONS
-- ============================================================
USE json_db;

-- Q1. JSON_EXTRACT (two equivalent syntaxes).
SELECT log_id, endpoint,
       JSON_EXTRACT(request_body, '$.customer_id') AS customer_id_quoted,
       request_body -> '$.customer_id'              AS customer_id_arrow
FROM api_logs WHERE method = 'POST';

-- Q2. User theme and language using ->> (unquoted, removes surrounding quotes).
SELECT user_id, username,
       preferences ->> '$.theme'    AS theme,
       preferences ->> '$.language' AS language
FROM user_preferences;

-- Q3. Extract order_id from response for POST order requests.
SELECT log_id,
       response ->> '$.order_id' AS order_id,
       response ->> '$.status'   AS order_status,
       response ->> '$.total'    AS order_total
FROM api_logs
WHERE endpoint = '/api/orders' AND method = 'POST';

-- Q4. Products with a 'brand' key.
SELECT prod_id, prod_name,
       attributes ->> '$.brand' AS brand
FROM product_attributes
WHERE JSON_CONTAINS_PATH(attributes, 'one', '$.brand');
-- 'one' = at least one of the paths must exist; 'all' = all paths must exist.

-- Q5. Users with email notifications enabled.
SELECT user_id, username,
       preferences ->> '$.notifications.email' AS email_notif
FROM user_preferences
WHERE JSON_EXTRACT(preferences, '$.notifications.email') = true;

-- Q6. JSON_TABLE — unpack colors array into rows.
SELECT p.prod_name, c.color
FROM product_attributes p,
JSON_TABLE(
    p.attributes,
    '$.color[*]'
    COLUMNS (color VARCHAR(50) PATH '$')
) AS c
WHERE JSON_CONTAINS_PATH(p.attributes, 'one', '$.color');

-- Q7. Number of items in each POST order request.
SELECT log_id, endpoint,
       request_body ->> '$.customer_id'            AS customer_id,
       JSON_LENGTH(request_body, '$.items')         AS item_count
FROM api_logs
WHERE endpoint = '/api/orders' AND method = 'POST';

-- Q8. JSON_OBJECT + JSON_ARRAYAGG to build category summary.
SELECT
    category,
    JSON_ARRAYAGG(prod_name) AS product_list
FROM product_attributes
GROUP BY category;

-- With JSON_OBJECT for a richer structure:
SELECT category,
    JSON_OBJECT(
        'count', COUNT(*),
        'products', JSON_ARRAYAGG(prod_name)
    ) AS category_summary
FROM product_attributes
GROUP BY category;

-- Q9. JSON_SET — update alice's preferences.
UPDATE user_preferences
SET preferences = JSON_SET(
    preferences,
    '$.theme',     'light',
    '$.font_size', 14
)
WHERE user_id = 1;

SELECT preferences FROM user_preferences WHERE user_id = 1;

-- Q10. JSON_TABLE on nested array in api_logs.response.
SELECT
    l.log_id,
    p.product_id,
    p.product_name
FROM api_logs l,
JSON_TABLE(
    l.response,
    '$.products[*]'
    COLUMNS (
        product_id   INT          PATH '$.id',
        product_name VARCHAR(100) PATH '$.name'
    )
) AS p
WHERE l.endpoint = '/api/products' AND l.method = 'GET';

-- Q11. Avg duration by method and status code range.
SELECT
    method,
    CASE
        WHEN status_code BETWEEN 200 AND 299 THEN '2xx Success'
        WHEN status_code BETWEEN 400 AND 499 THEN '4xx Client Error'
        WHEN status_code BETWEEN 500 AND 599 THEN '5xx Server Error'
        ELSE 'Other'
    END AS status_range,
    COUNT(*) AS call_count,
    ROUND(AVG(duration_ms),1) AS avg_duration_ms,
    MAX(duration_ms) AS max_duration_ms
FROM api_logs
GROUP BY method, status_range
ORDER BY method, status_range;

-- Q12. Build a single JSON object keyed by username.
SELECT JSON_OBJECTAGG(username, preferences) AS all_preferences
FROM user_preferences;

-- ── KEY TAKEAWAYS ──────────────────────────────────────────
-- • JSON_EXTRACT(col,'$.key') = col->'$.key'  → quoted string output.
-- • col->>'$.key'  → unquoted (strips surrounding double-quotes).
-- • JSON_CONTAINS_PATH(col,'one'/'all','$.path') → check key existence.
-- • JSON_LENGTH(col,'$.array') → count array elements.
-- • JSON_SET(col,'$.key',value) → add/update a key in JSON.
-- • JSON_TABLE(col,'$.arr[*]' COLUMNS(...)) → flatten JSON arrays to rows (MySQL 8+).
-- • JSON_ARRAYAGG  → aggregate rows into a JSON array.
-- • JSON_OBJECTAGG → aggregate rows into a JSON object (key, value pairs).
-- • JSON columns should be indexed with generated columns for WHERE filters:
--   ALTER TABLE t ADD COLUMN brand VARCHAR(50) GENERATED ALWAYS AS (attributes->>'$.brand');
--   CREATE INDEX idx_brand ON t(brand);
-- ───────────────────────────────────────────────────────────
