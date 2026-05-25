-- ============================================================
--  SQL INTERVIEW PREP — 06: JOINs (INNER, LEFT, RIGHT, SELF, CROSS)
--  Level     : Intermediate
--  Dataset   : Northwind-inspired (Orders, Customers, Products,
--              Employees, Suppliers) — classic interview dataset
--              https://github.com/Microsoft/sql-server-samples/
-- ============================================================

CREATE DATABASE IF NOT EXISTS northwind_db;
USE northwind_db;

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders_nw;
DROP TABLE IF EXISTS products_nw;
DROP TABLE IF EXISTS suppliers;
DROP TABLE IF EXISTS employees_nw;
DROP TABLE IF EXISTS customers_nw;
DROP TABLE IF EXISTS categories;

CREATE TABLE categories (
    cat_id    INT PRIMARY KEY,
    cat_name  VARCHAR(80),
    description VARCHAR(200)
);

CREATE TABLE suppliers (
    supplier_id   INT PRIMARY KEY,
    company_name  VARCHAR(100),
    country       VARCHAR(80),
    contact_name  VARCHAR(80)
);

CREATE TABLE products_nw (
    product_id    INT PRIMARY KEY,
    product_name  VARCHAR(100),
    cat_id        INT,
    supplier_id   INT,
    unit_price    DECIMAL(10,2),
    units_in_stock INT,
    discontinued  BOOLEAN DEFAULT FALSE
);

CREATE TABLE customers_nw (
    customer_id   CHAR(5) PRIMARY KEY,
    company_name  VARCHAR(100),
    contact_name  VARCHAR(80),
    country       VARCHAR(50),
    city          VARCHAR(80)
);

CREATE TABLE employees_nw (
    emp_id        INT PRIMARY KEY,
    first_name    VARCHAR(50),
    last_name     VARCHAR(50),
    title         VARCHAR(80),
    reports_to    INT,           -- self-reference: manager's emp_id
    hire_date     DATE,
    country       VARCHAR(50)
);

CREATE TABLE orders_nw (
    order_id      INT PRIMARY KEY,
    customer_id   CHAR(5),
    emp_id        INT,
    order_date    DATE,
    shipped_date  DATE,
    ship_country  VARCHAR(50),
    freight       DECIMAL(10,2)
);

CREATE TABLE order_items (
    order_id      INT,
    product_id    INT,
    unit_price    DECIMAL(10,2),
    quantity      INT,
    discount      DECIMAL(4,2),
    PRIMARY KEY (order_id, product_id)
);

INSERT INTO categories VALUES
 (1,'Beverages',   'Soft drinks, coffees, teas, beers, and ales'),
 (2,'Condiments',  'Sweet and savory sauces, relishes, spreads, and seasonings'),
 (3,'Seafood',     'Seaweed and fish'),
 (4,'Dairy Products','Cheeses'),
 (5,'Produce',     'Dried fruit and bean curd');

INSERT INTO suppliers VALUES
 (1,'Exotic Liquids',         'UK',     'Charlotte Cooper'),
 (2,'New Orleans Cajun Delights','USA',  'Shelley Burke'),
 (3,'Tokyo Traders',          'Japan',  'Yoshi Nagase'),
 (4,'Mayumi''s',              'Japan',  'Mayumi Ohno'),
 (5,'Pavlova Ltd.',           'Australia','Ian Devling');

INSERT INTO products_nw VALUES
 (1, 'Chai',              1,1,18.00, 39,FALSE),
 (2, 'Chang',             1,1,19.00, 17,FALSE),
 (3, 'Aniseed Syrup',     2,1,10.00, 13,FALSE),
 (4, 'Chef Anton Cajun',  2,2,22.00,  0,TRUE),
 (5, 'Ikura',             3,3,31.00, 31,FALSE),
 (6, 'Tofu',              3,4,23.25, 35,FALSE),
 (7, 'Genen Shouyu',      2,4,15.50,  6,FALSE),
 (8, 'Pavlova',           4,5,17.45, 29,FALSE),
 (9, 'Alice Mutton',      4,5,39.00,  0,TRUE),
 (10,'Carnarvon Tigers',  3,5,62.50,  0,FALSE),
 (11,'Teatime Cookies',   5,3,  9.20, 25,FALSE),
 (12,'Singaporean Noodles',2,2, 14.00,26,FALSE);

INSERT INTO customers_nw VALUES
 ('ALFKI','Alfreds Futterkiste',    'Maria Anders',   'Germany','Berlin'),
 ('ANATR','Ana Trujillo Emparedados','Ana Trujillo',  'Mexico', 'México D.F.'),
 ('ANTON','Antonio Moreno Taquería','Antonio Moreno', 'Mexico', 'México D.F.'),
 ('AROUT','Around the Horn',        'Thomas Hardy',   'UK',     'London'),
 ('BERGS','Berglunds snabbköp',     'Christina Berglund','Sweden','Luleå'),
 ('GHOST','Ghost Customer',         'No Name',        'Unknown','Unknown');  -- orphan

INSERT INTO employees_nw VALUES
 (1,'Nancy',  'Davolio',  'Sales Representative',  2,'2022-05-01','USA'),
 (2,'Andrew', 'Fuller',   'Vice President Sales',  NULL,'2020-08-14','USA'),
 (3,'Janet',  'Leverling','Sales Representative',  2,'2022-04-01','USA'),
 (4,'Margaret','Peacock', 'Sales Representative',  2,'2021-05-03','USA'),
 (5,'Steven', 'Buchanan', 'Sales Manager',         2,'2023-10-17','UK'),
 (6,'Michael','Suyama',   'Sales Representative',  5,'2023-10-17','UK'),
 (7,'Robert', 'King',     'Sales Representative',  5,'2024-01-02','UK'),
 (8,'Laura',  'Callahan', 'Inside Sales Coordinator',2,'2024-03-05','USA');

INSERT INTO orders_nw VALUES
 (10248,'VINET',5,'2023-07-04','2023-07-16','France', 32.38),
 (10249,'TOMSP',6,'2023-07-05','2023-07-10','Germany',11.61),
 (10250,'HANAR',4,'2023-07-08','2023-07-12','Brazil', 65.83),
 (10251,'ALFKI',3,'2023-07-08','2023-07-15','Germany',41.34),
 (10252,'BERGS',4,'2023-07-09','2023-07-11','Sweden', 51.30),
 (10253,'AROUT',3,'2023-07-10','2023-07-16','UK',     58.17),
 (10254,'ANATR',5,'2023-07-11','2023-07-23','Mexico', 22.98),
 (10255,'BERGS',9,'2023-07-12', NULL,        'Sweden',148.33),
 (10256,'ALFKI',3,'2023-07-15','2023-07-17','Germany',13.97),
 (10257,'AROUT',4,'2023-07-16','2023-07-22','UK',     81.91);

-- Order 10255 has emp_id=9 (no such employee → orphan FK for practice)

INSERT INTO order_items VALUES
 (10248,11,14.00,12,0.00),(10248,42,9.80, 10,0.00),(10248,72,34.80, 5,0.00),
 (10249,14,18.60, 9,0.00),(10249,51,42.40,40,0.00),
 (10250, 1,18.00,15,0.25),(10250, 5,31.00,35,0.15),(10250, 7,15.50,25,0.00),
 (10251, 2,19.00, 6,0.05),(10251, 3,10.00,15,0.00),
 (10252, 1,18.00, 2,0.05),(10252, 5,31.00,40,0.05),
 (10253, 6,23.25, 5,0.00),(10253, 7,15.50, 9,0.00),
 (10254, 1,18.00,15,0.15),(10254, 2,19.00,21,0.15),
 (10256, 3,10.00, 2,0.00),(10256, 5,31.00, 5,0.00),
 (10257, 8,17.45,25,0.00),(10257, 9,39.00, 6,0.00);

-- ─────────────────────────────────────────────────────────────
--  TASKS
-- ─────────────────────────────────────────────────────────────

-- Q1. [EASY] INNER JOIN: Show all orders with the customer's company_name
--     and contact_name.



-- Q2. [EASY] INNER JOIN: Show order items with product_name and unit_price
--     from the products table.



-- Q3. [MEDIUM] LEFT JOIN: Show ALL customers and their orders.
--     Include customers with NO orders (show NULL for order columns).



-- Q4. [MEDIUM] LEFT JOIN: Show ALL products and whether they have ever
--     been ordered. Show product_name, ordered (YES/NO).



-- Q5. [MEDIUM] Three-table JOIN: Show order_id, customer company_name,
--     employee first+last name, and order_date.



-- Q6. [MEDIUM] SELF JOIN: Show each employee alongside their manager's
--     first and last name. Employees with no manager show NULL.



-- Q7. [HARD] Four-table JOIN: Show order_id, customer_name, product_name,
--     category_name, quantity, and line total
--     (quantity * order_items.unit_price * (1 - discount)).



-- Q8. [HARD] Show all products with their supplier country and category name.
--     Include discontinued products. Exclude products with no supplier.



-- Q9. [HARD] Find customers who have NEVER placed an order.
--     Use a LEFT JOIN + IS NULL pattern.



-- Q10. [HARD] Show each order with total value (sum of line totals).
--      Join orders_nw → order_items. Group by order_id.
--      Sort by total_value DESC.



-- Q11. [EXPERT] CROSS JOIN: Generate a matrix of all category × supplier
--      combinations (every category paired with every supplier).
--      Show cat_name and company_name.



-- Q12. [EXPERT] Show only orders where the freight cost is HIGHER than
--      the average freight across ALL orders. Include customer name.
