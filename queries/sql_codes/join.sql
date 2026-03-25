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
  o.order_id,
  SUM(oi.quantity * p.price) AS order_revenue
FROM analytics.orders o
JOIN analytics.order_items oi
  ON o.order_id = oi.order_id
JOIN analytics.products p
  ON oi.product_id = p.product_id
GROUP BY o.order_id;

--Hierarchical JOIN | Customer Geography
--Where is each customer located?
SELECT
	co.customer_id,
	c.city_name,
	r.region_name,
	ca.country_name
FROM analytics.customers co
JOIN analytics.cities c ON co.city_id = c.city_id
JOIN analytics.regions r ON c.region_id = r.region_id
JOIN analytics.countries ca ON r.country_id = ca.country_id;

--Spatial JOIN | Geometry Meets Business Data
--Is a customer physically inside their declared city?
SELECT
  c.customer_id,
  ci.city_name,
  ST_Within(cl.geom, cb.geom) AS inside_city
FROM analytics.customers c
JOIN analytics.customer_locations cl
  ON c.customer_id = cl.customer_id
JOIN analytics.cities ci
  ON c.city_id = ci.city_id
JOIN analytics.city_boundaries cb
  ON ci.city_id = cb.city_id;
--ST_Within(cl.geom, cb.geom) AS inside_city :is related to spatial analysis in the PostGIS plugin.
--This line asks a logical question of the database: "Is this point exactly inside this boundary?"
--ST_Within :It takes two inputs and its output is a Boolean value (true/false).
--First input (cl.geom): The geometry of the customer's location (which is usually a point on the map).
--Second input (cb.geom): The geometry of the city boundary (which is a polygon).

--Many-to-Many Effect | Why Row Counts Explode
SELECT COUNT(*) AS joined_rows
FROM analytics.orders o
JOIN analytics.order_items oi
  ON o.order_id = oi.order_id;
--COUNT(*) counts all rows created after the JOIN operation.
--The orders table usually contains general information (such as date and customer ID)
--and the order_items table contains details about each item in that order.
--We connect the two using order_id, and the database creates a row for each item in each order.