SELECT * FROM public.customers LIMIT 10;

SELECT * FROM public.employees LIMIT 10;

SELECT * FROM public.orders LIMIT 10;

SELECT * FROM public.products LIMIT 10;

SELECT * FROM public.sales LIMIT 10;

ALTER TABLE employees
ADD CONSTRAINT uq_employees_email UNIQUE (email);

SELECT
	email,
	count(email)
FROM employees
GROUP BY email
HAVING count(email) >1;



ALTER TABLE employees
ALTER COLUMN phone_number SET NOT NULL;

SELECT 
	employee_id,
	first_name,
	last_name,
	phone_number
FROM employees
WHERE phone_number IS NOT NULL;


ALTER TABLE products
ADD CONSTRAINT chk_products_price CHECK (price > 0);

SELECT product_id, price
FROM products
WHERE price < 0;

ALTER TABLE sales
ADD CONSTRAINT chk_sales_total CHECK (total_sales >= 0);

SELECT total_sales
FROM sales
WHERE total_sales < 0;

ALTER TABLE sales
ADD COLUMN sales_channel TEXT;

ALTER TABLE sales
ADD CONSTRAINT chk_sales_channel
CHECK (sales_channel IN ('online', 'store'));

UPDATE sales
SET sales_channel = 'online'
WHERE transaction_id % 2 = 0;

CREATE INDEX idx_sales_product_id
ON sales (product_id);

CREATE INDEX idx_sales_customer_id
ON sales (customer_id);

CREATE INDEX idx_products_category
ON products (category);

EXPLAIN
SELECT
  product_id,
  SUM(total_sales) AS total_revenue
FROM sales
GROUP BY product_id;

EXPLAIN SELECT * FROM sales WHERE product_id = 101;

SELECT *
FROM sales;

SELECT
  transaction_id,
  product_id,
  total_sales
FROM sales;

EXPLAIN
SELECT
  product_id,
  SUM(total_sales) AS total_revenue
FROM sales
GROUP BY product_id
ORDER BY total_revenue DESC
LIMIT 5;


SELECT DISTINCT
  category,
  price
FROM products;

EXPLAIN
SELECT
  category,
  price
FROM products
GROUP BY category, price;

UPDATE products
SET price = -5
WHERE product_id = 101;

INSERT INTO customers (customer_id, email, phone_number)
VALUES (999, 'anna@example.com', '091000999');
