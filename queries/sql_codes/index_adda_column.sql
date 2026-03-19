--INDEX
--Tell to database to build a separate, hidden,search struction
--for searching the columns which we use more

--INDEX on product_id
CREATE INDEX idx_sales_product_id
ON sales(product_id);
-- in first row
	--sales = table which we work on it
	--product_id = index name

--INDEX on customer_id
CREATE INDEX idx_sales_customer_id
ON sales(customer_id);

--INDEX on category
CREATE INDEX idx_sales_category
ON sales(category);

--ALTER TABLE = Add new column
	--name: sales channel
	--rule: online/store
ALTER TABLE sales
ADD COLUMN sales_channel TEXT;
-- Till here you have empty column with NULL

--adding a new rule by ADD CONSTRAINT
--""chk_sales_channel"" is rule name
-- last line is the main order: in sales_channel only should be 'online'or'store'
ALTER TABLE sales
ADD CONSTRAINT chk_sales_channel
CHECK(sales_channel IN ('online','store'));

--
UPDATE sales
SET sales_channel='online'
WHERE transaction_id %2=0;
--last row: transaction_id/2=0 mins if transaction id is even (زوج)
WHERE transaction_id %2<>0;