-- Customer table

SELECT customerid,
	companyname,
	contactname,
	city,
	country
FROM customers


update orders 
set orderdate = orderdate + interval '1 year' * 1;

-- Orders table

SELECT o1.orderid,
	o1.customerid,
	o1.employeeid,
	CONCAT(o3.firstname, ' ', o3.lastname) AS employee, -- joined Salesperson name from Employees table
	o1.orderdate,
	EXTRACT(year FROM o1.orderdate) AS orderyear,
	o1.duedate,
	o1.shippeddate,
	ROUND(o2.unitprice::numeric*o2.quantity, 2) AS saleamount,
	o2.productid, -- joined Product ID from Order Details table
	o2.unitprice, -- joined Unit Price from Order Details table
	o2.quantity, -- joined Quantity from Order Details table
	(100*(o2.discount))::INTEGER AS percentdiscount
FROM orders AS o1

JOIN order_details AS o2
	ON o1.orderid = o2.orderid

JOIN employees AS o3
	ON o1.employeeid = o3.employeeid
	
	
-- Products table

SELECT p1.productid, 
	p1.productname, 
	p1.categoryid, 
	p2.categoryname, -- Joined Category from Categories table
	CASE 
		WHEN p1.discontinued = '1' THEN 'Discontinued'
		WHEN p1.discontinued = '0' THEN 'Active'
	END AS productstatus,
	p2.description  -- Joined Description from Categories table
FROM products AS p1

JOIN categories AS p2
	ON p1.categoryid = p2. categoryid


-- Frequently Boguht Together:
-- Create view with product names

CREATE VIEW products_bought AS
SELECT orderid, p2.productname
FROM order_details AS p1
	
	JOIN products AS p2
	ON p1.productid = p2.productid
	
	
-- Finding items frequently bought together by PRODUCT NAME

SELECT p1.productname, p2.productname AS bought_with, count(*) AS FBT
FROM products_bought AS p1

INNER JOIN products_bought AS p2
	ON p1.orderid = p2.orderid
	AND p1.productname != p2.productname

GROUP BY p1.productname, p2.productname
ORDER BY FBT DESC


-- Finding items frequently bought together by PRODUCT ID

SELECT o1.productid AS productid, o2.productid AS bought_with, count(*) AS frequency_bought_together
FROM order_details AS o1

JOIN products AS p1
	ON p1.productid = o1.productid

INNER JOIN order_details AS o2
	ON o1.orderid = o2.orderid
	AND o1.productid != o2.productid

GROUP BY o1.productid, o2.productid
ORDER BY frequency_bought_together DESC


-- Verify both queries product the same result
SELECT *
FROM products
WHERE productid = 61 OR productid = 21
