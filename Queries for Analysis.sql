-- find the top 10 products by revenue
select Description, SUM(Quantity) as `Total Units Sold`, ROUND(SUM(Revenue),0) as `Total Revenue($)`
FROM ecommerce_master_data_final
GROUP BY Description
ORDER BY `Total Revenue($)` DESC
LIMIT 10;

-- Monthly trend in revenue 

SELECT DATE_FORMAT(InvoiceDate, '%Y-%m') AS Month, 
       ROUND(SUM(Revenue),0) AS MonthlyRevenue
FROM ecommerce_master_data_final
GROUP BY Month
ORDER BY Month;

-- Top 10 most sold products by quantity
SELECT Description, SUM(quantity) AS `Total Units Sold`
FROM ecommerce_master_data_final
group by description
ORDER BY  `Total Units Sold` desc
LIMIT 10;

-- Average Revenue per customer
SELECT CustomerID, 
	   SUM(Quantity) AS TotalUnits,
       ROUND(SUM(Revenue),0) AS TotalRevenue
FROM ecommerce_master_data_final
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY TotalRevenue desc
limit 10;

-- Guest (null for customer ID) vs registered (has customer id) customer revenue
SELECT 
    CASE 
        WHEN CustomerID IS NULL THEN 'Guest'
        ELSE 'Registered'
    END AS CustomerGroup,
    ROUND(SUM(Revenue),0) AS TotalRevenue
FROM ecommerce_master_data_final
GROUP BY CustomerGroup;
