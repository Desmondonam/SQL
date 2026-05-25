-- ============================================================
--  SQL INTERVIEW PREP — 01: Basic SELECT Queries  ✅ SOLUTIONS
--  Level     : Beginner
--  Dataset   : Netflix-inspired Shows & Movies catalog
-- ============================================================
USE netflix_db;

-- Q1. Retrieve ALL columns for every title in the catalog.
SELECT * FROM netflix_titles;

-- Q2. Show only the title, type, and release_year columns.
SELECT title, type, release_year
FROM netflix_titles;

-- Q3. How many titles are in the catalog?
SELECT COUNT(*) AS total_titles
FROM netflix_titles;

-- Q4. Show all DISTINCT content types.
SELECT DISTINCT type
FROM netflix_titles;

-- Q5. Show all titles with a computed column "age", alias original as content_title.
SELECT
    title        AS content_title,
    2024 - release_year AS age
FROM netflix_titles;

-- Q6. List titles with rating aliased as "content_rating".
SELECT
    title,
    rating AS content_rating
FROM netflix_titles;

-- Q7. Title, country, and duration of all Movies.
SELECT title, country, duration
FROM netflix_titles
WHERE type = 'Movie';

-- Q8. Title, type, and release_year of all titles (columns only, no sort).
SELECT title, type, release_year
FROM netflix_titles;

-- Q9. All columns + computed "decade" column.
SELECT
    *,
    FLOOR(release_year / 10) * 10 AS decade
FROM netflix_titles;

-- Q10. Title + "era" label via CASE expression.
SELECT
    title,
    CASE
        WHEN release_year < 2000              THEN 'Classic'
        WHEN release_year BETWEEN 2000 AND 2009 THEN '2000s'
        WHEN release_year BETWEEN 2010 AND 2019 THEN '2010s'
        ELSE 'Recent'
    END AS era
FROM netflix_titles;

-- ── KEY TAKEAWAYS ──────────────────────────────────────────
-- • SELECT *        fetches every column (avoid in production — costly).
-- • SELECT col1, col2 is explicit and preferred.
-- • Column aliases use the AS keyword (optional but best practice).
-- • DISTINCT eliminates duplicate rows in the result set.
-- • Computed columns let you derive values without storing them.
-- • CASE WHEN … END is SQL's if-else; works inside SELECT, WHERE, ORDER BY.
-- ───────────────────────────────────────────────────────────
