/*
============================================================
MINI PROJECT 02 - CLASSICMODELS QUERY CHALLENGE
============================================================

Skills demonstrated:
SELECT, WHERE, ORDER BY, GROUP BY, HAVING, LIKE, IN,
LIMIT, OFFSET, aggregate functions, subqueries, joins,
filtering, sorting, date functions, string functions,
views, indexes and cross joins.
============================================================
*/

USE classicmodels;

SHOW TABLES;


-- ==========================================================
-- SECTION 1: CUSTOMER ANALYSIS
-- ==========================================================

-- Q1. Show all customers with selected details.
SELECT
    customerName,
    contactFirstName,
    contactLastName,
    country,
    creditLimit
FROM customers;


-- Q2. List all customers in USA and France.
SELECT *
FROM customers
WHERE country IN ('USA', 'France');


-- Q3. List USA customers with credit limit higher than $1,000.
SELECT *
FROM customers
WHERE country = 'USA'
  AND creditLimit > 1000;


-- Q4. List customers in Australia and Norway with credit
-- limit higher than $1,000.
SELECT *
FROM customers
WHERE country IN ('Australia', 'Norway')
  AND creditLimit > 1000;


-- Q5. List customers in USA, France, Australia and Poland.
SELECT *
FROM customers
WHERE country IN ('USA', 'France', 'Australia', 'Poland');


-- Q6. Employee codes for sales representatives of customers
-- in Spain, France and Italy.
SELECT DISTINCT
    salesRepEmployeeNumber
FROM customers
WHERE country IN ('Spain', 'France', 'Italy')
  AND salesRepEmployeeNumber IS NOT NULL;


-- Q7. Names and email addresses of those sales representatives.
SELECT
    e.employeeNumber,
    e.firstName,
    e.lastName,
    e.email,
    e.officeCode
FROM employees AS e
WHERE e.employeeNumber IN (
    SELECT DISTINCT salesRepEmployeeNumber
    FROM customers
    WHERE country IN ('Spain', 'France', 'Italy')
      AND salesRepEmployeeNumber IS NOT NULL
);


-- Q8. Change job title "Sales Rep" to "Sales Representative".
SET SQL_SAFE_UPDATES = 0;

UPDATE employees
SET jobTitle = 'Sales Representative'
WHERE jobTitle = 'Sales Rep';


-- Q9. Employees who are not sales representatives.
SELECT *
FROM employees
WHERE jobTitle <> 'Sales Representative';


-- Q10. Customers with "Toys" in their name.
SELECT *
FROM customers
WHERE customerName LIKE '%Toys%';


-- Q11. Customers whose first name starts with A.
SELECT *
FROM customers
WHERE contactFirstName LIKE 'A%';


-- Q12. Customers whose first name ends with n.
SELECT *
FROM customers
WHERE contactFirstName LIKE '%n';


-- Q13. Customers whose first name starts with B and ends with n.
SELECT *
FROM customers
WHERE contactFirstName LIKE 'B%n';


-- Q14. Customers sorted by first name ascending.
SELECT *
FROM customers
ORDER BY contactFirstName ASC;


-- ==========================================================
-- SECTION 2: PRODUCT ANALYSIS
-- ==========================================================

-- Q15. Products containing "Harley" in the product name.
SELECT *
FROM products
WHERE productName LIKE '%Harley%';


-- Q16. Five most expensive products from Planes.
SELECT *
FROM products
WHERE productLine = 'Planes'
ORDER BY MSRP DESC
LIMIT 5;


-- Q17. Next five most expensive Planes products.
SELECT *
FROM products
WHERE productLine = 'Planes'
ORDER BY MSRP DESC
LIMIT 5 OFFSET 5;


-- Q18. Alternative MySQL pagination syntax.
SELECT *
FROM products
WHERE productLine = 'Planes'
ORDER BY MSRP DESC
LIMIT 5, 5;


-- Q19. Second most expensive product from Planes.
SELECT *
FROM products
WHERE productLine = 'Planes'
ORDER BY MSRP DESC
LIMIT 1 OFFSET 1;


-- Q20. Products about to run out of stock.
SELECT *
FROM products
WHERE quantityInStock < 100;


-- Q21. Ten cheapest Motorcycles products with more than
-- 1,000 units in stock.
SELECT
    productName,
    buyPrice,
    quantityInStock,
    productLine
FROM products
WHERE productLine = 'Motorcycles'
  AND quantityInStock > 1000
ORDER BY buyPrice ASC
LIMIT 10;


-- Q22. All Harley Davidson motorcycle products.
SELECT *
FROM products
WHERE productName LIKE '%Harley%';


-- Q23. Ten products with highest profit margin.
-- Profit margin = ((MSRP - buyPrice) * 100) / buyPrice
SELECT
    productCode,
    productName,
    buyPrice,
    MSRP,
    ROUND(((MSRP - buyPrice) * 100 / buyPrice), 2) AS ProfitMargin
FROM products
ORDER BY ProfitMargin DESC
LIMIT 10;


-- Q24. Product lines with highest average product prices.
SELECT
    productLine,
    ROUND(AVG(MSRP), 2) AS AveragePrice
FROM products
GROUP BY productLine
ORDER BY AveragePrice DESC;


-- Q25. Five most expensive Motorcycles products.
SELECT
    productName,
    productLine,
    ROUND(MSRP, 0) AS SalePrice
FROM products
WHERE productLine = 'Motorcycles'
ORDER BY SalePrice DESC
LIMIT 5;


-- Q26. Total quantities ordered for each product.
SELECT
    productCode,
    SUM(quantityOrdered) AS totalQuantity
FROM orderdetails
GROUP BY productCode
ORDER BY totalQuantity DESC;


-- Q27. Products sold at less than 80% of MSRP.
SELECT
    productName
FROM products
WHERE buyPrice < 0.8 * MSRP;


-- Q28. Products with more than 5,000 units in stock and
-- MSRP below $100.
SELECT *
FROM products
WHERE quantityInStock > 5000
  AND MSRP < 100;


-- ==========================================================
-- SECTION 3: PAYMENT ANALYSIS
-- ==========================================================

-- Q29. Total number of payments received before 28 Oct 2004.
SELECT COUNT(*) AS TotalPayments
FROM payments
WHERE paymentDate < '2004-10-28';


-- Q30. Number of customers who made payments before
-- 28 Oct 2004.
SELECT COUNT(DISTINCT customerNumber) AS CustomersWithPayments
FROM payments
WHERE paymentDate < '2004-10-28';


-- Q31. Customer numbers of customers who paid before
-- 28 Oct 2004.
SELECT DISTINCT
    customerNumber
FROM payments
WHERE paymentDate < '2004-10-28';


-- Q32. Details of customers who paid before 28 Oct 2004.
SELECT *
FROM customers
WHERE customerNumber IN (
    SELECT DISTINCT customerNumber
    FROM payments
    WHERE paymentDate < '2004-10-28'
);


-- Q33. USA customers who made payments between
-- 1 Apr 2003 and 31 Mar 2004.
SELECT *
FROM customers
WHERE country = 'USA'
  AND customerNumber IN (
      SELECT DISTINCT customerNumber
      FROM payments
      WHERE paymentDate BETWEEN '2003-04-01' AND '2004-03-31'
  );


-- Q34. Number of payments made by each customer before
-- 28 Oct 2004.
SELECT
    customerNumber,
    COUNT(*) AS TotalPayments
FROM payments
WHERE paymentDate < '2004-10-28'
GROUP BY customerNumber
ORDER BY TotalPayments DESC;


-- Q35. Total payment amount by customer before
-- 28 Oct 2004.
SELECT
    customerNumber,
    ROUND(SUM(amount), 2) AS TotalAmount
FROM payments
WHERE paymentDate < '2004-10-28'
GROUP BY customerNumber
ORDER BY TotalAmount DESC;


-- Q36. Total payments, total amount, average, minimum and
-- maximum payment for each customer before 28 Oct 2004.
SELECT
    customerNumber,
    COUNT(*) AS TotalPayments,
    ROUND(SUM(amount), 2) AS TotalAmount,
    ROUND(AVG(amount), 2) AS AverageAmount,
    ROUND(MIN(amount), 2) AS MinimumAmount,
    ROUND(MAX(amount), 2) AS MaximumAmount
FROM payments
WHERE paymentDate < '2004-10-28'
GROUP BY customerNumber
ORDER BY TotalAmount DESC;


-- Q37. Largest single payment made by every customer in 2004.
SELECT
    customerNumber,
    MAX(amount) AS LargestPayment
FROM payments
WHERE YEAR(paymentDate) = 2004
GROUP BY customerNumber
ORDER BY LargestPayment DESC;


-- Q38. Total payments month by month for every year.
SELECT
    YEAR(paymentDate) AS PaymentYear,
    MONTH(paymentDate) AS PaymentMonth,
    ROUND(SUM(amount), 2) AS TotalPayments
FROM payments
GROUP BY YEAR(paymentDate), MONTH(paymentDate)
ORDER BY PaymentYear, PaymentMonth;


-- Q39. Payments greater than $100,000.
SELECT *
FROM payments
WHERE amount > 100000;


-- ==========================================================
-- SECTION 4: ORDER ANALYSIS
-- ==========================================================

-- Q40. Number of orders placed by each customer.
SELECT
    customerNumber,
    COUNT(*) AS TotalNumberOfOrders
FROM orders
GROUP BY customerNumber
ORDER BY customerNumber ASC;


-- ==========================================================
-- SECTION 5: JOINS
-- ==========================================================

-- Q41. Ten most recent payments with customer name and phone.
SELECT
    p.checkNumber,
    p.paymentDate,
    p.amount,
    c.customerNumber,
    c.customerName,
    c.phone
FROM payments AS p
JOIN customers AS c
    ON p.customerNumber = c.customerNumber
ORDER BY p.paymentDate DESC
LIMIT 10;


-- Q42. Full office address and phone number for each employee.
SELECT
    e.firstName,
    e.lastName,
    o.officeCode,
    o.phone,
    o.addressLine1,
    o.addressLine2,
    o.city,
    o.state
FROM employees AS e
JOIN offices AS o
    ON e.officeCode = o.officeCode
ORDER BY e.firstName;


-- Q43. Full order information and product details for order 10100.
SELECT
    od.orderNumber,
    od.productCode,
    p.productName,
    od.quantityOrdered,
    od.priceEach
FROM orderdetails AS od
JOIN products AS p
    ON od.productCode = p.productCode
WHERE od.orderNumber = 10100;


-- Q44. Countries where offices are located and number of
-- employees in each office.
SELECT
    o.country,
    o.officeCode,
    COUNT(e.employeeNumber) AS employeeCount
FROM offices AS o
JOIN employees AS e
    ON o.officeCode = e.officeCode
GROUP BY o.officeCode, o.country
ORDER BY employeeCount DESC;


-- Q45. Customers and products ordered for order 10100.
SELECT
    c.contactFirstName,
    c.contactLastName,
    p.productName,
    od.quantityOrdered,
    od.priceEach
FROM customers AS c
JOIN orders AS o
    ON c.customerNumber = o.customerNumber
JOIN orderdetails AS od
    ON o.orderNumber = od.orderNumber
JOIN products AS p
    ON od.productCode = p.productCode
WHERE o.orderNumber = 10100;


-- Q46. Customer name and assigned sales representative.
SELECT
    c.customerName,
    e.employeeNumber,
    e.firstName,
    e.lastName,
    e.email
FROM customers AS c
JOIN employees AS e
    ON c.salesRepEmployeeNumber = e.employeeNumber
ORDER BY c.customerName;


-- Q47. Employees with the name and employee number of their manager.
SELECT
    e.employeeNumber,
    e.firstName,
    e.lastName,
    m.employeeNumber AS managerEmployeeNumber,
    CONCAT(m.firstName, ' ', m.lastName) AS managerName
FROM employees AS e
LEFT JOIN employees AS m
    ON e.reportsTo = m.employeeNumber
ORDER BY e.employeeNumber;


-- Q48. All customers and their orders, including customers
-- who have not placed orders.
SELECT
    c.customerName,
    o.orderNumber
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customerNumber = o.customerNumber
ORDER BY c.customerName;


-- Q49. Orders and associated customers.
SELECT
    o.orderNumber,
    c.customerName
FROM orders AS o
RIGHT JOIN customers AS c
    ON o.customerNumber = c.customerNumber;


-- Q50. Products ordered on a Monday.
SELECT
    p.productName,
    o.orderDate,
    DAYNAME(o.orderDate) AS Weekday
FROM products AS p
JOIN orderdetails AS od
    ON p.productCode = od.productCode
JOIN orders AS o
    ON od.orderNumber = o.orderNumber
WHERE DAYOFWEEK(o.orderDate) = 2;


-- Q51. Products that have not been sold.
SELECT
    p.productName
FROM products AS p
LEFT JOIN orderdetails AS od
    ON p.productCode = od.productCode
WHERE od.productCode IS NULL;


-- Q52. Products sold with a markup of 100% or more.
SELECT
    p.productName,
    p.buyPrice,
    od.priceEach
FROM products AS p
JOIN orderdetails AS od
    ON p.productCode = od.productCode
WHERE od.priceEach >= p.buyPrice * 2;


-- ==========================================================
-- SECTION 6: CROSS JOIN / COMBINATIONS
-- ==========================================================

-- Q53. Every possible product-customer combination.
SELECT
    p.productName,
    c.customerName
FROM products AS p
CROSS JOIN customers AS c;


-- Q54. Every possible employee-customer combination.
SELECT
    e.firstName,
    e.lastName,
    c.contactFirstName,
    c.contactLastName
FROM employees AS e
CROSS JOIN customers AS c;


-- Q55. Dates from the specified order-date range combined
-- with every product.
SELECT
    d.orderDate,
    p.productName
FROM (
    SELECT DISTINCT DATE(orderDate) AS orderDate
    FROM orders
    WHERE orderDate BETWEEN '2003-01-01' AND '2004-06-14'
) AS d
CROSS JOIN products AS p
ORDER BY d.orderDate, p.productName;


-- ==========================================================
-- SECTION 7: INDEX
-- ==========================================================

-- Q56. Add an index on customer contact last name.
-- IF NOT EXISTS is not supported consistently for MySQL
-- CREATE INDEX, so this statement is intended to be run once.
CREATE INDEX customer_lastname_index
ON customers (contactLastName);


-- Q57. Search using the indexed column.
SELECT *
FROM customers
WHERE contactLastName = 'Lee';


-- Q58. First 10 customers by last name.
SELECT *
FROM customers
ORDER BY contactLastName
LIMIT 10;


-- Q59. First 10 customers by first name.
SELECT *
FROM customers
ORDER BY contactFirstName
LIMIT 10;


-- Q60. Verify the index.
SHOW INDEX FROM customers;


-- ==========================================================
-- SECTION 8: VIEW
-- ==========================================================

-- Q61. Create a view containing USA customers.
CREATE OR REPLACE VIEW usCustomers AS
SELECT *
FROM customers
WHERE country = 'USA';


-- Q62. Query the USA customer view for California customers.
SELECT *
FROM usCustomers
WHERE state = 'CA';


-- ==========================================================
-- FINAL VERIFICATION QUERIES
-- ==========================================================

SELECT COUNT(*) AS CustomerCount FROM customers;
SELECT COUNT(*) AS ProductCount FROM products;
SELECT COUNT(*) AS PaymentCount FROM payments;
SELECT COUNT(*) AS OrderCount FROM orders;
SELECT COUNT(*) AS EmployeeCount FROM employees;

SHOW INDEX FROM customers;

SELECT * FROM usCustomers LIMIT 10;


/*
============================================================
SKILLS CHECKLIST
============================================================

[✓] SELECT
[✓] WHERE
[✓] ORDER BY
[✓] GROUP BY
[✓] HAVING / aggregation concepts
[✓] LIKE
[✓] IN
[✓] LIMIT
[✓] OFFSET
[✓] COUNT
[✓] SUM
[✓] AVG
[✓] MIN
[✓] MAX
[✓] Subqueries
[✓] Filtering
[✓] Sorting
[✓] JOIN
[✓] LEFT JOIN
[✓] RIGHT JOIN
[✓] CROSS JOIN
[✓] Date functions
[✓] String functions
[✓] Index
[✓] View
============================================================
*/
