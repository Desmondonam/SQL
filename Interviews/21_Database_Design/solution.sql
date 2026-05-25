-- ============================================================
--  SQL INTERVIEW PREP — 21: Database Design  ✅ SOLUTIONS
-- ============================================================
USE design_db;

-- ─────────────────────────────────────────────────────────────
-- Q1. 1NF — eliminate repeating groups (product columns → rows).
-- ─────────────────────────────────────────────────────────────
-- Violations in unnormalized_orders:
-- 1. product_1/product_2/product_3 are repeating groups (multiple values in same entity).
-- 2. Multiple columns represent the same type of data.

DROP TABLE IF EXISTS orders_1nf;
DROP TABLE IF EXISTS order_items_1nf;

CREATE TABLE orders_1nf (
    order_id       INT,
    customer_name  VARCHAR(100),
    customer_email VARCHAR(150),
    customer_city  VARCHAR(80),
    product_name   VARCHAR(100),
    quantity       INT,
    unit_price     DECIMAL(10,2),
    salesperson    VARCHAR(100),
    sales_region   VARCHAR(50),
    order_date     DATE,
    PRIMARY KEY (order_id, product_name)  -- composite PK
);

-- Unpivot: each product becomes its own row
INSERT INTO orders_1nf
SELECT order_id,customer_name,customer_email,customer_city,product_1,product_1_qty,product_1_price,salesperson,sales_region,order_date
FROM unnormalized_orders WHERE product_1 IS NOT NULL
UNION ALL
SELECT order_id,customer_name,customer_email,customer_city,product_2,product_2_qty,product_2_price,salesperson,sales_region,order_date
FROM unnormalized_orders WHERE product_2 IS NOT NULL
UNION ALL
SELECT order_id,customer_name,customer_email,customer_city,product_3,product_3_qty,product_3_price,salesperson,sales_region,order_date
FROM unnormalized_orders WHERE product_3 IS NOT NULL;

SELECT * FROM orders_1nf;

-- ─────────────────────────────────────────────────────────────
-- Q2. 2NF — remove partial dependencies.
-- Composite PK = (order_id, product_name).
-- customer_name, customer_email, customer_city depend only on order_id (not on product).
-- salesperson, sales_region depend only on order_id.
-- → Move them to a separate orders table.
-- ─────────────────────────────────────────────────────────────
DROP TABLE IF EXISTS orders_2nf;
DROP TABLE IF EXISTS items_2nf;

CREATE TABLE orders_2nf (
    order_id      INT PRIMARY KEY,
    customer_name VARCHAR(100),
    customer_email VARCHAR(150),
    customer_city VARCHAR(80),
    salesperson   VARCHAR(100),
    sales_region  VARCHAR(50),
    order_date    DATE
);

CREATE TABLE items_2nf (
    order_id      INT,
    product_name  VARCHAR(100),
    quantity      INT,
    unit_price    DECIMAL(10,2),
    PRIMARY KEY (order_id, product_name)
);

INSERT INTO orders_2nf
SELECT DISTINCT order_id,customer_name,customer_email,customer_city,salesperson,sales_region,order_date
FROM orders_1nf;

INSERT INTO items_2nf SELECT order_id,product_name,quantity,unit_price FROM orders_1nf;

-- ─────────────────────────────────────────────────────────────
-- Q3. 3NF — remove transitive dependencies.
-- sales_region depends on salesperson (not on order_id directly).
-- customer_city may depend on customer_email (if email is unique per customer).
-- → Separate customers and salespersons.
-- ─────────────────────────────────────────────────────────────
DROP TABLE IF EXISTS customers_3nf;
DROP TABLE IF EXISTS salespersons_3nf;
DROP TABLE IF EXISTS orders_3nf;

CREATE TABLE customers_3nf (
    customer_email VARCHAR(150) PRIMARY KEY,
    customer_name  VARCHAR(100),
    customer_city  VARCHAR(80)
);

CREATE TABLE salespersons_3nf (
    salesperson_id INT PRIMARY KEY AUTO_INCREMENT,
    salesperson    VARCHAR(100) UNIQUE,
    sales_region   VARCHAR(50)
);

CREATE TABLE orders_3nf (
    order_id         INT PRIMARY KEY,
    customer_email   VARCHAR(150),
    salesperson_id   INT,
    order_date       DATE,
    FOREIGN KEY (customer_email)  REFERENCES customers_3nf(customer_email),
    FOREIGN KEY (salesperson_id)  REFERENCES salespersons_3nf(salesperson_id)
);

INSERT INTO customers_3nf SELECT DISTINCT customer_email,customer_name,customer_city FROM orders_2nf;
INSERT INTO salespersons_3nf (salesperson,sales_region) SELECT DISTINCT salesperson,sales_region FROM orders_2nf;
INSERT INTO orders_3nf SELECT o.order_id, o.customer_email, s.salesperson_id, o.order_date
FROM orders_2nf o JOIN salespersons_3nf s ON o.salesperson = s.salesperson;

-- ─────────────────────────────────────────────────────────────
-- Q4. Social Media Platform Schema
-- ─────────────────────────────────────────────────────────────
DROP TABLE IF EXISTS dm_messages;
DROP TABLE IF EXISTS post_tags;
DROP TABLE IF EXISTS hashtags;
DROP TABLE IF EXISTS comment_likes;
DROP TABLE IF EXISTS post_likes;
DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS follows;
DROP TABLE IF EXISTS user_profiles;
DROP TABLE IF EXISTS sm_users;

CREATE TABLE sm_users (
    user_id      INT PRIMARY KEY AUTO_INCREMENT,
    username     VARCHAR(50) UNIQUE NOT NULL,
    email        VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_active    BOOLEAN DEFAULT TRUE,
    is_deleted   BOOLEAN DEFAULT FALSE
) ENGINE=InnoDB;

CREATE TABLE user_profiles (
    user_id      INT PRIMARY KEY,
    display_name VARCHAR(100),
    bio          TEXT,
    avatar_url   VARCHAR(500),
    website      VARCHAR(200),
    location     VARCHAR(100),
    updated_at   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES sm_users(user_id)
) ENGINE=InnoDB;

CREATE TABLE follows (
    follower_id  INT NOT NULL,
    following_id INT NOT NULL,
    followed_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (follower_id, following_id),
    FOREIGN KEY (follower_id)  REFERENCES sm_users(user_id),
    FOREIGN KEY (following_id) REFERENCES sm_users(user_id),
    CHECK (follower_id != following_id)   -- can't follow yourself
) ENGINE=InnoDB;

CREATE TABLE posts (
    post_id      INT PRIMARY KEY AUTO_INCREMENT,
    user_id      INT NOT NULL,
    post_type    ENUM('text','image','video') DEFAULT 'text',
    content      TEXT,
    media_url    VARCHAR(500),
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted   BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES sm_users(user_id),
    INDEX idx_post_user (user_id),
    INDEX idx_post_created (created_at)
) ENGINE=InnoDB;

CREATE TABLE comments (
    comment_id   INT PRIMARY KEY AUTO_INCREMENT,
    post_id      INT NOT NULL,
    user_id      INT NOT NULL,
    parent_id    INT DEFAULT NULL,   -- NULL = top-level; set = reply to another comment
    content      TEXT NOT NULL,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_deleted   BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (post_id)   REFERENCES posts(comment_id),
    FOREIGN KEY (user_id)   REFERENCES sm_users(user_id),
    FOREIGN KEY (parent_id) REFERENCES comments(comment_id)
) ENGINE=InnoDB;

CREATE TABLE post_likes (
    user_id    INT NOT NULL,
    post_id    INT NOT NULL,
    liked_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, post_id),
    FOREIGN KEY (user_id) REFERENCES sm_users(user_id),
    FOREIGN KEY (post_id) REFERENCES posts(post_id)
) ENGINE=InnoDB;

CREATE TABLE hashtags (
    tag_id    INT PRIMARY KEY AUTO_INCREMENT,
    tag_name  VARCHAR(100) UNIQUE NOT NULL
) ENGINE=InnoDB;

CREATE TABLE post_tags (
    post_id   INT NOT NULL,
    tag_id    INT NOT NULL,
    PRIMARY KEY (post_id, tag_id),
    FOREIGN KEY (post_id) REFERENCES posts(post_id),
    FOREIGN KEY (tag_id)  REFERENCES hashtags(tag_id)
) ENGINE=InnoDB;

CREATE TABLE dm_messages (
    msg_id       INT PRIMARY KEY AUTO_INCREMENT,
    sender_id    INT NOT NULL,
    receiver_id  INT NOT NULL,
    content      TEXT NOT NULL,
    sent_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    read_at      DATETIME,
    is_deleted_by_sender   BOOLEAN DEFAULT FALSE,
    is_deleted_by_receiver BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (sender_id)   REFERENCES sm_users(user_id),
    FOREIGN KEY (receiver_id) REFERENCES sm_users(user_id)
) ENGINE=InnoDB;

-- Q5. Sample data.
INSERT INTO sm_users (username, email, password_hash) VALUES
 ('alice_j','alice@social.com','hash1'),('bob_s','bob@social.com','hash2'),
 ('carol_w','carol@social.com','hash3'),('dave_l','dave@social.com','hash4'),
 ('eve_m','eve@social.com','hash5');
INSERT INTO user_profiles VALUES (1,'Alice Johnson','Data lover | SQL nerd',NULL,'alice.dev','NYC',NOW()),
 (2,'Bob Smith','Coffee & code',NULL,NULL,'LA',NOW()), (3,'Carol White','Designer',NULL,NULL,'Chicago',NOW()),
 (4,'Dave Lee','Backend Engineer',NULL,'dave.io','London',NOW()), (5,'Eve M','ML Engineer',NULL,NULL,'Berlin',NOW());
INSERT INTO follows VALUES (1,2,NOW()),(1,3,NOW()),(2,1,NOW()),(3,1,NOW()),(4,1,NOW()),(2,4,NOW()),(5,1,NOW());
INSERT INTO posts (user_id,post_type,content) VALUES
 (1,'text','SQL window functions are amazing! #sql #data'),(2,'text','Just shipped v2.0 #coding'),
 (3,'image','My new design system #ux'),(4,'text','Why indexes matter #sql #database'),
 (5,'text','GPT-5 thoughts #ai #ml');
INSERT INTO post_likes VALUES (2,1,NOW()),(3,1,NOW()),(4,1,NOW()),(5,1,NOW()),(1,2,NOW()),(3,2,NOW()),(1,4,NOW());
INSERT INTO hashtags (tag_name) VALUES ('sql'),('data'),('coding'),('ux'),('database'),('ai'),('ml');

-- Q6. Analytics queries.
-- (a) Top 5 most-followed users:
SELECT u.username, COUNT(f.follower_id) AS followers
FROM sm_users u
LEFT JOIN follows f ON u.user_id = f.following_id
GROUP BY u.user_id, u.username
ORDER BY followers DESC LIMIT 5;

-- (b) Most liked post in last 30 days:
SELECT p.post_id, p.content, COUNT(pl.user_id) AS like_count
FROM posts p
JOIN post_likes pl ON p.post_id = pl.post_id
WHERE pl.liked_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY p.post_id, p.content
ORDER BY like_count DESC LIMIT 1;

-- (c) Mutual follows (users who follow each other):
SELECT a.follower_id AS user_a, a.following_id AS user_b
FROM follows a
JOIN follows b ON a.follower_id = b.following_id AND a.following_id = b.follower_id
WHERE a.follower_id < a.following_id;  -- avoid showing (A,B) and (B,A)

-- (d) Top 10 trending hashtags:
SELECT h.tag_name, COUNT(pt.post_id) AS use_count
FROM hashtags h
JOIN post_tags pt ON h.tag_id = pt.tag_id
GROUP BY h.tag_id, h.tag_name
ORDER BY use_count DESC LIMIT 10;

-- Q7. Theory
/*
(a) SURROGATE vs NATURAL KEY:
    Surrogate: system-generated (AUTO_INCREMENT INT, UUID). No business meaning.
               Use when: no stable natural key exists, or natural key is complex/long.
    Natural: has real-world meaning (email, SSN, ISBN).
             Use when: guaranteed unique, stable, and simple.
    Rule of thumb: prefer surrogate keys for PKs; keep natural keys as UNIQUE constraints.

(b) WHEN TO DENORMALIZE:
    - Reporting/Analytics: pre-join tables for fast reads on large datasets.
    - Materialized views / summary tables: store aggregates to avoid repeated computation.
    - High-read, low-write: e.g. a product catalog read by millions.
    - When JOINs become a performance bottleneck in production queries.
    - Example: store customer_city in orders table instead of joining customers.

(c) REFERENTIAL INTEGRITY:
    The guarantee that FK values always point to existing PK values.
    MySQL enforces this with FOREIGN KEY constraints (InnoDB only).
    Behaviors: ON DELETE CASCADE/SET NULL/RESTRICT; ON UPDATE CASCADE.

(d) BCNF vs 3NF:
    3NF:  Every non-prime attribute is non-transitively dependent on every key.
    BCNF: Every determinant is a candidate key. Stricter than 3NF.
    Difference: A table can be in 3NF but not BCNF when there are multiple
    overlapping candidate keys. BCNF eliminates ALL anomalies from functional deps.

(e) SOFT DELETES (is_deleted=TRUE):
    Pros: Data can be recovered. Audit trail preserved. FKs don't break.
          "Undo" functionality is trivial.
    Cons: Queries must always filter WHERE is_deleted=FALSE.
          Performance degrades (extra column in every query + index bloat).
          Storage usage never shrinks.
    Mitigation: Partial indexes (WHERE is_deleted=FALSE), archive old deleted rows.
*/
