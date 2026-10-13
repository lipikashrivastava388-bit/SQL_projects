-- ============================================================
-- MINI PROJECT 03: DATA CLEANING & TRANSFORMATION
-- Purpose: Identify and clean incomplete, inconsistent, and
-- duplicated data; transform fields for analysis.
-- ============================================================

USE classicmodels;


SELECT * FROM customers;
SELECT * FROM employees;
SELECT * FROM offices;
SELECT * FROM payments;
SELECT * FROM orders;
SELECT * FROM orderdetails;
SELECT * FROM products;


-- ------------------------------------------------------------
-- 1. MISSING VALUES: CUSTOMER ADDRESS
-- ------------------------------------------------------------
SELECT
    customerNumber,
    customerName,
    addressLine1,
    COALESCE(NULLIF(TRIM(addressLine2), ''), 'N/A') AS addressLine2_clean,
    city,
    COALESCE(NULLIF(TRIM(state), ''), 'Unknown') AS state_clean,
    COALESCE(NULLIF(TRIM(postalCode), ''), 'Unknown') AS postalCode_clean,
    country
FROM customers
ORDER BY customerNumber;


-- ------------------------------------------------------------
-- 2. NAME CLEANING: CUSTOMER CONTACTS AND EMPLOYEES
-- TRIM removes leading/trailing spaces and CONCAT combines names.
-- ------------------------------------------------------------
SELECT
    customerNumber,
    customerName,
    TRIM(CONCAT_WS(' ',
        NULLIF(TRIM(contactFirstName), ''),
        NULLIF(TRIM(contactLastName), '')
    )) AS contactFullName_clean,
    phone
FROM customers
ORDER BY customerNumber;

SELECT
    employeeNumber,
    TRIM(CONCAT_WS(' ',
        NULLIF(TRIM(firstName), ''),
        NULLIF(TRIM(lastName), '')
    )) AS employeeFullName_clean,
    LOWER(TRIM(email)) AS email_clean
FROM employees
ORDER BY employeeNumber;


-- ------------------------------------------------------------
-- 3. EMAIL CLEANING
-- address validation.
-- ------------------------------------------------------------
SELECT
    employeeNumber,
    email AS original_email,
    LOWER(TRIM(email)) AS cleaned_email,
    CASE
        WHEN email IS NULL OR TRIM(email) = '' THEN 'Missing email'
        WHEN LOWER(TRIM(email)) NOT LIKE '%_@_%._%' THEN 'Review email format'
        ELSE 'Present - basic format check passed'
    END AS email_status
FROM employees
ORDER BY employeeNumber;


-- ------------------------------------------------------------
-- 4. PHONE NUMBER CLEANING
-- Remove non-numeric characters from office phone numbers.
-- Keep the original value in the output for comparison.
-- ------------------------------------------------------------
SELECT
    officeCode,
    city,
    phone AS original_phone,
    REGEXP_REPLACE(phone, '[^0-9]', '') AS cleaned_phone_number
FROM offices
ORDER BY officeCode;


-- ------------------------------------------------------------
-- 5. DUPLICATE DETECTION: PAYMENTS
-- Find cases where the same customer has the same payment date
-- and exact amount more than once.
-- ------------------------------------------------------------
SELECT
    customerNumber,
    paymentDate,
    amount,
    COUNT(*) AS duplicate_count
FROM payments
GROUP BY customerNumber, paymentDate, amount
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, customerNumber, paymentDate;


-- ------------------------------------------------------------
-- 6. DUPLICATE-LIKE ORDER PATTERNS
-- Find customers who ordered the same product on the same date
-- across more than one order line/order.
-- This flags repeated patterns for review; it does not prove an
-- error because a customer may legitimately reorder a product.
-- ------------------------------------------------------------
SELECT
    o.customerNumber,
    c.customerName,
    DATE(o.orderDate) AS order_date,
    od.productCode,
    p.productName,
    COUNT(*) AS times_ordered
FROM orders AS o
JOIN orderdetails AS od ON od.orderNumber = o.orderNumber
JOIN customers AS c ON c.customerNumber = o.customerNumber
JOIN products AS p ON p.productCode = od.productCode
GROUP BY
    o.customerNumber,
    c.customerName,
    DATE(o.orderDate),
    od.productCode,
    p.productName
HAVING COUNT(*) > 1
ORDER BY times_ordered DESC, o.customerNumber, order_date;


-- ------------------------------------------------------------
-- 7. ORDER ANALYSIS: FULFILMENT DURATION
-- Show the number of days between order and shipment.
-- Unshipped orders are labelled rather than assigned a duration.
-- ------------------------------------------------------------
SELECT
    orderNumber,
    orderDate,
    shippedDate,
    status,
    CASE
        WHEN shippedDate IS NULL THEN 'Not Shipped Yet'
        ELSE CAST(DATEDIFF(shippedDate, orderDate) AS CHAR)
    END AS fulfilment_days
FROM orders
ORDER BY orderNumber;


-- ------------------------------------------------------------
-- 8. PRODUCT TRANSFORMATION: SCALE FACTOR
-- ------------------------------------------------------------
SELECT
    productCode,
    productName,
    productScale,
    CAST(SUBSTRING_INDEX(productScale, ':', -1) AS UNSIGNED) AS scale_factor
FROM products
ORDER BY productCode;


-- ------------------------------------------------------------
-- 9. DATA INCONSISTENCY: INVALID CREDIT LIMITS
-- Find customers with a NULL or zero credit limit who have placed
-- at least one order. The query reports the number of orders.
-- ------------------------------------------------------------
SELECT
    c.customerNumber,
    c.customerName,
    COALESCE(c.creditLimit, 0.00) AS current_credit_limit,
    COUNT(o.orderNumber) AS total_orders_placed
FROM customers AS c
JOIN orders AS o ON o.customerNumber = c.customerNumber
WHERE c.creditLimit IS NULL OR c.creditLimit = 0.00
GROUP BY c.customerNumber, c.customerName, c.creditLimit
ORDER BY total_orders_placed DESC, c.customerNumber;


-- ------------------------------------------------------------
-- 10. STANDARDISATION PREVIEW: COUNTRY NAMES
-- Preview the proposed replacements before changing stored data.
-- ------------------------------------------------------------
SELECT
    customerNumber,
    customerName,
    country AS original_country,
    CASE
        WHEN country = 'USA' THEN 'United States'
        WHEN country = 'UK' THEN 'United Kingdom'
        ELSE country
    END AS standardised_country
FROM customers
WHERE country IN ('USA', 'UK')
ORDER BY customerNumber;


-- ------------------------------------------------------------
-- 11. APPLY COUNTRY STANDARDISATION (OPTIONAL WRITE OPERATION)
-- Review section 10 first. This permanently updates the table.
-- If your SQL client uses safe-update mode, use a primary-key
-- condition or adjust your client settings as appropriate.
-- ------------------------------------------------------------
-- START TRANSACTION;
-- UPDATE customers
-- SET country = CASE
--     WHEN country = 'USA' THEN 'United States'
--     WHEN country = 'UK' THEN 'United Kingdom'
--     ELSE country
-- END
-- WHERE country IN ('USA', 'UK');
-- SELECT customerNumber, customerName, country
-- FROM customers
-- WHERE country IN ('United States', 'United Kingdom')
-- ORDER BY customerNumber;
-- COMMIT;
-- Use ROLLBACK instead of COMMIT if you want to undo the change
-- before committing the transaction.


-- ------------------------------------------------------------
-- 12. POST-CLEANING CHECK
-- After running the optional UPDATE above, use this query to
-- check whether the old country labels remain.
-- ------------------------------------------------------------
SELECT country, COUNT(*) AS customer_count
FROM customers
GROUP BY country
ORDER BY country;
