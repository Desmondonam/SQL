-- ============================================================
--  SQL INTERVIEW PREP — 22: Recursive Queries  ✅ SOLUTIONS
-- ============================================================
USE recursive_db;

-- Q1. Org hierarchy with level and manager name.
WITH RECURSIVE org AS (
    SELECT emp_id, emp_name, title, manager_id, 1 AS level, CAST(NULL AS CHAR(80)) AS manager_name
    FROM employees_hier WHERE manager_id IS NULL
    UNION ALL
    SELECT e.emp_id, e.emp_name, e.title, e.manager_id, o.level+1, o.emp_name
    FROM employees_hier e
    JOIN org o ON e.manager_id = o.emp_id
)
SELECT level, emp_name, title, manager_name
FROM org
ORDER BY level, emp_name;

-- Q2. Full reporting chain / path.
WITH RECURSIVE org_path AS (
    SELECT emp_id, emp_name, manager_id,
           CAST(emp_name AS CHAR(500)) AS path
    FROM employees_hier WHERE manager_id IS NULL
    UNION ALL
    SELECT e.emp_id, e.emp_name, e.manager_id,
           CONCAT(op.path, ' > ', e.emp_name)
    FROM employees_hier e
    JOIN org_path op ON e.manager_id = op.emp_id
)
SELECT emp_name, path FROM org_path ORDER BY path;

-- Q3. All reports under Marcus Lee.
WITH RECURSIVE marcus_team AS (
    -- Anchor: Marcus himself (level 1)
    SELECT emp_id, emp_name, title, 1 AS relative_level
    FROM employees_hier
    WHERE emp_name = 'Marcus Lee'

    UNION ALL

    -- Recursive: direct and indirect reports
    SELECT e.emp_id, e.emp_name, e.title, mt.relative_level + 1
    FROM employees_hier e
    JOIN marcus_team mt ON e.manager_id = mt.emp_id
)
SELECT emp_name, title, relative_level
FROM marcus_team
WHERE emp_name != 'Marcus Lee'   -- exclude Marcus himself
ORDER BY relative_level, emp_name;

-- Q4. Total headcount under each manager (subtree size).
WITH RECURSIVE all_reports AS (
    SELECT emp_id, manager_id FROM employees_hier
    UNION ALL
    SELECT e.emp_id, ar.manager_id
    FROM employees_hier e
    JOIN all_reports ar ON e.manager_id = ar.emp_id
)
SELECT
    m.emp_name AS manager,
    COUNT(ar.emp_id) - 1 AS total_reports   -- subtract 1 to exclude self
FROM employees_hier m
JOIN all_reports ar ON m.emp_id = ar.manager_id
GROUP BY m.emp_id, m.emp_name
HAVING total_reports > 0
ORDER BY total_reports DESC;

-- Q5. Deepest employee + full path.
WITH RECURSIVE org_path AS (
    SELECT emp_id, emp_name, manager_id, 1 AS lvl,
           CAST(emp_name AS CHAR(500)) AS path
    FROM employees_hier WHERE manager_id IS NULL
    UNION ALL
    SELECT e.emp_id, e.emp_name, e.manager_id, op.lvl+1,
           CONCAT(op.path,' > ',e.emp_name)
    FROM employees_hier e
    JOIN org_path op ON e.manager_id = op.emp_id
)
SELECT emp_name, lvl AS depth, path
FROM org_path
WHERE lvl = (SELECT MAX(lvl) FROM org_path)
ORDER BY path;

-- Q6. Bill of Materials explosion (all levels).
WITH RECURSIVE bom_tree AS (
    SELECT component_id, component_name, parent_id, quantity, unit_cost, 1 AS lvl,
           CAST(component_name AS CHAR(500)) AS path
    FROM bom WHERE parent_id IS NULL
    UNION ALL
    SELECT b.component_id, b.component_name, b.parent_id, b.quantity, b.unit_cost,
           bt.lvl+1, CONCAT(bt.path,' > ',b.component_name)
    FROM bom b
    JOIN bom_tree bt ON b.parent_id = bt.component_id
)
SELECT
    REPEAT('  ', lvl-1) AS indent,
    component_name, lvl AS level, quantity, unit_cost, path
FROM bom_tree
ORDER BY path;

-- Q7. Total build cost with quantity multiplication.
WITH RECURSIVE bom_cost AS (
    -- Anchor: top-level product, cumulative qty = 1
    SELECT component_id, component_name, parent_id, unit_cost,
           CAST(1 AS DECIMAL(10,2)) AS cumulative_qty,
           unit_cost AS cumulative_cost
    FROM bom WHERE parent_id IS NULL
    UNION ALL
    SELECT b.component_id, b.component_name, b.parent_id, b.unit_cost,
           bc.cumulative_qty * b.quantity,
           bc.cumulative_qty * b.quantity * b.unit_cost
    FROM bom b
    JOIN bom_cost bc ON b.parent_id = bc.component_id
)
SELECT
    component_name, cumulative_qty AS qty_needed, unit_cost,
    ROUND(cumulative_cost, 2) AS total_line_cost
FROM bom_cost
ORDER BY cumulative_cost DESC;

-- Grand total:
WITH RECURSIVE bom_cost AS (
    SELECT component_id, unit_cost, CAST(1 AS DECIMAL(10,2)) AS cumulative_qty
    FROM bom WHERE parent_id IS NULL
    UNION ALL
    SELECT b.component_id, b.unit_cost, bc.cumulative_qty * b.quantity
    FROM bom b JOIN bom_cost bc ON b.parent_id = bc.component_id
)
SELECT ROUND(SUM(cumulative_qty * unit_cost), 2) AS total_build_cost FROM bom_cost;

-- Q8. Date series + hire count per month.
WITH RECURSIVE dates AS (
    SELECT CAST('2023-01-01' AS DATE) AS dt
    UNION ALL
    SELECT DATE_ADD(dt, INTERVAL 1 MONTH) FROM dates WHERE dt < '2023-12-01'
),
hire_counts AS (
    SELECT DATE_FORMAT(hire_date,'%Y-%m') AS hire_month, COUNT(*) AS hires
    FROM employees_hier
    WHERE YEAR(hire_date) BETWEEN 2019 AND 2022
    GROUP BY hire_month
)
SELECT DATE_FORMAT(d.dt,'%Y-%m') AS month,
       COALESCE(h.hires, 0) AS employees_hired
FROM dates d
LEFT JOIN hire_counts h ON DATE_FORMAT(d.dt,'%Y-%m') = h.hire_month
ORDER BY d.dt;

-- Q9. Employees in the same reporting chain.
WITH RECURSIVE ancestors AS (
    SELECT emp_id, emp_id AS root_id FROM employees_hier
    UNION ALL
    SELECT e.emp_id, a.root_id
    FROM employees_hier e
    JOIN ancestors a ON e.manager_id = a.emp_id
)
SELECT DISTINCT a1.root_id AS emp_a, a2.root_id AS emp_b
FROM ancestors a1
JOIN ancestors a2 ON a1.emp_id = a2.emp_id AND a1.root_id < a2.root_id
ORDER BY emp_a, emp_b;

-- Q10. Cycle detection via path string.
WITH RECURSIVE safe_hierarchy AS (
    SELECT emp_id, manager_id, CAST(emp_id AS CHAR(500)) AS visited_ids, FALSE AS cycle_detected
    FROM employees_hier WHERE manager_id IS NULL
    UNION ALL
    SELECT e.emp_id, e.manager_id,
           CONCAT(sh.visited_ids, ',', e.emp_id),
           FIND_IN_SET(e.emp_id, sh.visited_ids) > 0
    FROM employees_hier e
    JOIN safe_hierarchy sh ON e.manager_id = sh.emp_id
    WHERE NOT sh.cycle_detected   -- stop recursion if cycle found
)
SELECT emp_id, visited_ids, cycle_detected
FROM safe_hierarchy
WHERE cycle_detected = TRUE;
-- If empty result: no cycles. Good!

-- ── KEY TAKEAWAYS ──────────────────────────────────────────
-- • WITH RECURSIVE cte AS (anchor UNION ALL recursive) — two-part structure.
-- • Anchor = base case (no recursion). Recursive step builds on prior result.
-- • Always include a termination condition (WHERE parent IS NULL, WHERE depth < n).
-- • Track a PATH string to: a) build readable paths b) detect cycles.
-- • Use CAST() for path strings — MySQL requires explicit type in anchor.
-- • BOM explosion = standard recursive pattern for manufacturing/supply chain.
-- • Org hierarchy traversal is one of the most common recursive interview scenarios.
-- ───────────────────────────────────────────────────────────
