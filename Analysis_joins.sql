-- Create database
CREATE DATABASE product_analytics;
USE product_analytics;

-- Create the orders table
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    order_status VARCHAR(30),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);


-- When loading the data
SHOW VARIABLES LIKE "secure_file_priv";
-- Import CSV files using MySQL Workbench or command line
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 9.2/Uploads/olist_orders_dataset.csv"
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    order_id,
    customer_id,
    order_status,
    @order_purchase_timestamp,
    @order_approved_at,
    @order_delivered_carrier_date,
    @order_delivered_customer_date,
    @order_estimated_delivery_date
)
SET
    order_purchase_timestamp       = NULLIF(@order_purchase_timestamp, ''),
    order_approved_at              = NULLIF(@order_approved_at, ''),
    order_delivered_carrier_date   = NULLIF(@order_delivered_carrier_date, ''),
    order_delivered_customer_date  = NULLIF(@order_delivered_customer_date, ''),
    order_estimated_delivery_date  = NULLIF(@order_estimated_delivery_date, '');
-- Repeat for all tables



-- Revenue by product category
SELECT 
    p.product_category_name,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(oi.order_item_id) AS total_items_sold,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(AVG(oi.price), 2) AS avg_item_price,
    ROUND(SUM(oi.freight_value), 2) AS total_shipping_cost
FROM olist_order_items_dataset oi
INNER JOIN olist_products_dataset p 
    ON oi.product_id = p.product_id
INNER JOIN olist_orders_dataset o 
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name
ORDER BY total_revenue DESC
LIMIT 20;