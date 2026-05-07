-- ========================
-- ABOUT BRANDS
-- ========================
 
-- Query 1: Which brands have the most listings?
SELECT
    b.brand_name,
    COUNT(*) AS total_listings
FROM analytics.fact_perfume_listing f
JOIN analytics.brand b ON b.brand_id = f.brand_id
GROUP BY b.brand_name
ORDER BY total_listings DESC
LIMIT 5;
 
 
-- Query 2: Which brand has the highest average price?
SELECT
    b.brand_name,
    ROUND(AVG(f.price), 2) AS avg_price,
    COUNT(*)               AS total_listings
FROM analytics.fact_perfume_listing f
JOIN analytics.brand b ON b.brand_id = f.brand_id
GROUP BY b.brand_name
HAVING COUNT(*) > 1
ORDER BY avg_price DESC
LIMIT 5;
 
 
-- Query 3: Which brand has sold the most units in total?
SELECT
    b.brand_name,
    SUM(f.sold)            AS total_units_sold,
    ROUND(AVG(f.price), 2) AS avg_price
FROM analytics.fact_perfume_listing f
JOIN analytics.brand b ON b.brand_id = f.brand_id
WHERE f.sold IS NOT NULL
GROUP BY b.brand_name
ORDER BY total_units_sold DESC
LIMIT 10;
 
 
-- ========================
-- ABOUT SALES
-- ========================
 
-- Query 4: What are the top 10 best selling perfumes by units sold?
SELECT
    b.brand_name,
    f.title,
    f.sold AS units_sold,
    f.price
FROM analytics.fact_perfume_listing f
JOIN analytics.brand b ON b.brand_id = f.brand_id
WHERE f.sold IS NOT NULL
ORDER BY f.sold DESC
LIMIT 10;
 
 
-- Query 5: Do low stock items sell more?
SELECT
    CASE
        WHEN f.available = 0   THEN '0 - Out of stock'
        WHEN f.available <= 5  THEN '1-5 - Very low'
        WHEN f.available <= 20 THEN '6-20 - Low'
        WHEN f.available <= 50 THEN '21-50 - Medium'
        ELSE                        '51+ - High'
    END                        AS stock_level,
    COUNT(*)                   AS total_listings,
    ROUND(AVG(f.sold), 1)      AS avg_units_sold
FROM analytics.fact_perfume_listing f
WHERE f.sold IS NOT NULL
AND f.available IS NOT NULL
GROUP BY stock_level
ORDER BY avg_units_sold DESC;
 
 
-- ========================
-- ABOUT PRICE
-- ========================
 
-- Query 6: What is the average price per fragrance type?
SELECT
    t.type_name,
    ROUND(AVG(f.price), 2) AS avg_price,
    COUNT(*)               AS total_listings
FROM analytics.fact_perfume_listing f
JOIN analytics.fragrance_type t ON t.type_id = f.type_id
GROUP BY t.type_name
ORDER BY avg_price DESC;
 
 
-- Query 7: What is the price range across the entire dataset?
SELECT
    ROUND(MIN(f.price), 2)                                                    AS cheapest,
    ROUND(MAX(f.price), 2)                                                    AS most_expensive,
    ROUND(AVG(f.price), 2)                                                    AS average_price,
    ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY f.price) AS NUMERIC), 2) AS median_price
FROM analytics.fact_perfume_listing f;
 
 
-- ========================
-- ABOUT LOCATION
-- ========================
 

 
 
-- ========================
-- ABOUT FRAGRANCE TYPE
-- ========================
 
-- Query 10: Which fragrance type is the most common?
SELECT
    t.type_name,
    COUNT(*) AS total_listings
FROM analytics.fact_perfume_listing f
JOIN analytics.fragrance_type t ON t.type_id = f.type_id
GROUP BY t.type_name
ORDER BY total_listings DESC
LIMIT 10;
 
 
-- Query 11: Which fragrance type has the highest average units sold?
SELECT
    t.type_name,
    ROUND(AVG(f.sold), 1) AS avg_units_sold,
    COUNT(*)              AS total_listings
FROM analytics.fact_perfume_listing f
JOIN analytics.fragrance_type t ON t.type_id = f.type_id
WHERE f.sold IS NOT NULL
GROUP BY t.type_name
ORDER BY avg_units_sold DESC
LIMIT 10;
 
 
-- ========================
-- ABOUT GENDER
-- ========================
 

 
 
-- Query 13: Which gender has a higher average price?
SELECT
    g.gender_name,
    ROUND(AVG(f.price), 2) AS avg_price
FROM analytics.fact_perfume_listing f
JOIN analytics.gender g ON g.gender_id = f.gender_id
GROUP BY g.gender_name
ORDER BY avg_price DESC;
 
 
-- Query 14: Which gender sells more units on average?
SELECT
    g.gender_name,
    ROUND(AVG(f.sold), 1) AS avg_units_sold,
    SUM(f.sold)           AS total_units_sold
FROM analytics.fact_perfume_listing f
JOIN analytics.gender g ON g.gender_id = f.gender_id
WHERE f.sold IS NOT NULL
GROUP BY g.gender_name
ORDER BY avg_units_sold DESC;
 
 
-- Query 15: Top 5 brands per gender by number of listings?
WITH gender_brand_ranked AS (
    SELECT
        g.gender_name,
        b.brand_name,
        COUNT(*)               AS total_listings,
        ROUND(AVG(f.price), 2) AS avg_price,
        ROW_NUMBER() OVER (
            PARTITION BY g.gender_name
            ORDER BY COUNT(*) DESC
        ) AS rank
    FROM analytics.fact_perfume_listing f
    JOIN analytics.gender g ON g.gender_id = f.gender_id
    JOIN analytics.brand  b ON b.brand_id  = f.brand_id
    GROUP BY g.gender_name, b.brand_name
)
SELECT
    gender_name,
    brand_name,
    total_listings,
    avg_price
FROM gender_brand_ranked
WHERE rank <= 5
ORDER BY gender_name, total_listings DESC;