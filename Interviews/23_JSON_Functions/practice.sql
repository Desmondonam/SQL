-- ============================================================
--  SQL INTERVIEW PREP — 23: JSON Functions (MySQL 5.7+)
--  Level     : Advanced → Expert
--  Dataset   : API logs + Product attributes + User preferences
--  Covers    : JSON_EXTRACT, JSON_SET, JSON_TABLE, JSON_OBJECT, JSON_ARRAYAGG
-- ============================================================

CREATE DATABASE IF NOT EXISTS json_db;
USE json_db;

DROP TABLE IF EXISTS api_logs;
DROP TABLE IF EXISTS product_attributes;
DROP TABLE IF EXISTS user_preferences;

CREATE TABLE api_logs (
    log_id       INT PRIMARY KEY AUTO_INCREMENT,
    endpoint     VARCHAR(200),
    method       VARCHAR(10),
    request_body JSON,
    response     JSON,
    status_code  SMALLINT,
    duration_ms  INT,
    logged_at    DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE product_attributes (
    prod_id    INT PRIMARY KEY AUTO_INCREMENT,
    prod_name  VARCHAR(150),
    category   VARCHAR(80),
    attributes JSON    -- flexible: different products have different fields
);

CREATE TABLE user_preferences (
    user_id     INT PRIMARY KEY,
    username    VARCHAR(80),
    preferences JSON    -- stores user settings as JSON
);

INSERT INTO api_logs (endpoint, method, request_body, response, status_code, duration_ms) VALUES
 ('/api/orders',   'POST',
  '{"customer_id":"C001","items":[{"sku":"SKU-001","qty":2},{"sku":"SKU-002","qty":1}],"payment":"credit_card"}',
  '{"order_id":"ORD-001","status":"created","total":1699.97}', 201, 145),
 ('/api/products', 'GET',
  '{"category":"electronics","limit":10,"page":1}',
  '{"count":10,"total":45,"products":[{"id":1,"name":"Laptop"},{"id":2,"name":"Phone"}]}', 200, 32),
 ('/api/orders',   'POST',
  '{"customer_id":"C002","items":[{"sku":"SKU-003","qty":1}],"payment":"paypal"}',
  '{"order_id":"ORD-002","status":"created","total":189.90}', 201, 89),
 ('/api/auth/login','POST',
  '{"email":"user@example.com","password":"***"}',
  '{"token":"eyJhbGciOiJIUzI1NiJ9...","expires_in":3600,"user_id":42}', 200, 210),
 ('/api/products', 'GET',
  '{"category":"books","limit":5}',
  '{"count":5,"total":12,"products":[{"id":4,"name":"SQL Guide"}]}', 200, 28),
 ('/api/orders',   'GET',
  '{"customer_id":"C001"}',
  '{"orders":[{"id":"ORD-001","status":"delivered"},{"id":"ORD-003","status":"shipped"}]}', 200, 55),
 ('/api/payments', 'POST',
  '{"order_id":"ORD-004","amount":299.99,"currency":"USD","method":"credit_card"}',
  '{"status":"failed","reason":"insufficient_funds","code":402}', 402, 320);

INSERT INTO product_attributes (prod_name, category, attributes) VALUES
 ('MacBook Pro 14','Electronics',
  '{"brand":"Apple","ram_gb":16,"storage_gb":512,"color":["Silver","Space Gray"],"warranty_years":1,"weight_kg":1.6,"features":["Touch ID","MagSafe","M3 chip"]}'),
 ('iPhone 15 Pro','Electronics',
  '{"brand":"Apple","storage_gb":256,"color":["Black","Blue","White"],"5g":true,"camera_mp":48,"battery_mah":3274}'),
 ('SQL Mastery','Books',
  '{"author":"Alice DB","publisher":"TechPress","pages":450,"isbn":"978-0-123456-78-9","edition":3,"languages":["English","Spanish"]}'),
 ('Running Pro X','Sports',
  '{"brand":"Nike","sizes":[7,8,9,10,11,12],"color":["Red","Black"],"weight_g":280,"surface":"road","waterproof":false}'),
 ('Gaming Chair','Furniture',
  '{"brand":"SecretLab","max_weight_kg":120,"adjustable":true,"material":"leather","armrests":4,"recline_degrees":165}');

INSERT INTO user_preferences VALUES
 (1,'alice',  '{"theme":"dark","language":"en","notifications":{"email":true,"sms":false,"push":true},"currency":"USD","timezone":"America/New_York"}'),
 (2,'bob',    '{"theme":"light","language":"pt","notifications":{"email":false,"sms":true,"push":true},"currency":"BRL","timezone":"America/Sao_Paulo"}'),
 (3,'carol',  '{"theme":"dark","language":"de","notifications":{"email":true,"sms":true,"push":false},"currency":"EUR","timezone":"Europe/Berlin"}'),
 (4,'dave',   '{"theme":"auto","language":"en","notifications":{"email":true,"sms":false,"push":false},"currency":"GBP","timezone":"Europe/London"}'),
 (5,'eve',    '{"theme":"dark","language":"ja","notifications":{"email":false,"sms":false,"push":true},"currency":"JPY","timezone":"Asia/Tokyo"}');

-- ─────────────────────────────────────────────────────────────
--  TASKS
-- ─────────────────────────────────────────────────────────────

-- Q1. [EASY] Extract the customer_id from request_body in api_logs.
--     Use JSON_EXTRACT or the -> shorthand operator.



-- Q2. [EASY] Show each user's theme and language from user_preferences.
--     Use the ->> operator (unquoted extraction).



-- Q3. [MEDIUM] From api_logs, extract the order_id from the response JSON
--     for all POST /api/orders requests.



-- Q4. [MEDIUM] Show products with their brand (from attributes JSON).
--     Only show products that HAVE a 'brand' key.
--     Use JSON_CONTAINS_PATH.



-- Q5. [MEDIUM] Find all users who have email notifications ENABLED.
--     Path: preferences->'$.notifications.email' = true



-- Q6. [MEDIUM] Use JSON_TABLE to "unpack" the product colors array
--     into individual rows. Show prod_name and each color as a separate row.



-- Q7. [HARD] In api_logs, extract the number of items in each POST order request.
--     Use JSON_LENGTH on the items array.



-- Q8. [HARD] Use JSON_OBJECT and JSON_ARRAYAGG to create a JSON summary:
--     For each category in product_attributes, aggregate all product names
--     into a JSON array. Output: category, product_list (JSON array).



-- Q9. [HARD] Update a user's preference using JSON_SET:
--     For user_id = 1 (alice), change theme to 'light'
--     and add a new key 'font_size' = 14.



-- Q10. [EXPERT] Use JSON_TABLE to parse the api_logs.response JSON
--      for GET /api/products endpoint — extract individual product id and name
--      from the nested products array. Show: log_id, product_id, product_name.



-- Q11. [EXPERT] Calculate the average duration_ms grouped by HTTP method and
--      status code range (2xx, 4xx). Also show total API calls.



-- Q12. [EXPERT] Write a query that converts the entire user_preferences table
--      into a single JSON object keyed by username.
--      Format: {"alice": {preferences...}, "bob": {preferences...}}
