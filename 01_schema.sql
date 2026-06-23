-- ============================================================
-- FOOD DELIVERY ANALYTICS PROJECT - DATABASE SCHEMA
-- ============================================================
-- Run this first to create the database structure.
-- Tested for MySQL / PostgreSQL (minor syntax tweaks noted below)

CREATE DATABASE IF NOT EXISTS food_delivery_analytics;
USE food_delivery_analytics;

-- ------------------------------------------------------------
-- 1. CUSTOMERS
-- ------------------------------------------------------------
CREATE TABLE customers (
    customer_id   VARCHAR(15) PRIMARY KEY,
    customer_name VARCHAR(100),
    city          VARCHAR(50),
    signup_date   DATE,
    age           INT,
    gender        VARCHAR(20)
);

-- ------------------------------------------------------------
-- 2. RESTAURANTS
-- ------------------------------------------------------------
CREATE TABLE restaurants (
    restaurant_id    VARCHAR(15) PRIMARY KEY,
    restaurant_name  VARCHAR(150),
    city             VARCHAR(50),
    category         VARCHAR(50),
    avg_cost_for_two INT,
    rating           DECIMAL(2,1),
    onboard_date     DATE
);

-- ------------------------------------------------------------
-- 3. DELIVERY PARTNERS
-- ------------------------------------------------------------
CREATE TABLE delivery_partners (
    delivery_partner_id VARCHAR(15) PRIMARY KEY,
    partner_name         VARCHAR(100),
    city                  VARCHAR(50),
    vehicle_type          VARCHAR(20),
    join_date             DATE,
    partner_rating        DECIMAL(2,1)
);

-- ------------------------------------------------------------
-- 4. ORDERS  (fact table - references the 3 above)
-- ------------------------------------------------------------
CREATE TABLE orders (
    order_id            BIGINT PRIMARY KEY,
    customer_id         VARCHAR(15),
    restaurant_id       VARCHAR(15),
    delivery_partner_id VARCHAR(15),
    order_date          DATE,
    order_value         DECIMAL(10,2),
    status              VARCHAR(20),       -- Delivered / Cancelled / Delayed
    delivery_time_min   DECIMAL(5,1),
    customer_rating     DECIMAL(2,1),
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_orders_restaurant
        FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id),
    CONSTRAINT fk_orders_partner
        FOREIGN KEY (delivery_partner_id) REFERENCES delivery_partners(delivery_partner_id)
);

-- ------------------------------------------------------------
-- 5. PAYMENTS (1-to-1 with orders)
-- ------------------------------------------------------------
CREATE TABLE payments (
    transaction_id     VARCHAR(20) PRIMARY KEY,
    order_id            BIGINT,
    payment_mode        VARCHAR(20),
    amount               DECIMAL(10,2),
    transaction_status   VARCHAR(20),       -- Success / Failed / Pending / Refunded
    CONSTRAINT fk_payments_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- ------------------------------------------------------------
-- INDEXES (for faster joins/aggregations on large fact table)
-- ------------------------------------------------------------
CREATE INDEX idx_orders_customer   ON orders(customer_id);
CREATE INDEX idx_orders_restaurant ON orders(restaurant_id);
CREATE INDEX idx_orders_partner    ON orders(delivery_partner_id);
CREATE INDEX idx_orders_date       ON orders(order_date);
CREATE INDEX idx_payments_order    ON payments(order_id);

-- ------------------------------------------------------------
-- LOAD DATA (MySQL example - adjust path; use \copy in PostgreSQL psql)
-- ------------------------------------------------------------
-- LOAD DATA INFILE '/path/to/customers_clean.csv'
-- INTO TABLE customers
-- FIELDS TERMINATED BY ',' ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;
-- (Repeat similarly for restaurants, delivery_partners, orders, payments
--  -- load customers/restaurants/delivery_partners BEFORE orders,
--     and orders BEFORE payments, to respect foreign keys)
