-- ============================================================
--  SQL INTERVIEW PREP — 05: GROUP BY & HAVING  ✅ SOLUTIONS
-- ============================================================
USE ecommerce_db;

-- Q1. Count of sales per region.
SELECT region, COUNT(*) AS sales_count
FROM sales
GROUP BY region;

-- Q2. Total amount per product category.
SELECT product_cat, SUM(amount) AS total_amount
FROM sales
GROUP BY product_cat;

-- Q3. Order count per status (orders table).
SELECT order_status, COUNT(*) AS order_count
FROM orders
GROUP BY order_status;

-- Q4. Salesperson totals, ordered by amount.
SELECT
    salesperson,
    SUM(amount)     AS total_amount,
    SUM(units_sold) AS total_units
FROM sales
GROUP BY salesperson
ORDER BY total_amount DESC;

-- Q5. Average sale amount per channel.
SELECT channel, ROUND(AVG(amount), 2) AS avg_amount
FROM sales
GROUP BY channel;

-- Q6. Regions with total sales > 20,000 (HAVING filters groups).
SELECT region, SUM(amount) AS total_sales
FROM sales
GROUP BY region
HAVING total_sales > 20000;
-- KEY POINT: WHERE filters rows before grouping;
--            HAVING filters groups AFTER aggregation.

-- Q7. Categories where average sale > 3,000.
SELECT product_cat, ROUND(AVG(amount), 2) AS avg_amount
FROM sales
GROUP BY product_cat
HAVING avg_amount > 3000;

-- Q8. Salespersons with more than 4 sales.
SELECT salesperson, COUNT(*) AS sale_count
FROM sales
GROUP BY salesperson
HAVING sale_count > 4;

-- Q9. Region + category combination breakdown.
SELECT
    region,
    product_cat,
    SUM(amount)     AS total_amount,
    SUM(units_sold) AS total_units,
    COUNT(*)        AS number_of_sales
FROM sales
GROUP BY region, product_cat
ORDER BY region ASC, total_amount DESC;

-- Q10. Channels with max single sale > 8,000 AND at least 3 sales.
SELECT
    channel,
    MAX(amount)  AS max_sale,
    COUNT(*)     AS sale_count
FROM sales
GROUP BY channel
HAVING max_sale > 8000 AND sale_count >= 3;

-- Q11. Monthly sales summary.
SELECT
    MONTH(sale_date)              AS month_num,
    DATE_FORMAT(sale_date,'%Y-%m') AS month,
    SUM(amount)                   AS total_amount,
    SUM(units_sold)               AS total_units
FROM sales
GROUP BY month_num, month
ORDER BY month_num ASC;

-- Q12. Salesperson performance label + HAVING filter.
SELECT
    salesperson,
    SUM(amount)  AS total_amount,
    COUNT(*)     AS sale_count,
    CASE
        WHEN SUM(amount) > 20000 THEN 'High Performer'
        ELSE 'Standard'
    END AS performance_label
FROM sales
GROUP BY salesperson
HAVING sale_count >= 3
ORDER BY total_amount DESC;

-- Q13. Regions that sold all 3 categories.
SELECT region
FROM sales
GROUP BY region
HAVING COUNT(DISTINCT product_cat) = 3;

-- Q14. Max sale amount per region (top sale overview).
SELECT region, MAX(amount) AS max_single_sale
FROM sales
GROUP BY region
ORDER BY max_single_sale DESC;

-- Q15. Payment types meeting multiple criteria (orders table).
SELECT
    payment_type,
    COUNT(*)                                           AS order_count,
    ROUND(AVG(total_amount), 2)                        AS avg_amount,
    COUNT(CASE WHEN order_status='delivered' THEN 1 END) AS delivered_count
FROM orders
GROUP BY payment_type
HAVING order_count >= 3
   AND avg_amount > 300
   AND delivered_count >= 1;

-- ── KEY TAKEAWAYS ──────────────────────────────────────────
-- • GROUP BY collapses rows with the same value(s) into one group.
-- • Every column in SELECT must be in GROUP BY or inside an aggregate.
-- • WHERE filters BEFORE grouping; HAVING filters AFTER.
-- • You can alias aggregate results and reference them in HAVING
--   (MySQL extension — not standard SQL).
-- • COUNT(DISTINCT col) inside GROUP BY counts unique values per group.
-- ───────────────────────────────────────────────────────────
