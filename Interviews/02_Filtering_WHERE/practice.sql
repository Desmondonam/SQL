-- ============================================================
--  SQL INTERVIEW PREP — 02: Filtering with WHERE
--  Level     : Beginner → Intermediate
--  Dataset   : E-Commerce (Olist Brazilian E-Commerce, Kaggle)
--              https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
-- ============================================================

CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;

CREATE TABLE customers (
    customer_id      VARCHAR(36) PRIMARY KEY,
    customer_name    VARCHAR(100),
    city             VARCHAR(80),
    state            VARCHAR(50),
    country          VARCHAR(50) DEFAULT 'Brazil'
);

CREATE TABLE products (
    product_id       VARCHAR(36) PRIMARY KEY,
    category         VARCHAR(80),
    product_name     VARCHAR(200),
    price            DECIMAL(10,2),
    weight_g         INT,
    stock_qty        INT
);

CREATE TABLE orders (
    order_id         VARCHAR(36) PRIMARY KEY,
    customer_id      VARCHAR(36),
    product_id       VARCHAR(36),
    order_status     VARCHAR(20),    -- delivered, shipped, canceled, processing
    purchase_date    DATE,
    delivered_date   DATE,
    quantity         INT,
    total_amount     DECIMAL(10,2),
    payment_type     VARCHAR(30),    -- credit_card, boleto, voucher, debit_card
    review_score     TINYINT         -- 1 to 5
);

INSERT INTO customers VALUES
 ('C001','Ana Silva',    'São Paulo',     'SP','Brazil'),
 ('C002','Bruno Souza',  'Rio de Janeiro','RJ','Brazil'),
 ('C003','Carla Lima',   'Belo Horizonte','MG','Brazil'),
 ('C004','Diego Costa',  'Curitiba',      'PR','Brazil'),
 ('C005','Elena Rocha',  'Porto Alegre',  'RS','Brazil'),
 ('C006','Felipe Melo',  'Salvador',      'BA','Brazil'),
 ('C007','Gisele Nunes', 'Recife',        'PE','Brazil'),
 ('C008','Hugo Alves',   'Fortaleza',     'CE','Brazil'),
 ('C009','Iris Pinto',   'Manaus',        'AM','Brazil'),
 ('C010','João Borges',  'Brasília',      'DF','Brazil');

INSERT INTO products VALUES
 ('P001','Electronics',  'Smartphone Pro X', 1299.99, 180, 45),
 ('P002','Electronics',  'Wireless Headset',  249.90,  90, 120),
 ('P003','Clothing',     'Winter Jacket',     189.90, 500,  30),
 ('P004','Books',        'SQL Mastery Guide',  59.90,  400, 200),
 ('P005','Home & Garden','Coffee Maker 3000',  349.90, 1200, 15),
 ('P006','Sports',       'Running Shoes',      299.90,  600, 80),
 ('P007','Electronics',  'Tablet 10"',         799.90,  450, 25),
 ('P008','Beauty',       'Perfume Set',        129.90,  200, 60),
 ('P009','Books',        'Data Science Handbook',79.90, 350,150),
 ('P010','Clothing',     'Jeans Classic',       99.90,  700, 55),
 ('P011','Sports',       'Yoga Mat',            79.90,  900, 40),
 ('P012','Home & Garden','Air Purifier',        499.90, 3500,  8),
 ('P013','Electronics',  'Smartwatch Ultra',    599.90,  120, 35),
 ('P014','Beauty',       'Skincare Bundle',     199.90,  300, 70),
 ('P015','Books',        'Python for Everyone',  49.90,  300,180);

INSERT INTO orders VALUES
 ('O001','C001','P001','delivered', '2023-01-10','2023-01-20',1,1299.99,'credit_card',5),
 ('O002','C002','P002','delivered', '2023-01-15','2023-01-25',2, 499.80,'boleto',      4),
 ('O003','C003','P003','canceled',  '2023-02-01', NULL,       1, 189.90,'credit_card',NULL),
 ('O004','C004','P004','delivered', '2023-02-14','2023-02-20',3, 179.70,'voucher',     3),
 ('O005','C005','P005','shipped',   '2023-03-01', NULL,       1, 349.90,'debit_card',  NULL),
 ('O006','C006','P006','delivered', '2023-03-10','2023-03-18',1, 299.90,'credit_card',5),
 ('O007','C007','P007','delivered', '2023-03-20','2023-04-01',1, 799.90,'credit_card',2),
 ('O008','C008','P008','processing','2023-04-05', NULL,       2, 259.80,'boleto',      NULL),
 ('O009','C009','P009','delivered', '2023-04-10','2023-04-17',1,  79.90,'credit_card',4),
 ('O010','C010','P010','delivered', '2023-04-22','2023-05-02',2, 199.80,'debit_card',  5),
 ('O011','C001','P011','delivered', '2023-05-01','2023-05-09',1,  79.90,'credit_card',3),
 ('O012','C002','P012','canceled',  '2023-05-15', NULL,       1, 499.90,'credit_card',NULL),
 ('O013','C003','P013','delivered', '2023-06-01','2023-06-12',1, 599.90,'boleto',      5),
 ('O014','C004','P014','delivered', '2023-06-18','2023-06-28',3, 599.70,'credit_card',4),
 ('O015','C005','P015','shipped',   '2023-07-01', NULL,       2,  99.80,'voucher',     NULL),
 ('O016','C006','P001','delivered', '2023-07-10','2023-07-20',1,1299.99,'credit_card',5),
 ('O017','C007','P002','delivered', '2023-08-05','2023-08-15',1, 249.90,'debit_card',  4),
 ('O018','C008','P003','delivered', '2023-08-20','2023-08-30',2, 379.80,'credit_card',3),
 ('O019','C009','P007','canceled',  '2023-09-01', NULL,       1, 799.90,'boleto',      NULL),
 ('O020','C010','P013','delivered', '2023-09-15','2023-09-25',1, 599.90,'credit_card',5);

-- ─────────────────────────────────────────────────────────────
--  TASKS
-- ─────────────────────────────────────────────────────────────

-- Q1. [EASY] Show all orders with status = 'delivered'.



-- Q2. [EASY] Show all products with price LESS THAN 200.



-- Q3. [EASY] Show all orders where payment_type is 'credit_card' AND review_score = 5.



-- Q4. [EASY] Show all products in the 'Electronics' OR 'Books' category.



-- Q5. [EASY] Show all orders that are NOT canceled.



-- Q6. [MEDIUM] Show all orders with total_amount BETWEEN 200 and 600 (inclusive).



-- Q7. [MEDIUM] Show all customers whose city starts with the letter 'S'.



-- Q8. [MEDIUM] Show all orders where delivered_date IS NULL
--     (i.e., not yet delivered).



-- Q9. [MEDIUM] Show all products whose category is one of:
--     'Electronics', 'Sports', 'Home & Garden'  — use IN.



-- Q10. [MEDIUM] Show all products whose product_name contains the word 'Pro'
--      or 'Ultra' (case-insensitive search using LIKE).



-- Q11. [MEDIUM] Show all orders placed in the first quarter of 2023
--      (January, February, March).



-- Q12. [HARD] Show all orders where the customer's review_score is
--      below 3 OR the order was canceled. Include order_id, customer_id,
--      order_status, and review_score.



-- Q13. [HARD] Find products that are low stock (stock_qty < 20)
--      AND expensive (price > 400).



-- Q14. [HARD] Show all orders for customers C001, C003, C005, C007
--      that were delivered. Use IN for customer_id.



-- Q15. [HARD] Show orders where quantity >= 2 AND total_amount > 300
--      AND payment_type != 'voucher'.
