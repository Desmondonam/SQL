-- ============================================================
--  SQL INTERVIEW PREP — 05: GROUP BY & HAVING
--  Level     : Intermediate
--  Dataset   : E-Commerce Orders (reusing ecommerce_db)
--              + Sales by Region dataset
-- ============================================================

USE ecommerce_db;

-- Add a regional sales table for richer GROUP BY practice
DROP TABLE IF EXISTS sales;
CREATE TABLE sales (
    sale_id     INT PRIMARY KEY AUTO_INCREMENT,
    region      VARCHAR(50),
    salesperson VARCHAR(80),
    product_cat VARCHAR(80),
    sale_date   DATE,
    amount      DECIMAL(10,2),
    units_sold  INT,
    channel     VARCHAR(30)   -- 'Online','In-Store','Partner'
);

INSERT INTO sales (region,salesperson,product_cat,sale_date,amount,units_sold,channel) VALUES
 ('North','Alice','Electronics','2023-01-05', 8500,  7,'Online'),
 ('South','Bob',  'Electronics','2023-01-10', 4200,  3,'In-Store'),
 ('East', 'Carol','Clothing',   '2023-01-15', 3100, 12,'Online'),
 ('West', 'Dave', 'Books',      '2023-01-20', 1200, 20,'Partner'),
 ('North','Alice','Clothing',   '2023-02-01', 2800,  9,'Online'),
 ('South','Bob',  'Books',      '2023-02-05',  900, 15,'In-Store'),
 ('East', 'Carol','Electronics','2023-02-10', 9200,  8,'Online'),
 ('West', 'Dave', 'Electronics','2023-02-14', 6100,  5,'Partner'),
 ('North','Eve',  'Books',      '2023-02-20', 1500, 25,'Online'),
 ('South','Frank','Clothing',   '2023-03-01', 4500, 18,'In-Store'),
 ('East', 'Carol','Books',      '2023-03-10',  800, 12,'Online'),
 ('West', 'Dave', 'Clothing',   '2023-03-15', 3300, 11,'Partner'),
 ('North','Alice','Electronics','2023-03-20',12000, 10,'Online'),
 ('South','Bob',  'Electronics','2023-04-01', 5500,  4,'In-Store'),
 ('East', 'Eve',  'Clothing',   '2023-04-05', 2700,  9,'Online'),
 ('West', 'Frank','Books',      '2023-04-10',  650, 10,'Partner'),
 ('North','Alice','Books',      '2023-04-15', 1100, 18,'Online'),
 ('South','Carol','Electronics','2023-05-01', 7800,  6,'In-Store'),
 ('East', 'Dave', 'Clothing',   '2023-05-10', 4100, 14,'Online'),
 ('West', 'Eve',  'Electronics','2023-05-15', 9500,  8,'Partner'),
 ('North','Frank','Clothing',   '2023-06-01', 3600, 13,'Online'),
 ('South','Alice','Books',      '2023-06-05',  750, 12,'In-Store'),
 ('East', 'Bob',  'Electronics','2023-06-10', 8900,  7,'Online'),
 ('West', 'Carol','Clothing',   '2023-06-15', 5200, 17,'Partner'),
 ('North','Dave', 'Electronics','2023-07-01',11000,  9,'Online');

-- ─────────────────────────────────────────────────────────────
--  TASKS
-- ─────────────────────────────────────────────────────────────

-- Q1. [EASY] Count the number of sales per region.



-- Q2. [EASY] Find the total amount sold per product category.



-- Q3. [EASY] How many orders exist per order_status in the orders table?



-- Q4. [MEDIUM] For each salesperson, show their total sales amount
--     and total units sold. Order by total_amount DESC.



-- Q5. [MEDIUM] Find the average sale amount per channel ('Online',
--     'In-Store', 'Partner').



-- Q6. [MEDIUM] Show regions where the TOTAL sales amount exceeds 20,000.
--     (Use HAVING.)



-- Q7. [MEDIUM] Show product categories where the AVERAGE sale amount
--     is greater than 3,000.



-- Q8. [MEDIUM] Find salespersons who have made MORE THAN 4 sales.



-- Q9. [HARD] For each region and product_cat combination, show:
--     total_amount, total_units, number_of_sales.
--     Order by region ASC, total_amount DESC.



-- Q10. [HARD] Show channels where the MAX single sale is above 8,000
--      AND at least 3 sales were made through that channel.



-- Q11. [HARD] Group sales by month (use MONTH() or DATE_FORMAT).
--      Show month, total_amount, total_units.
--      Order by month ASC.



-- Q12. [HARD] For each salesperson, show their total amount and flag
--      them as 'High Performer' if total > 20,000, else 'Standard'.
--      Use HAVING to show only salespersons with at least 3 sales.



-- Q13. [EXPERT] Find regions where EVERY product category was sold
--      (i.e., region has sales in all 3 categories: Electronics, Clothing, Books).
--      Hint: COUNT(DISTINCT product_cat) = 3



-- Q14. [EXPERT] Show the top salesperson per region by total_amount.
--      (This requires a subquery — preview of things to come!)
--      Just GROUP BY region and show MAX(amount) for now.



-- Q15. [EXPERT] In the orders table, find payment_type groups where:
--      - At least 3 orders exist
--      - Average total_amount > 300
--      - At least 1 delivered order
--      Show payment_type, order_count, avg_amount, delivered_count.
