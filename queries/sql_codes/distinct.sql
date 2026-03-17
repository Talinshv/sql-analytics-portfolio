--DIstinct (UNIQUE)
	--If there is more than one item of the same information unit in each column, 
	--from each product or from each name, it only considers one.
	
--Important points:
	   --need only unique value
	   --no aggrigation
	   --simple, more needable
	   --choose NULE 

SELECT DISTINCT
category
FROM products;


--Find unique combination of product category and price
SELECT DISTINCT 
category,
price
From products;

--Count() of a column VS Count Distinct of the same column
SELECT DISTINCT 
COUNT(category),
COUNT(DISTINCT category)
From products;

--COUNT(category) = COUNT(*)

