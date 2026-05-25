-- ============================================================
--  SQL INTERVIEW PREP — 16: Date & Time Functions  ✅ SOLUTIONS
-- ============================================================
USE datetime_db;

-- Q1. Current date/time functions.
SELECT NOW() AS now, CURDATE() AS today, CURTIME() AS time_now;

-- Q2. Extract year, month, day.
SELECT customer_name, started_at,
       YEAR(started_at) AS yr, MONTH(started_at) AS mo, DAY(started_at) AS dy
FROM subscriptions;

-- Q3. Subscription duration in days.
SELECT customer_name, started_at, ends_at,
       DATEDIFF(ends_at, started_at) AS duration_days
FROM subscriptions;

-- Q4. Format date as 'Month DD, YYYY'.
SELECT customer_name,
       DATE_FORMAT(started_at, '%M %d, %Y') AS formatted_start
FROM subscriptions;
-- Common format codes: %Y=4-digit year, %m=2-digit month, %M=month name,
-- %d=2-digit day, %H=hour(24), %i=minutes, %s=seconds

-- Q5. Subscriptions expiring within 30 days of 2023-12-01.
SELECT customer_name, plan, ends_at
FROM subscriptions
WHERE ends_at BETWEEN '2023-12-01' AND DATE_ADD('2023-12-01', INTERVAL 30 DAY)
  AND cancelled_at IS NULL;

-- Q6. Months between start and end.
SELECT customer_name,
       TIMESTAMPDIFF(MONTH, started_at, ends_at) AS months_duration
FROM subscriptions;

-- Q7. Event duration in hours.
SELECT event_name,
       TIMESTAMPDIFF(HOUR, start_dt, end_dt) AS duration_hours
FROM events;

-- Q8. Delivery timing breakdown + SLA breach.
SELECT
    order_ref,
    DATEDIFF(shipped_at,   ordered_at)   AS days_to_ship,
    DATEDIFF(delivered_at, shipped_at)   AS days_to_deliver,
    DATEDIFF(delivered_at, ordered_at)   AS total_days,
    promised_days,
    CASE
        WHEN delivered_at IS NULL                              THEN 'Pending'
        WHEN DATEDIFF(delivered_at,ordered_at) > promised_days THEN 'SLA Breach'
        ELSE 'On Time'
    END AS sla_status
FROM deliveries;

-- Q9. Subscriptions by quarter.
SELECT
    YEAR(started_at)    AS year,
    QUARTER(started_at) AS quarter,
    COUNT(*)            AS total,
    SUM(plan='monthly') AS monthly,
    SUM(plan='yearly')  AS yearly,
    SUM(plan='trial')   AS trial
FROM subscriptions
GROUP BY year, quarter
ORDER BY year, quarter;

-- Q10. Early churners (cancelled within 7 days).
SELECT customer_name, plan, started_at, cancelled_at,
       DATEDIFF(cancelled_at, started_at) AS days_before_cancel
FROM subscriptions
WHERE cancelled_at IS NOT NULL
  AND DATEDIFF(cancelled_at, started_at) <= 7;

-- Q11. Day of week analysis for deliveries.
SELECT
    order_ref, ordered_at,
    DAYNAME(ordered_at)   AS day_name,
    DAYOFWEEK(ordered_at) AS day_num,  -- 1=Sunday, 7=Saturday
    CASE WHEN DAYOFWEEK(ordered_at) IN (1,7) THEN 'Weekend' ELSE 'Weekday' END AS day_type
FROM deliveries;

-- Q12. Monthly subscription signups.
SELECT
    DATE_FORMAT(started_at,'%Y-%m') AS year_month,
    COUNT(*) AS new_subscriptions
FROM subscriptions
GROUP BY year_month
ORDER BY year_month;

-- Q13. Age in years, months, days.
SELECT
    customer_name,
    TIMESTAMPDIFF(YEAR,  started_at, NOW()) AS years_active,
    TIMESTAMPDIFF(MONTH, started_at, NOW()) AS months_active,
    DATEDIFF(NOW(), started_at)             AS days_active
FROM subscriptions;

-- Q14. On-time delivery classification.
SELECT
    order_ref, ordered_at, delivered_at, promised_days,
    DATE_ADD(ordered_at, INTERVAL promised_days DAY) AS deadline,
    CASE
        WHEN delivered_at IS NULL THEN 'Pending'
        WHEN delivered_at <= DATE_ADD(ordered_at, INTERVAL promised_days DAY) THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status
FROM deliveries;

-- Q15. Daily active subscriptions in January 2023 (recursive CTE date series).
WITH RECURSIVE jan_dates AS (
    SELECT CAST('2023-01-01' AS DATE) AS cal_date
    UNION ALL
    SELECT DATE_ADD(cal_date, INTERVAL 1 DAY)
    FROM jan_dates
    WHERE cal_date < '2023-01-31'
)
SELECT
    d.cal_date,
    COUNT(s.sub_id) AS active_subscriptions
FROM jan_dates d
LEFT JOIN subscriptions s
    ON DATE(s.started_at) <= d.cal_date
    AND DATE(s.ends_at)   >  d.cal_date
    AND (s.cancelled_at IS NULL OR DATE(s.cancelled_at) > d.cal_date)
GROUP BY d.cal_date
ORDER BY d.cal_date;

-- ── KEY TAKEAWAYS ──────────────────────────────────────────
-- • NOW()       → current datetime;  CURDATE() → date only;  CURTIME() → time only.
-- • YEAR/MONTH/DAY/HOUR/MINUTE/SECOND → extract parts.
-- • DATEDIFF(end,start)      → days difference.
-- • TIMESTAMPDIFF(unit,s,e)  → difference in any unit (YEAR,MONTH,DAY,HOUR…).
-- • DATE_ADD(date, INTERVAL n UNIT) → add time; DATE_SUB for subtraction.
-- • DATE_FORMAT(dt,'%Y-%m-%d') → custom string representation.
-- • QUARTER(dt) → 1-4; DAYOFWEEK(dt) → 1=Sun .. 7=Sat; DAYNAME → 'Monday' etc.
-- • Recursive CTE is the standard way to generate date series in MySQL.
-- ───────────────────────────────────────────────────────────
