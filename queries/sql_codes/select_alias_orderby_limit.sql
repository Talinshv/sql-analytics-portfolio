--SELECT
SELECT
 product_name,
 price,
 category
FROM products;

--Alias
SELECT
 product_name AS item_name,
 price AS unite_price
FROM products;

SELECT
 p.product_name,
 p.price
FROM products p;

--ORDER BY
	--ASC صعودی
	--DESC نزولی
	--ASC by default 
SELECT
product_name,
category
FROM products
ORDER BY product_name DESC, category ASC;

SELECT
product_name,
category,
price
FROM products
ORDER BY 2 DESC, 3 ASC;
-- 2= category and 3=price

--LIMIT
--LIMIT is added atthe end of codes
SELECT
product_name,
category
FROM products
ORDER BY product_name DESC, category ASC
LIMIT 10;
--means 10 row from the first

