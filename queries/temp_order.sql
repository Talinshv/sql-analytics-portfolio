CREATE TEMP TABLE tmp_order AS
SELECT 
	o.order_id,
 	oi.quantity,
 	p.product_name,
 	p.category,
 	p.price
FROM analytics.orders o
LEFt JOIN analytics.order_items oi ON (o.order_id = oi.order_id)
LEFt JOIN products p ON (oi.product_id = p.product_id);

