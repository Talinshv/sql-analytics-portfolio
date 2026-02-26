-- TOP 3 MONTHS BY REVENUE
SELECT 
    month, 
    SUM(total_sales) AS monthly_revenue
FROM sales_analysis
GROUP BY month
ORDER BY monthly_revenue DESC
LIMIT 3; 

-- TOP QUARTER BY REVENUE
SELECT 
    quarter, 
    SUM(total_sales) AS quarterly_revenue
FROM sales_analysis
GROUP BY quarter
ORDER BY quarterly_revenue DESC
LIMIT 1; 

-- TRANSACTIONS FROM LAST 60 DAYS
SELECT 
    transaction_id,
    order_date_date,
    (CURRENT_DATE - order_date_date) AS days_since_transaction,
    total_sales
FROM sales_analysis
WHERE (CURRENT_DATE - order_date_date) <= 60;