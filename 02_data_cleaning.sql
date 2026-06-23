-- ============================================================
-- FOOD DELIVERY ANALYTICS PROJECT - DATA CLEANING (SQL LEVEL)
-- ============================================================
-- Run this AFTER loading raw CSVs into the tables from 01_schema.sql
-- This documents the SQL-side cleaning (separate from Excel-side cleaning)

-- 1. Remove duplicate orders (keep the first occurrence by order_id)
DELETE o1 FROM orders o1
INNER JOIN orders o2
    ON o1.order_id = o2.order_id
WHERE o1.customer_id = o2.customer_id   -- safeguard: identical full duplicate rows
  AND o1.order_date  = o2.order_date
  AND o1.order_id    > o2.order_id;     -- keeps the lower physical row

-- (If your SQL engine doesn't support DELETE...JOIN, use this PostgreSQL-style version instead)
-- DELETE FROM orders
-- WHERE order_id IN (
--     SELECT order_id FROM (
--         SELECT order_id,
--                ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_date) AS rn
--         FROM orders
--     ) t WHERE rn > 1
-- );

-- 2. Fix negative/zero order values -> set to NULL (true anomalies, can't be guessed)
UPDATE orders
SET order_value = NULL
WHERE order_value <= 0;

-- 3. Standardize city name casing/spacing across all tables
UPDATE customers        SET city = INITCAP(TRIM(city));
UPDATE restaurants       SET city = INITCAP(TRIM(city));
UPDATE delivery_partners SET city = INITCAP(TRIM(city));
-- Note: INITCAP is PostgreSQL. In MySQL use:
-- UPDATE customers SET city = CONCAT(UPPER(LEFT(TRIM(city),1)), LOWER(SUBSTRING(TRIM(city),2)));

-- 4. Standardize payment mode values (messy casing/blank entries)
UPDATE payments
SET payment_mode = CASE
    WHEN LOWER(TRIM(payment_mode)) = 'upi'  THEN 'UPI'
    WHEN LOWER(TRIM(payment_mode)) = 'cash' THEN 'Cash'
    WHEN TRIM(payment_mode) = ''            THEN 'Not Specified'
    ELSE TRIM(payment_mode)
END;

-- 5. Fill missing gender with 'Not Specified'
UPDATE customers
SET gender = 'Not Specified'
WHERE gender IS NULL OR TRIM(gender) = '';

-- 6. Sanity check queries after cleaning
SELECT COUNT(*) AS total_orders FROM orders;
SELECT COUNT(*) AS duplicate_check, order_id
FROM orders GROUP BY order_id HAVING COUNT(*) > 1;
SELECT COUNT(*) AS null_order_values FROM orders WHERE order_value IS NULL;
SELECT DISTINCT city FROM customers ORDER BY city;
SELECT DISTINCT payment_mode FROM payments;
