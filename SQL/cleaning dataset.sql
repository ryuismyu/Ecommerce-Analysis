-- First step is to create the database and the full master data table to get ready for csv import--
CREATE DATABASE ecommerce;
CREATE TABLE ecommerce_master_data (
InvoiceNo varchar(100),
StockCode varchar(100),
Description varchar(100),
Quantity varchar(100),
InvoiceDate varchar(100),
UnitPrice varchar(100),
CustomerID varchar(100),
Country varchar(100)
);
USE ecommerce;
-- query for importing the full csv file
CREATE TABLE ecommerce_master_data
SELECT *
FROM parks_and_recreation.ecommerce_master_data;
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\e_commerce_dataset.csv'
INTO TABLE ecommerce_master_data
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
-- To check if the import was successful
SELECT * FROM ecommerce_master_data;

-- converting the column from text to a date so it is recognized by datetime data type in sql

UPDATE ecommerce_master_data
SET InvoiceDate = STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i');
-- adjusting the datatypes for the table--
-- converting all blanks to NULL

UPDATE ecommerce_master_data
SET CustomerID = NULL
WHERE CustomerID = '';
ALTER TABLE ecommerce_master_data
                      MODIFY UnitPrice FLOAT,
                      MODIFY InvoiceDate DATETIME,
                      MODIFY CustomerID INT CHECK (CustomerID BETWEEN 10000 AND 99999);
			
-- Handling missing and invalid values in the table--  

-- removing blank invoices                    
DELETE FROM ecommerce_master_data
WHERE InvoiceNo = '';

-- remove invalid quantities
DELETE FROM ecommerce_master_data
WHERE quantity <=0;

-- removing invalid prices
DELETE FROM ecommerce_master_data
WHERE UnitPrice <=0;
--  removing invoices with no dates 
DELETE FROM ecommerce_master_data
WHERE InvoiceDate IS NULL;
-- removing leading and trailing spaces
UPDATE ecommerce_master_data
SET Descritpion = TRIM(Descritpion),
	Country = TRIM(country);
    
-- Deleting rows with no description
SELECT * FROM ecommerce_master_data WHERE description ='';
select * from ecommerce_master_data;

-- Approximately 11000 rows were deleted after cleaning, 530104 rows remain.

-- Adding primary key, has to be composite key as one invoice can have several products in it.
ALTER TABLE ecommerce_master_data
ADD PRIMARY KEY (InvoiceNo,StockCode);

-- Identifying duplicates as primary key couldnt be created, over 9000 identifed.

SELECT InvoiceNo, StockCode, COUNT(*) as cnt
FROM ecommerce_master_data
GROUP BY InvoiceNo, StockCode
HAVING cnt>1;

-- creating a new table to sum the quantities, average the price for the duplicate invoices
CREATE TABLE ecommerce_master_data_clean AS
SELECT InvoiceNo,
       StockCode,
       Description,
       SUM(Quantity) AS Quantity,
       AVG(UnitPrice) AS UnitPrice,
       MIN(InvoiceDate) AS InvoiceDate,
       CustomerID,
       Country,
       SUM(Quantity * UnitPrice) AS TotalPrice
FROM ecommerce_master_data
GROUP BY InvoiceNo, StockCode, Description, CustomerID, Country;

-- check again now if there are any duplicates--

SELECT InvoiceNo, StockCode, COUNT(*) as cnt
FROM ecommerce_master_data_clean
GROUP BY InvoiceNo, StockCode
HAVING cnt>1;
-- readding the primary key
ALTER TABLE ecommerce_master_data
ADD PRIMARY KEY (InvoiceNo,StockCode);

-- needed to create a table again as some of the invoice numbers were being treated as strings

CREATE TABLE ecommerce_master_data_finals AS
SELECT 
    InvoiceNo,
    UPPER(TRIM(StockCode)) AS StockCode,     
    MIN(TRIM(Description)) AS Description,
    SUM(Quantity) AS Quantity,
    ROUND(AVG(UnitPrice), 2) AS UnitPrice,
    MIN(InvoiceDate) AS InvoiceDate,
    MIN(CustomerID) AS CustomerID,
    MIN(Country) AS Country,
    SUM(Quantity * UnitPrice) AS TotalPrice
FROM ecommerce_master_data_clean
GROUP BY InvoiceNo, UPPER(TRIM(StockCode));

ALTER TABLE ecommerce_master_data_finals
ADD PRIMARY KEY (InvoiceNo,StockCode);

ALTER TABLE ecommerce_master_data_finals RENAME TO ecommerce_master_data_final;

alter table ecommerce_master_data_final CHANGE TotalPrice Revenue double; 




