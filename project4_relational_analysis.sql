-- ============================================================
-- MINI PROJECT 04: RELATIONAL ANALYSIS WITH JOINs
--
-- Topics: INNER JOIN, LEFT JOIN, RIGHT JOIN, SELF JOIN,
-- CROSS JOIN, multiple-table JOINs, aggregation, and missing
-- relationships.
--
-- ============================================================

USE classicmodels;


-- ------------------------------------------------------------
-- 1. CUSTOMER & PAYMENT ANALYSIS
-- Show the 10 most recent payments with customer name and phone.
-- ------------------------------------------------------------
SELECT
    p.checkNumber,
    p.paymentDate,
    p.amount,
    c.customerNumber,
    c.customerName,
    c.phone
FROM payments AS p
INNER JOIN customers AS c
    ON p.customerNumber = c.customerNumber
ORDER BY p.paymentDate DESC
LIMIT 10;


-- ------------------------------------------------------------
-- 2. EMPLOYEE & OFFICE ANALYSIS
-- Show each employee's office details and full office address.
-- ------------------------------------------------------------
SELECT
    e.employeeNumber,
    CONCAT_WS(' ', e.firstName, e.lastName) AS employeeName,
    o.officeCode,
    o.phone AS officePhone,
    o.addressLine1,
    o.addressLine2,
    o.city,
    o.state,
    o.country,
    o.postalCode
FROM employees AS e
INNER JOIN offices AS o
    ON e.officeCode = o.officeCode
ORDER BY e.firstName, e.lastName;


-- ------------------------------------------------------------
-- 3. ORDER & PRODUCT ANALYSIS
-- Show product details for order number 10100.
-- ------------------------------------------------------------
SELECT
    od.orderNumber,
    od.productCode,
    p.productName,
    od.quantityOrdered,
    od.priceEach,
    od.quantityOrdered * od.priceEach AS lineTotal
FROM orderdetails AS od
INNER JOIN products AS p
    ON od.productCode = p.productCode
WHERE od.orderNumber = 10100
ORDER BY p.productName;


-- ------------------------------------------------------------
-- 4. OFFICE ANALYSIS
-- Count employees in each office and show the office country.
-- ------------------------------------------------------------
SELECT
    o.officeCode,
    o.city,
    o.country,
    COUNT(e.employeeNumber) AS employeeCount
FROM offices AS o
LEFT JOIN employees AS e
    ON o.officeCode = e.officeCode
GROUP BY o.officeCode, o.city, o.country
ORDER BY employeeCount DESC, o.officeCode;


-- ------------------------------------------------------------
-- 5. CUSTOMER, ORDER & PRODUCT ANALYSIS
-- List the customer and products ordered in order number 10100.
-- ------------------------------------------------------------
SELECT
    c.customerName,
    c.contactFirstName,
    c.contactLastName,
    o.orderNumber,
    p.productName,
    od.quantityOrdered,
    od.priceEach
FROM customers AS c
INNER JOIN orders AS o
    ON c.customerNumber = o.customerNumber
INNER JOIN orderdetails AS od
    ON o.orderNumber = od.orderNumber
INNER JOIN products AS p
    ON od.productCode = p.productCode
WHERE o.orderNumber = 10100
ORDER BY p.productName;


-- ------------------------------------------------------------
-- 6. SALES REPRESENTATIVE ANALYSIS
-- Show each customer and their assigned sales representative.
-- INNER JOIN includes customers with an assigned representative.
-- ------------------------------------------------------------
SELECT
    c.customerName,
    e.employeeNumber,
    CONCAT_WS(' ', e.firstName, e.lastName) AS salesRepresentative,
    e.email
FROM customers AS c
INNER JOIN employees AS e
    ON c.salesRepEmployeeNumber = e.employeeNumber
ORDER BY c.customerName;


-- ------------------------------------------------------------
-- 7. EMPLOYEE HIERARCHY (SELF JOIN)
-- Show each employee and their manager.
-- LEFT JOIN keeps employees who do not report to another employee.
-- ------------------------------------------------------------
SELECT
    e.employeeNumber,
    CONCAT_WS(' ', e.firstName, e.lastName) AS employeeName,
    m.employeeNumber AS managerEmployeeNumber,
    CONCAT_WS(' ', m.firstName, m.lastName) AS managerName
FROM employees AS e
LEFT JOIN employees AS m
    ON e.reportsTo = m.employeeNumber
ORDER BY e.employeeNumber;


-- ------------------------------------------------------------
-- 8. ALL CUSTOMERS AND THEIR ORDERS
-- LEFT JOIN includes customers who have not placed orders.
-- ------------------------------------------------------------
SELECT
    c.customerNumber,
    c.customerName,
    o.orderNumber,
    o.orderDate,
    o.status
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customerNumber = o.customerNumber
ORDER BY c.customerName, o.orderNumber;


-- ------------------------------------------------------------
-- 9. CUSTOMERS WITHOUT ORDERS
-- ------------------------------------------------------------
SELECT
    c.customerNumber,
    c.customerName,
    c.country
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customerNumber = o.customerNumber
WHERE o.orderNumber IS NULL
ORDER BY c.customerName;


-- ------------------------------------------------------------
-- 10. RIGHT JOIN EXAMPLE
-- Show all customers and any matching orders using RIGHT JOIN.
-- This is equivalent in purpose to section 8, but reverses the
-- table order. In a normal ClassicModels dataset, orders are
-- expected to have a customer, so unmatched orders may not exist.
-- ------------------------------------------------------------
SELECT
    o.orderNumber,
    o.orderDate,
    c.customerNumber,
    c.customerName
FROM orders AS o
RIGHT JOIN customers AS c
    ON o.customerNumber = c.customerNumber
ORDER BY c.customerName, o.orderNumber;


-- ------------------------------------------------------------
-- 11. PRODUCTS ORDERED ON A MONDAY
-- DAYOFWEEK(): Sunday = 1, Monday = 2, ..., Saturday = 7.
-- ------------------------------------------------------------
SELECT DISTINCT
    p.productCode,
    p.productName,
    o.orderNumber,
    o.orderDate,
    DAYNAME(o.orderDate) AS weekday
FROM products AS p
INNER JOIN orderdetails AS od
    ON p.productCode = od.productCode
INNER JOIN orders AS o
    ON od.orderNumber = o.orderNumber
WHERE DAYOFWEEK(o.orderDate) = 2
ORDER BY o.orderDate, p.productName;


-- ------------------------------------------------------------
-- 12. PRODUCTS THAT HAVE NEVER BEEN SOLD
-- ------------------------------------------------------------
SELECT
    p.productCode,
    p.productName,
    p.productLine
FROM products AS p
LEFT JOIN orderdetails AS od
    ON p.productCode = od.productCode
WHERE od.productCode IS NULL
ORDER BY p.productName;


-- ------------------------------------------------------------
-- 13. PAYMENTS GREATER THAN $100,000
-- ------------------------------------------------------------
SELECT
    p.customerNumber,
    c.customerName,
    p.checkNumber,
    p.paymentDate,
    p.amount
FROM payments AS p
INNER JOIN customers AS c
    ON p.customerNumber = c.customerNumber
WHERE p.amount > 100000
ORDER BY p.amount DESC;


-- ------------------------------------------------------------
-- 14. PRODUCTS SOLD AT LEAST TWICE THEIR BUY PRICE
-- A markup of 100% or more means sale price >= 2 * buy price.
-- ------------------------------------------------------------
SELECT
    p.productCode,
    p.productName,
    p.buyPrice,
    od.priceEach AS salePrice,
    od.quantityOrdered,
    ROUND(od.priceEach - p.buyPrice, 2) AS unitDifference
FROM products AS p
INNER JOIN orderdetails AS od
    ON p.productCode = od.productCode
WHERE od.priceEach >= p.buyPrice * 2
ORDER BY unitDifference DESC, p.productName;


-- ------------------------------------------------------------
-- 15. CROSS JOIN: ALL PRODUCT-CUSTOMER COMBINATIONS
-- This intentionally creates every possible product/customer pair.
-- The output can be very large.
-- ------------------------------------------------------------
SELECT
    p.productName,
    c.customerName
FROM products AS p
CROSS JOIN customers AS c
ORDER BY p.productName, c.customerName;


-- ------------------------------------------------------------
-- 16. CROSS JOIN: ALL EMPLOYEE-CUSTOMER COMBINATIONS
-- This also creates every possible pair and can return many rows.
-- ------------------------------------------------------------
SELECT
    e.employeeNumber,
    CONCAT_WS(' ', e.firstName, e.lastName) AS employeeName,
    c.customerNumber,
    c.customerName
FROM employees AS e
CROSS JOIN customers AS c
ORDER BY employeeName, c.customerName;


-- ------------------------------------------------------------
-- 17. CROSS JOIN: ORDER DATES AND PRODUCTS
-- Generate every distinct order date in the requested period
-- paired with every product. This is not a continuous calendar:
-- it includes only dates present in the orders table.
-- ------------------------------------------------------------
SELECT
    d.orderDate,
    p.productCode,
    p.productName
FROM (
    SELECT DISTINCT DATE(orderDate) AS orderDate
    FROM orders
    WHERE orderDate >= '2003-01-01'
      AND orderDate <  '2004-06-15'
) AS d
CROSS JOIN products AS p
ORDER BY d.orderDate, p.productName;


-- ------------------------------------------------------------
-- 18. OBSERVATION QUERY: CUSTOMERS AND NUMBER OF ORDERS
-- Useful for reporting customers with the most orders.
-- LEFT JOIN keeps customers with zero orders.
-- ------------------------------------------------------------
SELECT
    c.customerNumber,
    c.customerName,
    COUNT(o.orderNumber) AS orderCount
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customerNumber = o.customerNumber
GROUP BY c.customerNumber, c.customerName
ORDER BY orderCount DESC, c.customerName;
