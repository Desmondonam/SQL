-- ============================================================
--  SQL INTERVIEW PREP — 20: Advanced Analytics  ✅ SOLUTIONS
-- ============================================================
USE ecommerce_db;

-- Q1. Conversion Funnel.
WITH funnel AS (
    SELECT
        SUM(event_type = 'page_view')   AS views,
        SUM(event_type = 'add_to_cart') AS adds,
        SUM(event_type = 'checkout')    AS checkouts,
        SUM(event_type = 'purchase')    AS purchases
    FROM (
        SELECT customer_id, event_type
        FROM user_events
        GROUP BY customer_id, event_type
    ) deduped
)
SELECT 'page_view'   AS stage, views      AS users, 100.0 AS conv_pct FROM funnel
UNION ALL
SELECT 'add_to_cart', adds,    ROUND(100.0*adds/views, 1)      FROM funnel
UNION ALL
SELECT 'checkout',   checkouts, ROUND(100.0*checkouts/views, 1) FROM funnel
UNION ALL
SELECT 'purchase',  purchases, ROUND(100.0*purchases/views, 1)  FROM funnel;

-- Q2. Cohort Analysis — customers by first purchase month.
WITH first_purchase AS (
    SELECT customer_id, MIN(purchase_date) AS first_order_date
    FROM orders
    WHERE order_status = 'delivered'
    GROUP BY customer_id
)
SELECT
    DATE_FORMAT(first_order_date,'%Y-%m') AS cohort_month,
    COUNT(*) AS cohort_size
FROM first_purchase
GROUP BY cohort_month
ORDER BY cohort_month;

-- Q3. Month-over-month revenue growth.
WITH monthly_rev AS (
    SELECT
        DATE_FORMAT(purchase_date,'%Y-%m') AS month,
        SUM(total_amount) AS revenue
    FROM orders
    GROUP BY month
)
SELECT
    month, revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_revenue,
    ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month)) /
          NULLIF(LAG(revenue) OVER (ORDER BY month),0), 2) AS mom_growth_pct
FROM monthly_rev
ORDER BY month;

-- Q4. YoY comparison — CASE-based pivot on year.
WITH monthly AS (
    SELECT MONTH(purchase_date) AS mo, YEAR(purchase_date) AS yr,
           SUM(total_amount) AS revenue
    FROM orders
    GROUP BY mo, yr
)
SELECT
    mo AS month,
    SUM(CASE WHEN yr=2023 THEN revenue ELSE 0 END) AS revenue_2023,
    SUM(CASE WHEN yr=2022 THEN revenue ELSE 0 END) AS revenue_2022,
    ROUND(100.0 * (SUM(CASE WHEN yr=2023 THEN revenue ELSE 0 END) -
                   SUM(CASE WHEN yr=2022 THEN revenue ELSE 0 END)) /
           NULLIF(SUM(CASE WHEN yr=2022 THEN revenue ELSE 0 END),0), 2) AS yoy_pct
FROM monthly
GROUP BY mo
ORDER BY mo;

-- Q5. Running total + contribution %.
WITH monthly_rev AS (
    SELECT DATE_FORMAT(purchase_date,'%Y-%m') AS month,
           SUM(total_amount) AS revenue
    FROM orders
    GROUP BY month
),
totals AS (
    SELECT SUM(revenue) AS grand_total FROM monthly_rev
)
SELECT
    m.month,
    m.revenue,
    SUM(m.revenue) OVER (ORDER BY m.month ROWS UNBOUNDED PRECEDING) AS running_total,
    ROUND(100.0 * m.revenue / t.grand_total, 2) AS pct_of_total
FROM monthly_rev m, totals t
ORDER BY m.month;

-- Q6. RFM Analysis.
WITH rfm_raw AS (
    SELECT
        customer_id,
        DATEDIFF('2023-12-01', MAX(purchase_date)) AS recency,
        COUNT(*) AS frequency,
        SUM(total_amount) AS monetary
    FROM orders
    GROUP BY customer_id
),
rfm_scored AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY recency DESC) AS r_score,   -- lower recency = more recent = better
        NTILE(4) OVER (ORDER BY frequency)    AS f_score,
        NTILE(4) OVER (ORDER BY monetary)     AS m_score
    FROM rfm_raw
)
SELECT
    customer_id, recency, frequency, ROUND(monetary,2) AS monetary,
    r_score, f_score, m_score,
    CONCAT(r_score, f_score, m_score) AS rfm_segment,
    CASE
        WHEN r_score=4 AND f_score>=3 AND m_score>=3 THEN 'Champion'
        WHEN r_score>=3 AND f_score>=3               THEN 'Loyal Customer'
        WHEN r_score=4 AND f_score<=2                THEN 'New Customer'
        WHEN r_score<=2 AND f_score>=3               THEN 'At Risk'
        ELSE 'Needs Attention'
    END AS rfm_label
FROM rfm_scored
ORDER BY rfm_segment DESC;

-- Q7. Week-1 (month-2) retention.
WITH jan_buyers AS (
    SELECT DISTINCT customer_id FROM orders
    WHERE YEAR(purchase_date)=2023 AND MONTH(purchase_date)=1
),
feb_buyers AS (
    SELECT DISTINCT customer_id FROM orders
    WHERE YEAR(purchase_date)=2023 AND MONTH(purchase_date)=2
)
SELECT
    COUNT(DISTINCT j.customer_id) AS total_jan_buyers,
    COUNT(DISTINCT f.customer_id) AS retained_in_feb,
    ROUND(100.0*COUNT(DISTINCT f.customer_id)/COUNT(DISTINCT j.customer_id),2) AS retention_rate
FROM jan_buyers j
LEFT JOIN feb_buyers f ON j.customer_id = f.customer_id;

-- Q8. First and repeat purchase analysis.
WITH ordered_purchases AS (
    SELECT customer_id, purchase_date,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY purchase_date) AS purchase_num
    FROM orders
    WHERE order_status != 'canceled'
),
first_orders  AS (SELECT customer_id, purchase_date AS first_date  FROM ordered_purchases WHERE purchase_num=1),
second_orders AS (SELECT customer_id, purchase_date AS second_date FROM ordered_purchases WHERE purchase_num=2)
SELECT
    f.customer_id,
    f.first_date,
    s.second_date,
    CASE WHEN s.customer_id IS NOT NULL THEN 'Yes' ELSE 'No' END AS is_repeat_buyer,
    DATEDIFF(s.second_date, f.first_date) AS days_to_repurchase
FROM first_orders f
LEFT JOIN second_orders s ON f.customer_id = s.customer_id
ORDER BY days_to_repurchase;

-- Q9. Product affinity (co-purchased by same customer).
SELECT
    a.product_id AS product_1,
    b.product_id AS product_2,
    COUNT(DISTINCT a.customer_id) AS co_purchase_count
FROM orders a
JOIN orders b
  ON a.customer_id = b.customer_id
  AND a.product_id < b.product_id   -- avoid self-pairs and duplicates
GROUP BY a.product_id, b.product_id
ORDER BY co_purchase_count DESC;

-- Q10. 3-month rolling average + underperformance flag.
WITH monthly_rev AS (
    SELECT DATE_FORMAT(purchase_date,'%Y-%m') AS month,
           SUM(total_amount) AS revenue
    FROM orders
    GROUP BY month
),
with_rolling AS (
    SELECT month, revenue,
        AVG(revenue) OVER (ORDER BY month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_avg_3m
    FROM monthly_rev
)
SELECT
    month, ROUND(revenue,2) AS revenue,
    ROUND(rolling_avg_3m,2) AS rolling_avg_3m,
    CASE WHEN revenue < rolling_avg_3m THEN '⚠ Below Average' ELSE '✓ On Track' END AS signal
FROM with_rolling
ORDER BY month;

-- ── KEY TAKEAWAYS ──────────────────────────────────────────
-- • Funnel analysis: COUNT distinct users at each step + ratio to top-of-funnel.
-- • Cohort analysis: group by first event month; track behavior over time.
-- • MoM/YoY: LAG() or CASE-based pivoting on year; watch for division by zero.
-- • RFM: standard customer segmentation; NTILE gives equal-size quartile buckets.
-- • Retention: LEFT JOIN + IS NULL or COUNT(DISTINCT INTERSECT) approach.
-- • Product affinity: self-join on customer, filter a.id < b.id to avoid dups.
-- • These patterns appear in virtually every data/analytics SQL interview.
-- ───────────────────────────────────────────────────────────
