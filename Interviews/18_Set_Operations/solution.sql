-- ============================================================
--  SQL INTERVIEW PREP — 18: Set Operations  ✅ SOLUTIONS
-- ============================================================
USE sets_db;

-- Q1. UNION — all 3 quarters, deduplicated.
SELECT * FROM sales_q1
UNION
SELECT * FROM sales_q2
UNION
SELECT * FROM sales_q3;

-- Q2. UNION ALL — keeps all rows (faster, no dedup).
SELECT * FROM sales_q1
UNION ALL
SELECT * FROM sales_q2
UNION ALL
SELECT * FROM sales_q3;
-- Use UNION ALL when: duplicates don't matter, or you know there are none.
-- Use UNION    when: you need to deduplicate across data sets.

-- Q3. Total sales per region across all quarters.
SELECT region, SUM(amount) AS total_sales
FROM (
    SELECT region, amount FROM sales_q1
    UNION ALL
    SELECT region, amount FROM sales_q2
    UNION ALL
    SELECT region, amount FROM sales_q3
) all_sales
GROUP BY region
ORDER BY total_sales DESC;

-- Q4. Unique customers in Q1 OR Q2.
SELECT customer FROM sales_q1
UNION
SELECT customer FROM sales_q2;
-- UNION deduplicates — each customer appears once.

-- Q5. INTERSECT — products in BOTH catalogs.
-- MySQL 8.0.31+:
SELECT product_sku FROM catalog_us
INTERSECT
SELECT product_sku FROM catalog_eu;

-- Older MySQL alternative (INNER JOIN):
SELECT us.product_sku, us.product_name
FROM catalog_us us
INNER JOIN catalog_eu eu ON us.product_sku = eu.product_sku;

-- Q6. EXCEPT — in US but NOT in EU.
-- MySQL 8.0.31+:
SELECT product_sku FROM catalog_us
EXCEPT
SELECT product_sku FROM catalog_eu;

-- Anti-join alternative (always works):
SELECT us.product_sku, us.product_name, us.price_usd
FROM catalog_us us
LEFT JOIN catalog_eu eu ON us.product_sku = eu.product_sku
WHERE eu.product_sku IS NULL;

-- Q7. In EU but NOT in US (reverse except).
SELECT eu.product_sku, eu.product_name, eu.price_eur
FROM catalog_eu eu
LEFT JOIN catalog_us us ON eu.product_sku = us.product_sku
WHERE us.product_sku IS NULL;

-- Q8. Customer total spend across all quarters.
SELECT customer, SUM(amount) AS total_spend
FROM (
    SELECT customer, amount FROM sales_q1
    UNION ALL
    SELECT customer, amount FROM sales_q2
    UNION ALL
    SELECT customer, amount FROM sales_q3
) all_sales
GROUP BY customer
ORDER BY total_spend DESC;

-- Q9. Customers in ALL THREE quarters.
-- MySQL 8.0.31+:
SELECT customer FROM sales_q1
INTERSECT
SELECT customer FROM sales_q2
INTERSECT
SELECT customer FROM sales_q3;

-- Alternative (always works):
SELECT customer FROM sales_q1
WHERE customer IN (SELECT customer FROM sales_q2)
  AND customer IN (SELECT customer FROM sales_q3);

-- Q10. Q1 customers not in Q3 (lapsed).
-- EXCEPT approach:
SELECT customer FROM sales_q1
EXCEPT
SELECT customer FROM sales_q3;

-- NOT EXISTS alternative:
SELECT DISTINCT customer FROM sales_q1 q1
WHERE NOT EXISTS (
    SELECT 1 FROM sales_q3 q3 WHERE q3.customer = q1.customer
);

-- Q11. Symmetric difference (US-only OR EU-only, not shared).
SELECT product_sku, product_name, 'US Only' AS source
FROM catalog_us
WHERE product_sku NOT IN (SELECT product_sku FROM catalog_eu)
UNION ALL
SELECT product_sku, product_name, 'EU Only' AS source
FROM catalog_eu
WHERE product_sku NOT IN (SELECT product_sku FROM catalog_us)
ORDER BY source, product_sku;

-- Q12. UNION with literal column + summary row.
SELECT customer, amount, sale_date, 'Q1' AS quarter FROM sales_q1
UNION ALL
SELECT customer, amount, sale_date, 'Q2' AS quarter FROM sales_q2
UNION ALL
SELECT 'ALL', SUM(amount), NULL, 'TOTAL'
FROM (
    SELECT amount FROM sales_q1
    UNION ALL SELECT amount FROM sales_q2
) combined;

-- ── KEY TAKEAWAYS ──────────────────────────────────────────
-- • UNION       → combines + deduplicates (sorts rows internally — slower).
-- • UNION ALL   → combines without dedup (faster, use when safe).
-- • INTERSECT   → rows in BOTH queries; MySQL 8.0.31+; else use INNER JOIN.
-- • EXCEPT      → rows in first but NOT second; MySQL 8.0.31+; else LEFT JOIN + IS NULL.
-- • All UNION queries must have the same number of columns + compatible types.
-- • Column names come from the FIRST SELECT in a UNION.
-- • Pad missing columns with NULL or literal values.
-- • Symmetric difference = (A ∪ B) − (A ∩ B) = A-only UNION ALL B-only.
-- ───────────────────────────────────────────────────────────
