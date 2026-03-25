--Table JOINs
--INNER JOIN | Only Matching Rows
--Which customers have placed orders?
SELECT
	c.customer_id,
    c.first_name,
    o.order_id,
    o.order_date
FROM analytics.customers c
INNER JOIN analytics.orders o ON o.customer_id = c.customer_id;


--LEFT JOIN | Preserve the Base Table
--Show all customers, even if they never ordered.
SELECT
	c.customer_id,
	c.first_name,
	o.order_id
FROM analytics.customers c
LEFT JOIN analytics.orders o ON o.customer_id = c.customer_id;


--LEFT JOIN + NULL FILTER | Anti-Join Pattern
--Which customers have never ordered?
SELECT
	c.customer_id,
	c.first_name
FROM analytics.customers c
LEFT JOIN analytics.orders o ON o.customer_id = c.customer_id
WHERE order_id IS NULL;


--One-to-Many JOIN | Orders to Order Items
--What products were sold in each order?
SELECT
  o.order_id,
  p.product_name,
  oi.quantity
FROM analytics.orders o
JOIN analytics.order_items oi
  ON o.order_id = oi.order_id
JOIN analytics.products p
  ON oi.product_id = p.product_id;

--Aggregation After JOIN | Controlling Row Explosion
--Total revenue per order?
SELECT





	