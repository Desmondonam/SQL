-- create the dataset and the set up
CREATE DATABASE product_analytics_pds;
USE product_analytics_pds;

-- Create Products Table
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

-- Insert data

INSERT INTO products VALUES
(1, 'Wireless Mouse', 'Electronics', 29.99),
(2, 'Laptop Stand', 'Accessories', 49.99),
(3, 'USB-C Cable', 'Accessories', 12.99),
(4, 'Mechanical Keyboard', 'Electronics', 89.99),
(5, 'Monitor 27"', 'Electronics', 299.99);

-- look at the products table
SELECT * FROM products;

-- Create Orders Table
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    user_id INT,
    product_id INT,
    quantity INT,
    order_date DATE
);

INSERT INTO orders VALUES
(101, 1001, 1, 2, '2024-01-15'),
(102, 1002, 3, 1, '2024-01-16'),
(103, 1001, 4, 1, '2024-01-17'),
(104, 1003, 2, 3, '2024-01-18'),
(105, 1004, 6, 1, '2024-01-19');  -- product_id 6 doesn't exist!

-- query the orders table
SELECT * FROM orders;

-- Create Users Table
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    user_name VARCHAR(100),
    country VARCHAR(50),
    signup_date DATE
);

INSERT INTO users VALUES
(1001, 'Alice Johnson', 'USA', '2023-12-01'),
(1002, 'Bob Smith', 'Canada', '2024-01-05'),
(1003, 'Carol Lee', 'UK', '2023-11-20'),
(1005, 'David Chen', 'Australia', '2024-01-10');  -- No orders yet

-- Query the users tables
SELECT * FROM users;


-- Create Product Reviews Table
CREATE TABLE reviews (
    review_id INT PRIMARY KEY,
    product_id INT,
    user_id INT,
    rating INT,
    review_text TEXT
);

INSERT INTO reviews VALUES
(1, 1, 1001, 5, 'Great mouse, very responsive'),
(2, 3, 1002, 4, 'Good quality cable'),
(3, 4, 1001, 5, 'Best keyboard I have owned'),
(4, 2, 1003, 3, 'Decent stand but a bit wobbly');

-- query the reviews table
SELECT * FROM reviews;

-- inner joins

/*
What it does: Returns only rows where there's a match in BOTH tables.
When to use: When you only care about records that exist in both tables.
*/

/* 
Before any joins ask the question

1. What is my Main table
2. What extra information do I need
3. Do I want to keep unmatched rows

-> THis helps you determing the type of join to use

*/

-- Inner join to see the amount spent on each order of the products

SELECT 
    o.order_id,
    o.user_id,
    p.product_name,
    p.category,
    p.price,
    o.quantity,
    (p.price * o.quantity) AS total_amount
FROM orders o
INNER JOIN products p ON o.product_id = p.product_id;



/*
Notice: Order 105 (product_id 6) is missing because that product doesn't exist!
*/
-- Get the total revenue from each product category, number of items sold and total orders made
SELECT 
    p.category,
    COUNT(o.order_id) AS total_orders,
    SUM(o.quantity) AS units_sold,
    ROUND(SUM(p.price * o.quantity), 2) AS total_revenue
FROM orders o
INNER JOIN products p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

/*
2. LEFT JOIN (LEFT OUTER JOIN) - Keep Everything from the Left
What it does: Returns ALL rows from the left table, with matching rows from the right table (or NULL if no match).
When to use: When you want all records from your primary table, even if they don't have matches.
*/

-- example coalese
SELECT COALESCE(NULL, NULL, "Hello");

-- Replacing null values
SELECT 
	COALESCE(discount, 0) AS discount_fixed
FROM orders;

-- Left Join
-- What products were sold, how many units were sold, how many oders were made.
SELECT 
    p.product_id,
    p.product_name,
    COUNT(o.order_id) AS times_ordered,
    COALESCE(SUM(o.quantity), 0) AS total_units_sold
FROM products p
LEFT JOIN orders o ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_units_sold DESC;

-- Product Analytics Use Case: Finding Products with No Sales
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price
FROM products p
LEFT JOIN orders o ON p.product_id = o.product_id
WHERE o.order_id IS NULL;

-- This identifies inventory that isn't moving - critical for product decisions!

/* 3. RIGHT JOIN (RIGHT OUTER JOIN) - Keep Everything from the Right
What it does: Returns ALL rows from the right table, with matching rows from the left table (or NULL if no match).
When to use: Less common, but useful when your main focus is the second table. Can always be rewritten as a LEFT JOIN.

*/
SELECT 
    o.order_id,
    o.product_id,
    p.product_name,
    o.quantity
FROM products p
RIGHT JOIN orders o ON p.product_id = o.product_id;


-- Pro Tip: Most data scientists prefer LEFT JOIN and just swap table order. It's more readable.

/* 4. FULL OUTER JOIN - Everything from Both Tables
What it does: Returns ALL rows from both tables, matching where possible, NULL where not.
MySQL Note: MySQL doesn't support FULL OUTER JOIN directly, but we can simulate it with UNION.
*/
-- Simulating FULL OUTER JOIN in MySQL
SELECT 
    p.product_id,
    p.product_name,
    o.order_id,
    o.quantity
FROM products p
LEFT JOIN orders o ON p.product_id = o.product_id

UNION

SELECT 
    p.product_id,
    p.product_name,
    o.order_id,
    o.quantity
FROM products p
RIGHT JOIN orders o ON p.product_id = o.product_id;
-- When to use: Auditing and data reconciliation - finding orphaned records in both tables.
/* 5. CROSS JOIN - The Cartesian Product
What it does: Returns EVERY combination of rows from both tables.
When to use: Generating combinations, filling gaps in time series, or creating test data.
*/
SELECT 
    u.user_id,
    u.user_name,
    p.product_id,
    p.product_name
FROM users u
CROSS JOIN products p
LIMIT 10;

-- Product Analytics Use Case: Finding Missing Product-User Combinations
-- Which products has each user NOT purchased?
SELECT 
    u.user_id,
    u.user_name,
    p.product_id,
    p.product_name
FROM users u
CROSS JOIN products p
WHERE NOT EXISTS (
    SELECT 1 
    FROM orders o 
    WHERE o.user_id = u.user_id 
    AND o.product_id = p.product_id
)
ORDER BY u.user_id, p.product_id;

-- Use with caution: With 1000 users and 1000 products, you get 1,000,000 rows!
/*
6. SELF JOIN - Joining a Table to Itself
What it does: Compares rows within the same table.
When to use: Hierarchical data, comparing related records, finding duplicates.
*/
SELECT DISTINCT
    o1.user_id AS user1_id,
    o2.user_id AS user2_id,
    o1.product_id,
    p.product_name
FROM orders o1
INNER JOIN orders o2 ON o1.product_id = o2.product_id 
    AND o1.user_id < o2.user_id  -- Avoid duplicate pairs
INNER JOIN products p ON o1.product_id = p.product_id
ORDER BY o1.product_id;

-- Product Analytics Use Case: Product Affinity Analysis
-- What products are bought together by the same user?
SELECT 
    o1.product_id AS product_a,
    p1.product_name AS product_a_name,
    o2.product_id AS product_b,
    p2.product_name AS product_b_name,
    COUNT(DISTINCT o1.user_id) AS co_purchase_count
FROM orders o1
INNER JOIN orders o2 ON o1.user_id = o2.user_id 
    AND o1.product_id < o2.product_id
INNER JOIN products p1 ON o1.product_id = p1.product_id
INNER JOIN products p2 ON o2.product_id = p2.product_id
GROUP BY o1.product_id, p1.product_name, o2.product_id, p2.product_name
ORDER BY co_purchase_count DESC;

-- 7. Multiple Joins - Real-World Complexity
SELECT 
    u.user_id,
    u.user_name,
    u.country,
    o.order_id,
    o.order_date,
    p.product_name,
    p.category,
    p.price,
    o.quantity,
    (p.price * o.quantity) AS order_value,
    r.rating,
    r.review_text
FROM users u
INNER JOIN orders o ON u.user_id = o.user_id
INNER JOIN products p ON o.product_id = p.product_id
LEFT JOIN reviews r ON p.product_id = r.product_id 
    AND u.user_id = r.user_id
ORDER BY o.order_date DESC;

-- Friday

-- Product Analytics Use Case: User Lifetime Value (LTV) Calculation
SELECT 
    u.user_id,
    u.user_name,
    u.country,
    u.signup_date,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(o.quantity), 0) AS total_items,
    COALESCE(ROUND(SUM(p.price * o.quantity), 2), 0) AS lifetime_value,
    COALESCE(ROUND(AVG(r.rating), 2), 0) AS avg_rating_given
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
LEFT JOIN products p ON o.product_id = p.product_id
LEFT JOIN reviews r ON u.user_id = r.user_id
GROUP BY u.user_id, u.user_name, u.country, u.signup_date
ORDER BY lifetime_value DESC;

-- 8. Advanced Join Techniques for Data Scientists
-- Orders with reviews from the same user
SELECT 
    o.order_id,
    o.user_id,
    p.product_name,
    r.rating,
    r.review_text
FROM orders o
INNER JOIN products p ON o.product_id = p.product_id
INNER JOIN reviews r ON o.product_id = r.product_id 
    AND o.user_id = r.user_id;

-- B) Using Inequalities in Joins (Range Joins)
-- Price tiers analysis
CREATE TABLE price_tiers (
    tier_name VARCHAR(20),
    min_price DECIMAL(10,2),
    max_price DECIMAL(10,2)
);


INSERT INTO price_tiers VALUES
('Budget', 0, 19.99),
('Mid-Range', 20, 99.99),
('Premium', 100, 999.99);

SELECT * FROM price_tiers;

SELECT 
    p.product_name,
    p.price,
    pt.tier_name
FROM products p
JOIN price_tiers pt ON p.price >= pt.min_price 
    AND p.price <= pt.max_price;

-- C) Joining with Aggregated Subqueries
-- Products with above-average ratings
SELECT 
    p.product_name,
    p.category,
    avg_ratings.avg_rating,
    avg_ratings.review_count
FROM products p
INNER JOIN (
    SELECT 
        product_id,
        AVG(rating) AS avg_rating,
        COUNT(*) AS review_count
    FROM reviews
    GROUP BY product_id
    HAVING AVG(rating) > 4
) avg_ratings ON p.product_id = avg_ratings.product_id;

-- add more data
INSERT INTO orders VALUES
(106, 1001, 5, 1, '2024-01-20'),
(107, 1002, 1, 1, '2024-01-22'),
(108, 1005, 3, 2, '2024-01-25'),
(109, 1001, 2, 1, '2024-02-01'),
(110, 1003, 4, 1, '2024-02-05'),
(111, 1002, 5, 1, '2024-02-10'),
(112, 1001, 1, 3, '2024-02-15'),
(113, 1004, 2, 1, '2024-02-20'),
(114, 1005, 4, 1, '2024-03-01');

SELECT * FROM orders;

-- Add more reviews
INSERT INTO reviews VALUES
(5, 5, 1001, 5, 'Amazing display quality'),
(6, 1, 1002, 4, 'Good value for money'),
(7, 2, 1004, 4, 'Solid build quality');

-- Create events table for behavioral tracking
CREATE TABLE user_events (
    event_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    event_type VARCHAR(50),
    product_id INT,
    event_timestamp DATETIME
);

INSERT INTO user_events VALUES
(1, 1001, 'page_view', 1, '2024-01-14 10:30:00'),
(2, 1001, 'add_to_cart', 1, '2024-01-14 10:35:00'),
(3, 1001, 'purchase', 1, '2024-01-15 09:20:00'),
(4, 1002, 'page_view', 3, '2024-01-16 14:15:00'),
(5, 1002, 'add_to_cart', 3, '2024-01-16 14:20:00'),
(6, 1002, 'purchase', 3, '2024-01-16 14:25:00'),
(7, 1003, 'page_view', 2, '2024-01-17 11:00:00'),
(8, 1003, 'page_view', 4, '2024-01-17 11:05:00'),
(9, 1003, 'add_to_cart', 2, '2024-01-18 09:30:00'),
(10, 1003, 'purchase', 2, '2024-01-18 09:35:00');


SELECT * FROM user_events;

-- Wednesdays 
-- Windows Functions:

-- Cumulative revenue over time
SELECT 
	o.order_date,
    o.order_id, 
    p.product_name,
    (p.price * o.quantity) AS order_value,
    SUM(p.price * o.quantity) OVER (
		ORDER BY o.order_date, o.order_id
	) AS cumulative_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
ORDER BY o.order_date, o.order_id;

-- Windows functions
-- Finding 

-- Cumulative revenue over time
-- Can you find the running cumulative revenue for the time that we have had the customers
-- Answer the Question: Can we get the running revenue we had at any time, if we did not make any expense in the course
SELECT 
    o.order_date,
    o.order_id,
    p.product_name,
    (p.price * o.quantity) AS order_value,
    SUM(p.price * o.quantity) OVER (
        ORDER BY o.order_date, o.order_id
    ) AS cumulative_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
ORDER BY o.order_date, o.order_id;


-- What are our top products that we have based on the revenue we have been generating
-- Top products by revenue with ranking
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    SUM(p.price * o.quantity) AS total_revenue,
    RANK() OVER (ORDER BY SUM(p.price * o.quantity) DESC) AS revenue_rank,
    DENSE_RANK() OVER (ORDER BY SUM(p.price * o.quantity) DESC) AS dense_rank,
    ROW_NUMBER() OVER (ORDER BY SUM(p.price * o.quantity) DESC) AS row_num
FROM products p
LEFT JOIN orders o ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_revenue DESC;

-- from each category, can we get the best product that is selling in the products we have
-- Best selling product in each category
SELECT 
    category,
    product_name,
    total_revenue,
    category_rank
FROM (
    SELECT 
        p.category,
        p.product_name,
        COALESCE(SUM(p.price * o.quantity), 0) AS total_revenue,
        RANK() OVER (
            PARTITION BY p.category 
            ORDER BY COALESCE(SUM(p.price * o.quantity), 0) DESC
        ) AS category_rank
    FROM products p
    LEFT JOIN orders o ON p.product_id = o.product_id
    GROUP BY p.category, p.product_name
) ranked
WHERE category_rank <= 3
ORDER BY category, category_rank;


-- we can also get the average of the order value per user
-- 3-order moving average of order values per user
SELECT 
    u.user_name,
    o.order_date,
    (p.price * o.quantity) AS order_value,
    AVG(p.price * o.quantity) OVER (
        PARTITION BY u.user_id 
        ORDER BY o.order_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_3_orders
FROM users u
JOIN orders o ON u.user_id = o.user_id
JOIN products p ON o.product_id = p.product_id
ORDER BY u.user_name, o.order_date;

-- Applying lead and lag functions
-- Time between consecutive purchases per user
SELECT 
    u.user_name,
    o.order_date AS current_order_date,
    LAG(o.order_date) OVER (
        PARTITION BY u.user_id 
        ORDER BY o.order_date
    ) AS previous_order_date,
    DATEDIFF(
        o.order_date, 
        LAG(o.order_date) OVER (
            PARTITION BY u.user_id 
            ORDER BY o.order_date
        )
    ) AS days_since_last_order
FROM users u
JOIN orders o ON u.user_id = o.user_id
ORDER BY u.user_name, o.order_date;

-- What is the first most recent product purchased by each user
-- First and most recent product purchased by each user
SELECT DISTINCT
    u.user_id,
    u.user_name,
    FIRST_VALUE(p.product_name) OVER (
        PARTITION BY u.user_id 
        ORDER BY o.order_date
    ) AS first_product,
    LAST_VALUE(p.product_name) OVER (
        PARTITION BY u.user_id 
        ORDER BY o.order_date
        RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS latest_product
FROM users u
JOIN orders o ON u.user_id = o.user_id
JOIN products p ON o.product_id = p.product_id;


/* Cohort Analysis 
- We can analyze the cohorts based on the time we look at the customers, or users
*/

-- User Cohort by Signup Month
-- What is the behaviour of the customers based on the time that they sign-up
-- Define cohorts and track their behavior
WITH user_cohorts AS (
    SELECT 
        user_id,
        DATE_FORMAT(signup_date, '%Y-%m') AS cohort_month
    FROM users
),
cohort_orders AS (
    SELECT 
        uc.cohort_month,
        uc.user_id,
        DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
        PERIOD_DIFF(
            DATE_FORMAT(o.order_date, '%Y%m'),
            DATE_FORMAT(MIN(o.order_date) OVER (PARTITION BY uc.user_id), '%Y%m')
        ) AS months_since_first_order
    FROM user_cohorts uc
    LEFT JOIN orders o ON uc.user_id = o.user_id
)
SELECT 
    cohort_month,
    months_since_first_order,
    COUNT(DISTINCT user_id) AS active_users,
    COUNT(DISTINCT CASE WHEN months_since_first_order = 0 THEN user_id END) AS cohort_size
FROM cohort_orders
WHERE order_month IS NOT NULL
GROUP BY cohort_month, months_since_first_order
ORDER BY cohort_month, months_since_first_order;

-- Based on the cohorts we have, can you tell us what is the revenue that each cohort is generating
-- Revenue generated by each cohort over time
WITH user_cohorts AS (
    SELECT 
        user_id,
        DATE_FORMAT(signup_date, '%Y-%m') AS cohort_month
    FROM users
)
SELECT 
    uc.cohort_month,
    DATE_FORMAT(o.order_date, '%Y-%m') AS revenue_month,
    COUNT(DISTINCT o.user_id) AS purchasing_users,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(p.price * o.quantity), 2) AS cohort_revenue,
    ROUND(AVG(p.price * o.quantity), 2) AS avg_order_value
FROM user_cohorts uc
JOIN orders o ON uc.user_id = o.user_id
JOIN products p ON o.product_id = p.product_id
GROUP BY uc.cohort_month, DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY uc.cohort_month, revenue_month;

/* retention and Churn Analysis

*/

-- User Retention Rate
-- Calculate the monthly rate of the users retentions

-- Monthly retention rate
WITH user_first_order AS (
    SELECT 
        user_id,
        MIN(DATE_FORMAT(order_date, '%Y-%m')) AS first_order_month
    FROM orders
    GROUP BY user_id
),
monthly_activity AS (
    SELECT DISTINCT
        ufo.user_id,
        ufo.first_order_month,
        DATE_FORMAT(o.order_date, '%Y-%m') AS activity_month,
        PERIOD_DIFF(
            DATE_FORMAT(o.order_date, '%Y%m'),
            DATE_FORMAT(STR_TO_DATE(CONCAT(ufo.first_order_month, '-01'), '%Y-%m-%d'), '%Y%m')
        ) AS months_since_first
    FROM user_first_order ufo
    JOIN orders o ON ufo.user_id = o.user_id
)
SELECT 
    first_order_month,
    months_since_first,
    COUNT(DISTINCT user_id) AS retained_users,
    ROUND(
        100.0 * COUNT(DISTINCT user_id) / 
        FIRST_VALUE(COUNT(DISTINCT user_id)) OVER (
            PARTITION BY first_order_month 
            ORDER BY months_since_first
        ), 2
    ) AS retention_rate_pct
FROM monthly_activity
GROUP BY first_order_month, months_since_first
ORDER BY first_order_month, months_since_first;

-- At what rate are people leaving the business -> What is the churn rate
-- Users who haven't ordered in 30+ days
SELECT 
    u.user_id,
    u.user_name,
    MAX(o.order_date) AS last_order_date,
    DATEDIFF(CURDATE(), MAX(o.order_date)) AS days_inactive,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(p.price * o.quantity), 2) AS lifetime_value,
    CASE 
        WHEN DATEDIFF(CURDATE(), MAX(o.order_date)) > 60 THEN 'High Risk'
        WHEN DATEDIFF(CURDATE(), MAX(o.order_date)) > 30 THEN 'At Risk'
        ELSE 'Active'
    END AS churn_risk
FROM users u
JOIN orders o ON u.user_id = o.user_id
JOIN products p ON o.product_id = p.product_id
GROUP BY u.user_id, u.user_name
HAVING DATEDIFF(CURDATE(), MAX(o.order_date)) > 30
ORDER BY days_inactive DESC;

/* 
Time Series Analysis
*/

-- Daily Revenue Trends
-- Daily revenue with 7-day moving average
WITH daily_revenue AS (
    SELECT 
        o.order_date,
        ROUND(SUM(p.price * o.quantity), 2) AS daily_revenue
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY o.order_date
)
SELECT 
    order_date,
    daily_revenue,
    AVG(daily_revenue) OVER (
        ORDER BY order_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS moving_avg_7day,
    SUM(daily_revenue) OVER (
        ORDER BY order_date
    ) AS cumulative_revenue
FROM daily_revenue
ORDER BY order_date;

-- GEt the growth rate, - Week by Week

-- Week-over-week revenue comparison
WITH weekly_revenue AS (
    SELECT 
        YEARWEEK(o.order_date) AS year_week,
        DATE_FORMAT(o.order_date, '%Y-%m-%d') AS week_start,
        ROUND(SUM(p.price * o.quantity), 2) AS weekly_revenue
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY YEARWEEK(o.order_date), DATE_FORMAT(o.order_date, '%Y-%m-%d')
)
SELECT 
    year_week,
    week_start,
    weekly_revenue,
    LAG(weekly_revenue) OVER (ORDER BY year_week) AS prev_week_revenue,
    ROUND(
        100.0 * (weekly_revenue - LAG(weekly_revenue) OVER (ORDER BY year_week)) / 
        LAG(weekly_revenue) OVER (ORDER BY year_week), 
        2
    ) AS wow_growth_pct
FROM weekly_revenue
ORDER BY year_week;

-- What is the seasonality in the data that we have?
-- Day of week performance
SELECT 
    DAYNAME(o.order_date) AS day_of_week,
    DAYOFWEEK(o.order_date) AS day_num,
    COUNT(o.order_id) AS order_count,
    ROUND(SUM(p.price * o.quantity), 2) AS total_revenue,
    ROUND(AVG(p.price * o.quantity), 2) AS avg_order_value
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY DAYNAME(o.order_date), DAYOFWEEK(o.order_date)
ORDER BY day_num;


/* 
RFM Analysis (Recency, Frequency, Monetary)
*/
-- Complete RFM Segmentation
-- Calculate RFM scores for customer segmentation
WITH rfm_calc AS (
    SELECT 
        u.user_id,
        u.user_name,
        DATEDIFF(CURDATE(), MAX(o.order_date)) AS recency_days,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(p.price * o.quantity), 2) AS monetary
    FROM users u
    LEFT JOIN orders o ON u.user_id = o.user_id
    LEFT JOIN products p ON o.product_id = p.product_id
    GROUP BY u.user_id, u.user_name
),
rfm_scores AS (
    SELECT 
        user_id,
        user_name,
        recency_days,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm_calc
)
SELECT 
    user_id,
    user_name,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    (r_score + f_score + m_score) AS rfm_total,
    CASE 
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'Promising'
        WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
        WHEN r_score <= 2 AND f_score <= 2 THEN 'Lost'
        ELSE 'Needs Attention'
    END AS customer_segment
FROM rfm_scores
ORDER BY rfm_total DESC;


/*
Funnel Analysis
*/
-- Analyze conversion through the purchase funnel
WITH funnel_steps AS (
    SELECT 
        user_id,
        MAX(CASE WHEN event_type = 'page_view' THEN 1 ELSE 0 END) AS viewed,
        MAX(CASE WHEN event_type = 'add_to_cart' THEN 1 ELSE 0 END) AS added_to_cart,
        MAX(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchased
    FROM user_events
    GROUP BY user_id
)
SELECT 
    'Total Users' AS funnel_step,
    COUNT(DISTINCT user_id) AS user_count,
    100.0 AS conversion_rate
FROM funnel_steps

UNION ALL

SELECT 
    'Viewed Product' AS funnel_step,
    SUM(viewed) AS user_count,
    ROUND(100.0 * SUM(viewed) / COUNT(DISTINCT user_id), 2) AS conversion_rate
FROM funnel_steps

UNION ALL

SELECT 
    'Added to Cart' AS funnel_step,
    SUM(added_to_cart) AS user_count,
    ROUND(100.0 * SUM(added_to_cart) / COUNT(DISTINCT user_id), 2) AS conversion_rate
FROM funnel_steps

UNION ALL

SELECT 
    'Purchased' AS funnel_step,
    SUM(purchased) AS user_count,
    ROUND(100.0 * SUM(purchased) / COUNT(DISTINCT user_id), 2) AS conversion_rate
FROM funnel_steps;

-- Product-Level Funnel
-- Conversion funnel by product
SELECT 
    p.product_id,
    p.product_name,
    COUNT(DISTINCT CASE WHEN ue.event_type = 'page_view' THEN ue.user_id END) AS views,
    COUNT(DISTINCT CASE WHEN ue.event_type = 'add_to_cart' THEN ue.user_id END) AS cart_adds,
    COUNT(DISTINCT CASE WHEN ue.event_type = 'purchase' THEN ue.user_id END) AS purchases,
    ROUND(
        100.0 * COUNT(DISTINCT CASE WHEN ue.event_type = 'add_to_cart' THEN ue.user_id END) /
        NULLIF(COUNT(DISTINCT CASE WHEN ue.event_type = 'page_view' THEN ue.user_id END), 0),
        2
    ) AS view_to_cart_rate,
    ROUND(
        100.0 * COUNT(DISTINCT CASE WHEN ue.event_type = 'purchase' THEN ue.user_id END) /
        NULLIF(COUNT(DISTINCT CASE WHEN ue.event_type = 'add_to_cart' THEN ue.user_id END), 0),
        2
    ) AS cart_to_purchase_rate
FROM products p
LEFT JOIN user_events ue ON p.product_id = ue.product_id
GROUP BY p.product_id, p.product_name
ORDER BY purchases DESC;

/*
7. Product Recommendation Queries
Collaborative Filtering - Users Who Bought This Also Bought

*/

-- Get us a market basket analysis 
-- Products frequently bought together
SELECT 
    p1.product_id AS base_product_id,
    p1.product_name AS base_product,
    p2.product_id AS recommended_product_id,
    p2.product_name AS recommended_product,
    COUNT(DISTINCT o1.user_id) AS co_purchase_count,
    ROUND(
        100.0 * COUNT(DISTINCT o1.user_id) / 
        (SELECT COUNT(DISTINCT user_id) FROM orders WHERE product_id = p1.product_id),
        2
    ) AS recommendation_strength_pct
FROM orders o1
JOIN orders o2 ON o1.user_id = o2.user_id AND o1.product_id < o2.product_id
JOIN products p1 ON o1.product_id = p1.product_id
JOIN products p2 ON o2.product_id = p2.product_id
GROUP BY p1.product_id, p1.product_name, p2.product_id, p2.product_name
HAVING co_purchase_count >= 2
ORDER BY p1.product_id, co_purchase_count DESC;

-- segment users into groups based on what they are buying

-- Similar Users Based on Purchase Behavior
-- Find similar users based on overlapping purchases
WITH user_products AS (
    SELECT DISTINCT user_id, product_id
    FROM orders
)
SELECT 
    up1.user_id AS user_a,
    up2.user_id AS user_b,
    COUNT(*) AS common_products,
    GROUP_CONCAT(DISTINCT p.product_name SEPARATOR ', ') AS shared_products
FROM user_products up1
JOIN user_products up2 ON up1.product_id = up2.product_id 
    AND up1.user_id < up2.user_id
JOIN products p ON up1.product_id = p.product_id
GROUP BY up1.user_id, up2.user_id
HAVING common_products >= 2
ORDER BY common_products DESC;

/*
Statistical Analysis

*/

-- Order value percentiles
WITH order_values AS (
    SELECT 
        o.order_id,
        ROUND(p.price * o.quantity, 2) AS order_value
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
)
SELECT 
    MIN(order_value) AS min_value,
    MAX(order_value) AS max_value,
    ROUND(AVG(order_value), 2) AS mean_value,
    ROUND(STDDEV(order_value), 2) AS std_dev,
    (SELECT order_value FROM order_values ORDER BY order_value LIMIT 1 OFFSET (SELECT COUNT(*) * 0.25 FROM order_values)) AS percentile_25,
    (SELECT order_value FROM order_values ORDER BY order_value LIMIT 1 OFFSET (SELECT COUNT(*) * 0.50 FROM order_values)) AS median,
    (SELECT order_value FROM order_values ORDER BY order_value LIMIT 1 OFFSET (SELECT COUNT(*) * 0.75 FROM order_values)) AS percentile_75
FROM order_values;

-- What is the category performance Distribution
-- Standard deviation and variance by category
SELECT 
    p.category,
    COUNT(o.order_id) AS order_count,
    ROUND(AVG(p.price * o.quantity), 2) AS avg_order_value,
    ROUND(STDDEV(p.price * o.quantity), 2) AS std_dev,
    ROUND(VARIANCE(p.price * o.quantity), 2) AS variance,
    ROUND(MIN(p.price * o.quantity), 2) AS min_order,
    ROUND(MAX(p.price * o.quantity), 2) AS max_order
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category;

-- Is there  a relationship between Ratings and Price?

-- Analyze if higher-priced products get better ratings
SELECT 
    CASE 
        WHEN p.price < 20 THEN 'Budget (< $20)'
        WHEN p.price < 100 THEN 'Mid-Range ($20-$100)'
        ELSE 'Premium ($100+)'
    END AS price_tier,
    COUNT(r.review_id) AS review_count,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    ROUND(AVG(p.price), 2) AS avg_price
FROM products p
LEFT JOIN reviews r ON p.product_id = r.product_id
WHERE r.rating IS NOT NULL
GROUP BY price_tier
ORDER BY avg_price;

/* 
Advanced Aggregations and Pivoting
*/

-- Get Dynamic pivot-Revenue by Category and Month
-- Revenue pivot table
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
    ROUND(SUM(CASE WHEN p.category = 'Electronics' THEN p.price * o.quantity ELSE 0 END), 2) AS electronics_revenue,
    ROUND(SUM(CASE WHEN p.category = 'Accessories' THEN p.price * o.quantity ELSE 0 END), 2) AS accessories_revenue,
    ROUND(SUM(p.price * o.quantity), 2) AS total_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY order_month;

-- Get a  Cross-Tab Analysis of the data
-- User purchase matrix by category
SELECT 
    u.user_id,
    u.user_name,
    COUNT(DISTINCT CASE WHEN p.category = 'Electronics' THEN o.order_id END) AS electronics_orders,
    COUNT(DISTINCT CASE WHEN p.category = 'Accessories' THEN o.order_id END) AS accessories_orders,
    COUNT(DISTINCT o.order_id) AS total_orders,
    CASE 
        WHEN COUNT(DISTINCT p.category) > 1 THEN 'Multi-Category'
        ELSE 'Single-Category'
    END AS buyer_type
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
LEFT JOIN products p ON o.product_id = p.product_id
GROUP BY u.user_id, u.user_name
ORDER BY total_orders DESC;


/* COmplex Busiiness Questions

Can you predict the future CLV 
*/
-- Predict future value based on early behavior
WITH customer_metrics AS (
    SELECT 
        u.user_id,
        u.user_name,
        DATEDIFF(CURDATE(), u.signup_date) AS days_as_customer,
        COUNT(DISTINCT o.order_id) AS total_orders,
        ROUND(SUM(p.price * o.quantity), 2) AS total_spent,
        ROUND(AVG(p.price * o.quantity), 2) AS avg_order_value,
        DATEDIFF(CURDATE(), MAX(o.order_date)) AS days_since_last_order,
        ROUND(
            SUM(p.price * o.quantity) / NULLIF(DATEDIFF(CURDATE(), u.signup_date), 0) * 365,
            2
        ) AS annualized_value
    FROM users u
    LEFT JOIN orders o ON u.user_id = o.user_id
    LEFT JOIN products p ON o.product_id = p.product_id
    GROUP BY u.user_id, u.user_name, u.signup_date
)
SELECT 
    user_id,
    user_name,
    days_as_customer,
    total_orders,
    total_spent,
    avg_order_value,
    days_since_last_order,
    annualized_value,
    ROUND(annualized_value * 3, 2) AS predicted_3yr_clv,
    CASE 
        WHEN annualized_value > 1000 THEN 'High Value'
        WHEN annualized_value > 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS value_segment
FROM customer_metrics
ORDER BY predicted_3yr_clv DESC;


-- What is the product Performance Score

-- Predict future value based on early behavior
WITH customer_metrics AS (
    SELECT 
        u.user_id,
        u.user_name,
        DATEDIFF(CURDATE(), u.signup_date) AS days_as_customer,
        COUNT(DISTINCT o.order_id) AS total_orders,
        ROUND(SUM(p.price * o.quantity), 2) AS total_spent,
        ROUND(AVG(p.price * o.quantity), 2) AS avg_order_value,
        DATEDIFF(CURDATE(), MAX(o.order_date)) AS days_since_last_order,
        ROUND(
            SUM(p.price * o.quantity) / NULLIF(DATEDIFF(CURDATE(), u.signup_date), 0) * 365,
            2
        ) AS annualized_value
    FROM users u
    LEFT JOIN orders o ON u.user_id = o.user_id
    LEFT JOIN products p ON o.product_id = p.product_id
    GROUP BY u.user_id, u.user_name, u.signup_date
)
SELECT 
    user_id,
    user_name,
    days_as_customer,
    total_orders,
    total_spent,
    avg_order_value,
    days_since_last_order,
    annualized_value,
    ROUND(annualized_value * 3, 2) AS predicted_3yr_clv,
    CASE 
        WHEN annualized_value > 1000 THEN 'High Value'
        WHEN annualized_value > 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS value_segment
FROM customer_metrics
ORDER BY predicted_3yr_clv DESC;


-- What Anomalies do wew have - Can you detect the anomalies in the data

-- Detect unusual order patterns
WITH daily_stats AS (
    SELECT 
        order_date,
        COUNT(*) AS order_count,
        ROUND(SUM(p.price * o.quantity), 2) AS daily_revenue
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY order_date
),
stats_with_avg AS (
    SELECT 
        order_date,
        order_count,
        daily_revenue,
        AVG(daily_revenue) OVER () AS avg_revenue,
        STDDEV(daily_revenue) OVER () AS stddev_revenue
    FROM daily_stats
)
SELECT 
    order_date,
    order_count,
    daily_revenue,
    ROUND(avg_revenue, 2) AS avg_revenue,
    ROUND(stddev_revenue, 2) AS stddev_revenue,
    ROUND((daily_revenue - avg_revenue) / NULLIF(stddev_revenue, 0), 2) AS z_score,
    CASE 
        WHEN ABS((daily_revenue - avg_revenue) / NULLIF(stddev_revenue, 0)) > 2 THEN 'ANOMALY'
        ELSE 'Normal'
    END AS anomaly_flag
FROM stats_with_avg
ORDER BY ABS((daily_revenue - avg_revenue) / NULLIF(stddev_revenue, 0)) DESC;















    
    
    
    
    
