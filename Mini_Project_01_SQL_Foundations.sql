/*
============================================================
MINI PROJECT 01
SQL FOUNDATIONS & DATABASE OPERATIONS
============================================================

Skills covered:
1. Database creation
2. Table creation
3. INSERT
4. DDL
5. ALTER TABLE
6. ADD / DROP columns
7. Rename columns and tables
8. MODIFY column structure
9. UPDATE
10. DELETE
11. CASE statements / conditional categories

============================================================
*/

-- ==========================================================
-- PART 1: DATABASE CREATION
-- ==========================================================

SHOW DATABASES;

DROP DATABASE IF EXISTS Bleep;
CREATE DATABASE Bleep;

USE Bleep;


-- ==========================================================
-- PART 2: CREATE STUDENTS TABLE
-- ==========================================================

CREATE TABLE students (
    Id INT NOT NULL,
    FirstName VARCHAR(15) NOT NULL,
    LastName VARCHAR(15),
    Course VARCHAR(20) NOT NULL,
    Address VARCHAR(15) NOT NULL
);

-- Check table structure
DESCRIBE students;


-- ==========================================================
-- PART 3: INSERT STUDENT RECORDS
-- ==========================================================

INSERT INTO students (Id, FirstName, LastName, Course, Address)
VALUES
(1, 'Ram', 'Kumar', 'DA', 'Hosur'),
(2, 'Shyam', 'Kumar', 'DS', 'Chennai'),
(3, 'Ghanshyam', 'Kumar', 'AI', 'Madurai'),
(4, 'Hari', 'Kumar', 'DS', 'Bengaluru'),
(5, 'Tilak', 'Kumar', 'DA', 'Salem');

SELECT * FROM students;


-- ==========================================================
-- PART 4: ALTER TABLE - ADD COLUMN
-- ==========================================================

ALTER TABLE students
ADD Email VARCHAR(25);

SELECT * FROM students;


-- ==========================================================
-- PART 5: ALTER TABLE - DROP COLUMN
-- ==========================================================

ALTER TABLE students
DROP COLUMN LastName;

SELECT * FROM students;


-- ==========================================================
-- PART 6: RENAME COLUMN
-- Address -> City
-- ==========================================================

ALTER TABLE students
RENAME COLUMN Address TO City;

SELECT * FROM students;


-- ==========================================================
-- PART 7: RENAME TABLE
-- students -> student
-- ==========================================================

ALTER TABLE students
RENAME TO student;

SELECT * FROM student;


-- ==========================================================
-- PART 8: ADD CONTACT COLUMN
-- ==========================================================

ALTER TABLE student
ADD Contact INT;

SELECT * FROM student;


-- ==========================================================
-- PART 9: MODIFY COLUMN
-- Contact INT -> VARCHAR(15)
-- A phone number should be stored as text because it may
-- contain +, -, spaces, or leading zeroes.
-- ==========================================================

ALTER TABLE student
MODIFY COLUMN Contact VARCHAR(15);

DESCRIBE student;


-- ==========================================================
-- PART 10: UPDATE RECORDS
-- ==========================================================

-- Update all email addresses
UPDATE student
SET Email = CASE
    WHEN Id = 1 THEN 'ram@gmail.com'
    WHEN Id = 2 THEN 'shyam@gmail.com'
    WHEN Id = 3 THEN 'ghanshyam@gmail.com'
    WHEN Id = 4 THEN 'hari@gmail.com'
    WHEN Id = 5 THEN 'tilak@gmail.com'
END;

-- Update one specific record
UPDATE student
SET Email = 'shyam@gmail.com'
WHERE Id = 2;

-- Update multiple columns for one record
UPDATE student
SET Email = 'ghanshyam@gmail.com',
    City = 'Mumbai',
    Contact = '+912345677654'
WHERE Id = 3;

SELECT * FROM student;


-- ==========================================================
-- PART 11: DELETE RECORD
-- ==========================================================

DELETE FROM student
WHERE Id = 5;

SELECT * FROM student;


-- ==========================================================
-- PART 12: CASE STATEMENT / CONDITIONAL LOGIC
-- ==========================================================

/*
Create a category based on the student's course.

DA -> Data Analytics
DS -> Data Science
AI -> Artificial Intelligence
Other -> Other Course
*/

SELECT
    Id,
    FirstName,
    Course,
    City,
    CASE
        WHEN Course = 'DA' THEN 'Data Analytics'
        WHEN Course = 'DS' THEN 'Data Science'
        WHEN Course = 'AI' THEN 'Artificial Intelligence'
        ELSE 'Other Course'
    END AS Course_Category
FROM student
ORDER BY Id;


-- Another CASE example using student ID
SELECT
    Id,
    FirstName,
    Course,
    CASE
        WHEN Id <= 2 THEN 'Group A'
        WHEN Id <= 4 THEN 'Group B'
        ELSE 'Group C'
    END AS Student_Group
FROM student
ORDER BY Id;


-- ==========================================================
-- PART 13: EMPLOYEES TABLE
-- ==========================================================

CREATE TABLE employees (
    Empid INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(15) NOT NULL,
    LastName VARCHAR(15),
    Department CHAR(15) NOT NULL,
    Email VARCHAR(25) NOT NULL,
    DOB DATE NOT NULL,
    CONTACT CHAR(20) NOT NULL,
    Salary FLOAT NOT NULL
);

DESCRIBE employees;


-- ==========================================================
-- PART 14: INSERT EMPLOYEE RECORDS
-- ==========================================================

INSERT INTO employees
(FirstName, LastName, Department, Email, DOB, Contact, Salary)
VALUES
('Harry', 'Potter', 'IT', 'harryp@gmail.com', '2001-11-10', '+44-234567898', 560000),
('Shinchan', 'Nohara', 'HR', 'sn@gmail.com', '2010-10-15', '+32-2345654322', 520000),
('Shaik', 'Siraj', 'Ops', 'ss@gmail.com', '2006-12-18', '+91-234736898', 660000),
('Bhavya', 'Kusum', 'IT', 'bk@gmail.com', '2007-11-23', '+91-239007898', 750000),
('Sandeep', 'Reddy', 'Marketing', 'sr@gmail.com', '2006-12-25', '+1-987667898', 860000);

SELECT * FROM employees;


-- ==========================================================
-- PART 15: CASE ON EMPLOYEE SALARY
-- ==========================================================

SELECT
    Empid,
    FirstName,
    LastName,
    Department,
    Salary,
    CASE
        WHEN Salary >= 800000 THEN 'High Salary'
        WHEN Salary >= 600000 THEN 'Medium Salary'
        ELSE 'Entry Level Salary'
    END AS Salary_Category
FROM employees
ORDER BY Salary DESC;


-- ==========================================================
-- PART 16: CASE ON EMPLOYEE DEPARTMENT
-- ==========================================================

SELECT
    Empid,
    FirstName,
    Department,
    CASE
        WHEN Department = 'IT' THEN 'Technology'
        WHEN Department = 'HR' THEN 'Human Resources'
        WHEN Department = 'Ops' THEN 'Operations'
        WHEN Department = 'Marketing' THEN 'Marketing'
        ELSE 'Other'
    END AS Department_Category
FROM employees
ORDER BY Empid;


-- ==========================================================
-- PART 17: FINAL VERIFICATION
-- ==========================================================

SELECT 'Students Table' AS Table_Checked;
SELECT * FROM student;

SELECT 'Employees Table' AS Table_Checked;
SELECT * FROM employees;

-- Verify database tables
SHOW TABLES;


/*
============================================================
PROJECT CHECKLIST
============================================================

[✓] Database created
[✓] Tables created
[✓] Records inserted
[✓] ALTER TABLE used
[✓] Column added
[✓] Column dropped
[✓] Column renamed
[✓] Table renamed
[✓] Column modified
[✓] Records updated
[✓] Record deleted
[✓] CASE statements used
[✓] Conditional categories created
[✓] Final outputs verified

============================================================
*/
