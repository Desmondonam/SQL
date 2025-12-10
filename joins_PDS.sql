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

INSERT INTO products VALUES
(1, 'Wireless Mouse', 'Electronics', 29.99),
(2, 'Laptop Stand', 'Accessories', 49.99),
(3, 'USB-C Cable', 'Accessories', 12.99),
(4, 'Mechanical Keyboard', 'Electronics', 89.99),
(5, 'Monitor 27"', 'Electronics', 299.99);

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

-- inner joins

/*
What it does: Returns only rows where there's a match in BOTH tables.
When to use: When you only care about records that exist in both tables.
*/

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


