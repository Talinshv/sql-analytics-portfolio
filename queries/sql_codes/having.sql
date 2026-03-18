--find duplication
--HAVING+COUNT()
SELECT
transaction_id,
COUNT(*) AS occurrence_count
FROM sales
Group BY transaction_id
HAVING COUNT (*) >1;
--empty answer means there is no duplicated
--The GROUP BY transaction_id Clause places all rows with the same transaction_id into a single "bucket."
--The COUNT(*) AS occurrence_count Clause count inside each of these buckets, how many rows exist.

--We use HAVING instead of WHERE because WHERE is processed before the grouping happens but 
--HAVING clause steps in after the grouping and counting are complete


--Identify products that generated more than 10.000 in total revenue
SELECT
product_id,
SUM(total_sales) AS total_revenue
FROM sales
GROUP BY product_id
HAVING SUM(total_sales) > 10000;

--HAVING + WHERE are more effective
--WHERE removes unnecessary rows then HAVING filter it
SELECT 
product_id,
SUM(total_sales) AS total_revenue
FROM sales
WHERE total_sales > 0
GROUP BY product_id
HAVING SUM(total_sales) > 10000;




SELECT
*
FROM sales;



