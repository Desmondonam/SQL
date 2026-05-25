-- ============================================================
--  SQL INTERVIEW PREP — 09: CTEs  ✅ SOLUTIONS
-- ============================================================
USE github_db;

-- Q1. User commit totals via CTE.
WITH user_commits AS (
    SELECT user_id, COUNT(*) AS commit_count
    FROM commits
    GROUP BY user_id
)
SELECT u.username, uc.commit_count
FROM user_commits uc
JOIN gh_users u ON uc.user_id = u.user_id
WHERE uc.commit_count > 1
ORDER BY uc.commit_count DESC;

-- Q2. Add sample repo_stars + count per repo.
INSERT IGNORE INTO repo_stars VALUES
 (1,9,'2023-01-20'),(4,9,'2023-01-25'),(4,10,'2023-02-01');

WITH star_counts AS (
    SELECT repo_id, COUNT(*) AS total_stars
    FROM repo_stars
    GROUP BY repo_id
)
SELECT r.repo_name, sc.total_stars
FROM star_counts sc
JOIN repositories r ON sc.repo_id = r.repo_id;

-- Q3. Two CTEs — commits and merged PRs, joined.
WITH commit_totals AS (
    SELECT user_id, COUNT(*) AS total_commits
    FROM commits
    GROUP BY user_id
),
merged_prs AS (
    SELECT author_id AS user_id, COUNT(*) AS pr_count
    FROM pull_requests
    WHERE status = 'merged'
    GROUP BY author_id
)
SELECT
    u.username,
    COALESCE(ct.total_commits, 0) AS commits,
    COALESCE(mp.pr_count,       0) AS merged_prs
FROM gh_users u
JOIN commit_totals ct ON u.user_id = ct.user_id
JOIN merged_prs    mp ON u.user_id = mp.user_id
ORDER BY commits DESC;

-- Q4. High-star repos + owner info.
WITH popular_repos AS (
    SELECT * FROM repositories WHERE stars > 1000
)
SELECT pr.repo_name, pr.stars, pr.language,
       u.username AS owner, u.followers
FROM popular_repos pr
JOIN gh_users u ON pr.owner_id = u.user_id
ORDER BY pr.stars DESC;

-- Q5. Avg lines added per merged PR per repo (> 100).
WITH pr_avg AS (
    SELECT
        repo_id,
        AVG(lines_added) AS avg_lines_added,
        COUNT(*) AS pr_count
    FROM pull_requests
    WHERE status = 'merged'
    GROUP BY repo_id
)
SELECT r.repo_name, pa.avg_lines_added, pa.pr_count
FROM pr_avg pa
JOIN repositories r ON pa.repo_id = r.repo_id
WHERE pa.avg_lines_added > 100;

-- Q6. Top contributor per repo (using ROW_NUMBER inside CTE).
WITH ranked_contributors AS (
    SELECT
        c.repo_id,
        c.user_id,
        COUNT(*) AS commit_count,
        ROW_NUMBER() OVER (PARTITION BY c.repo_id ORDER BY COUNT(*) DESC) AS rn
    FROM commits c
    GROUP BY c.repo_id, c.user_id
)
SELECT r.repo_name, u.username, rc.commit_count
FROM ranked_contributors rc
JOIN repositories r ON rc.repo_id = r.repo_id
JOIN gh_users u     ON rc.user_id = u.user_id
WHERE rc.rn = 1;

-- Q7. Rolling 30-day commit count per user (self-join or window).
WITH daily_commits AS (
    SELECT user_id, commit_date, COUNT(*) AS day_commits
    FROM commits
    GROUP BY user_id, commit_date
),
rolling AS (
    SELECT
        d1.user_id,
        d1.commit_date,
        SUM(d2.day_commits) AS rolling_30d
    FROM daily_commits d1
    JOIN daily_commits d2
      ON d1.user_id = d2.user_id
      AND d2.commit_date BETWEEN DATE_SUB(d1.commit_date, INTERVAL 29 DAY)
                              AND d1.commit_date
    GROUP BY d1.user_id, d1.commit_date
)
SELECT u.username, r.commit_date, r.rolling_30d
FROM rolling r
JOIN gh_users u ON r.user_id = u.user_id
ORDER BY u.username, r.commit_date;

-- Q8. Top 5 contributors by total activity.
WITH contributions AS (
    SELECT user_id,
           COUNT(*) AS total
    FROM (
        SELECT user_id FROM commits
        UNION ALL
        SELECT author_id FROM pull_requests
    ) all_activity
    GROUP BY user_id
),
ranked AS (
    SELECT user_id, total,
           RANK() OVER (ORDER BY total DESC) AS rnk
    FROM contributions
)
SELECT u.username, r.total, r.rnk
FROM ranked r
JOIN gh_users u ON r.user_id = u.user_id
WHERE r.rnk <= 5;

-- Q9. Recursive CTE — number series 1..10.
WITH RECURSIVE num_series AS (
    SELECT 1 AS n           -- anchor
    UNION ALL
    SELECT n + 1            -- recursive step
    FROM num_series
    WHERE n < 10
)
SELECT n, n*n AS square, n*n*n AS cube
FROM num_series;

-- Q10. Recursive CTE — org hierarchy traversal.
USE github_db;
WITH RECURSIVE org_hierarchy AS (
    -- Anchor: start from the root (no manager)
    SELECT
        emp_id,
        emp_name,
        manager_id,
        1 AS level,
        emp_name AS path
    FROM org_tree
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive: join children to parents
    SELECT
        e.emp_id,
        e.emp_name,
        e.manager_id,
        oh.level + 1,
        CONCAT(oh.path, ' > ', e.emp_name)
    FROM org_tree e
    JOIN org_hierarchy oh ON e.manager_id = oh.emp_id
)
SELECT emp_name, level, path
FROM org_hierarchy
ORDER BY path;

-- ── KEY TAKEAWAYS ──────────────────────────────────────────
-- • WITH cte_name AS (query) SELECT … — CTE is like a named subquery.
-- • Multiple CTEs: WITH a AS (…), b AS (…) SELECT … — separate with commas.
-- • CTEs improve readability vs nested subqueries.
-- • CTEs can reference themselves — this is a RECURSIVE CTE.
-- • Recursive CTE has two parts: ANCHOR (base case) + RECURSIVE STEP.
-- • Always include a termination condition (WHERE n < 10) to prevent loops.
-- • MySQL requires WITH RECURSIVE keyword for recursive CTEs.
-- ───────────────────────────────────────────────────────────
