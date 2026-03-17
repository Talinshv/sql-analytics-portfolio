--GROUP BY
--control how rows are aggregated
--GROUP BY+ 
		--COUNT()   count number of rows
		--MAX()     find max value in calumn
		--MIN()     find min value in calumn
		--SUM()     adds all numeric value in a calumn
		--AVG()     avrage of numeric value in a calumn

--Total revenue per product
SELECT
product_id,
SUM(total_sales) AS total_revenue
FROM sales
GROUP BY product_id
--the column after SELECt (product_id)should be the same column in GROUP BY (product_id)

--Number of products by category
SELECT
category,
COUNT(*)
FROM products
GROUP bY category;

--Number of sales transaction per product
SELECT
product_id,
COUNT(transaction_id) AS numerical_transaction
FROM sales
GROUP BY product_id;

--Number of sales transaction for per employee
SELECT
employee_id,
COUNT(transaction_id) AS transaction_count
FROM sales
GROUP BY employee_id
ORDER By transaction_count DESC;

--Avrage price by category
SELECT
category,
AVG(price) AS avg_price
FROM products
GROUP BY category;