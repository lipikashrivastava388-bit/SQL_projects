-- ============================================================
-- MINI PROJECT 05: ADVANCED SQL - WINDOW FUNCTIONS
-- Reference: User-provided SQL file
-- SQL dialect: MySQL 8.0+
--
-- Topics: ROW_NUMBER, RANK, DENSE_RANK, PARTITION BY, running
-- totals, CTEs, LAG, month-over-month change, moving averages.
--
-- NOTE:
-- The supplied reference starts with a baby_names example and
-- then uses the ClassicModels database. This script keeps both
-- exercises, but fixes the setup so it does not accidentally
-- attempt to drop a database named baby_names.
-- ============================================================


-- ============================================================
-- PART A: BABY NAME POPULARITY EXAMPLE
-- ============================================================

-- Create/use a dedicated database for the sample baby-name table.
CREATE DATABASE IF NOT EXISTS baby_names_project;
USE baby_names_project;

DROP TABLE IF EXISTS baby_names;

CREATE TABLE baby_names (
    Gender VARCHAR(10),
    Name VARCHAR(50),
    Total INT
);

INSERT INTO baby_names (Gender, Name, Total) VALUES
('Girl', 'Ava', 95),
('Girl', 'Emma', 106),
('Boy', 'Ethan', 115),
('Girl', 'Isabella', 100),
('Boy', 'Jacob', 101),
('Boy', 'Liam', 84),
('Boy', 'Logan', 73),
('Boy', 'Noah', 120),
('Girl', 'Olivia', 100),
('Girl', 'Sophia', 88);

-- A1. View all records
SELECT *
FROM baby_names;

-- A2. Sort names by total popularity, highest first
SELECT *
FROM baby_names
ORDER BY Total DESC;

-- A3. Assign a unique row number by total popularity
SELECT
    Gender,
    Name,
    Total,
    ROW_NUMBER() OVER (ORDER BY Total DESC) AS Popularity
FROM baby_names;

-- A4. Compare ROW_NUMBER, RANK, and DENSE_RANK
SELECT
    Gender,
    Name,
    Total,
    ROW_NUMBER() OVER (ORDER BY Total DESC) AS Popularity_Row_Number,
    RANK() OVER (ORDER BY Total DESC) AS Popularity_Rank,
    DENSE_RANK() OVER (ORDER BY Total DESC) AS Popularity_Dense_Rank
FROM baby_names
ORDER BY Total DESC;

-- A5. Rank names within each gender
SELECT
    Gender,
    Name,
    Total,
    ROW_NUMBER() OVER (
        PARTITION BY Gender
        ORDER BY Total DESC, Name ASC
    ) AS Popularity_Within_Gender
FROM baby_names
ORDER BY Gender, Popularity_Within_Gender;

-- A6. Top 3 names for each gender
WITH RankedNames AS (
    SELECT
        Gender,
        Name,
        Total,
        ROW_NUMBER() OVER (
            PARTITION BY Gender
            ORDER BY Total DESC, Name ASC
        ) AS Popularity
    FROM baby_names
)
SELECT Gender, Name, Total, Popularity
FROM RankedNames
WHERE Popularity <= 3
ORDER BY Gender, Popularity;


-- ============================================================
-- PART B: CLASSICMODELS WINDOW-FUNCTION PROJECT
-- ============================================================

USE classicmodels;

-- B1. Rank products by MSRP within each product line.
-- DENSE_RANK gives equal ranks to products with the same MSRP.
SELECT
    productLine,
    productName,
    MSRP,
    DENSE_RANK() OVER (
        PARTITION BY productLine
        ORDER BY MSRP DESC
    ) AS price_rank
FROM products
ORDER BY productLine, price_rank, productName;


-- B2. Running total of payments per customer.
-- Rows are ordered by payment date. checkNumber is included as a
-- tie-breaker so payments on the same date have a stable order.
SELECT
    customerNumber,
    paymentDate,
    checkNumber,
    amount,
    SUM(amount) OVER (
        PARTITION BY customerNumber
        ORDER BY paymentDate, checkNumber
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_payment_total
FROM payments
ORDER BY customerNumber, paymentDate, checkNumber;


-- B3. Top 3 most expensive products by MSRP in each product line.
-- ROW_NUMBER returns at most three products per product line.
WITH RankedProducts AS (
    SELECT
        productLine,
        productName,
        MSRP,
        ROW_NUMBER() OVER (
            PARTITION BY productLine
            ORDER BY MSRP DESC, productName ASC
        ) AS row_num
    FROM products
)
SELECT productLine, productName, MSRP, row_num
FROM RankedProducts
WHERE row_num <= 3
ORDER BY productLine, row_num;


-- B4. Month-over-month sales comparison using payments as the
-- revenue measure, matching the supplied reference file.
WITH MonthlySales AS (
    SELECT
        DATE_FORMAT(paymentDate, '%Y-%m') AS sales_month,
        SUM(amount) AS total_sales
    FROM payments
    GROUP BY DATE_FORMAT(paymentDate, '%Y-%m')
),
SalesWithPreviousMonth AS (
    SELECT
        sales_month,
        total_sales,
        LAG(total_sales, 1) OVER (ORDER BY sales_month) AS previous_month_sales
    FROM MonthlySales
)
SELECT
    sales_month,
    total_sales,
    previous_month_sales,
    ROUND(total_sales - previous_month_sales, 2) AS monthly_growth,
    CASE
        WHEN previous_month_sales IS NULL THEN 'No previous month in result'
        WHEN total_sales > previous_month_sales THEN 'Growth'
        WHEN total_sales < previous_month_sales THEN 'Decline'
        ELSE 'No change'
    END AS sales_trend
FROM SalesWithPreviousMonth
ORDER BY sales_month;


-- B5. Three-month moving average of monthly payment revenue.
-- Uses the current month and up to the two preceding rows in the
-- monthly result. If a calendar month has no payments, it will not
-- appear as a row; therefore this is a 3-observed-month average,
-- not necessarily a complete calendar-month average.
WITH MonthlySales AS (
    SELECT
        DATE_FORMAT(paymentDate, '%Y-%m') AS sales_month,
        SUM(amount) AS total_sales
    FROM payments
    GROUP BY DATE_FORMAT(paymentDate, '%Y-%m')
)
SELECT
    sales_month,
    total_sales,
    ROUND(
        AVG(total_sales) OVER (
            ORDER BY sales_month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS moving_average_3_month
FROM MonthlySales
ORDER BY sales_month;


-- B6. Optional: compare each month's sales with the previous
-- month as a percentage change.
WITH MonthlySales AS (
    SELECT
        DATE_FORMAT(paymentDate, '%Y-%m') AS sales_month,
        SUM(amount) AS total_sales
    FROM payments
    GROUP BY DATE_FORMAT(paymentDate, '%Y-%m')
),
SalesWithPreviousMonth AS (
    SELECT
        sales_month,
        total_sales,
        LAG(total_sales) OVER (ORDER BY sales_month) AS previous_month_sales
    FROM MonthlySales
)
SELECT
    sales_month,
    total_sales,
    previous_month_sales,
    CASE
        WHEN previous_month_sales IS NULL OR previous_month_sales = 0 THEN NULL
        ELSE ROUND(
            ((total_sales - previous_month_sales) / previous_month_sales) * 100,
            2
        )
    END AS percentage_change
FROM SalesWithPreviousMonth
ORDER BY sales_month;
