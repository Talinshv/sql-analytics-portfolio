-- Analytical Queries
-- QUERY 1
-- What are the top 5 brands by number of listings?

-- COUNT(*) counts how many listings each brand has
-- GROUP BY groups the rows by brand before counting
-- ORDER BY sorts from highest to lowest
SELECT
    b.brand_name,
    COUNT(*) AS total_listings
FROM analytics.fact_perfume_listing f
JOIN analytics.brand b ON b.brand_id = f.brand_id
GROUP BY b.brand_name
ORDER BY total_listings DESC
LIMIT 5;


-- QUERY 2
-- What are the top 5 brands by total units sold?

-- SUM(f.sold) adds up all sold units per brand
-- WHERE f.sold IS NOT NULL skips rows with missing sold data
SELECT
    b.brand_name,
    SUM(f.sold) AS total_units_sold
FROM analytics.fact_perfume_listing f
JOIN analytics.brand b ON b.brand_id = f.brand_id
WHERE f.sold IS NOT NULL
GROUP BY b.brand_name
ORDER BY total_units_sold DESC
LIMIT 5;


-- QUERY 3
-- Which brands have the highest average price?

-- AVG(f.price) calculates the average price per brand
-- ROUND(..., 2) keeps only 2 decimal places (e.g. 84.99)
-- HAVING COUNT(*) > 1 removes brands with only 1 listing
-- (a single expensive item would unfairly top the list)
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

-- QUERY 4
-- Within the top 5 brands by listings,
-- what are the top 3 best selling titles per brand?

-- WITH top_brands: first finds the top 5 brands by listing count
-- WITH title_rankings: inside those brands, ranks each title
-- ROW_NUMBER() OVER (PARTITION BY brand ORDER BY count) 
--   numbers titles 1,2,3... within each brand
-- WHERE rank <= 3 keeps only the top 3 per brand
WITH top_brands AS (
    SELECT
        b.brand_name,
        COUNT(*) AS total_listings
    FROM analytics.fact_perfume_listing f
    JOIN analytics.brand b ON b.brand_id = f.brand_id
    GROUP BY b.brand_name
    ORDER BY total_listings DESC
    LIMIT 5
),
title_rankings AS (
    SELECT
        b.brand_name,
        f.title,
        COUNT(*)               AS total_listings,
        ROUND(AVG(f.price), 2) AS avg_price,
        ROW_NUMBER() OVER (
            PARTITION BY b.brand_name
            ORDER BY COUNT(*) DESC
        ) AS rank
    FROM analytics.fact_perfume_listing f
    JOIN analytics.brand b ON b.brand_id = f.brand_id
    WHERE b.brand_name IN (SELECT brand_name FROM top_brands)
    GROUP BY b.brand_name, f.title
)
SELECT
    brand_name,
    title,
    total_listings,
    avg_price
FROM title_rankings
WHERE rank <= 3
ORDER BY brand_name, total_listings DESC;

-- QUERY 5
-- Within the top 5 brands by units sold,
-- what are the top 3 titles by units sold per brand?

-- Same logic as Query 4 but uses SUM(sold) instead of COUNT(*)
-- This measures actual units sold, not just number of listings
WITH top_brands AS (
    SELECT
        b.brand_name,
        SUM(f.sold) AS total_units_sold
    FROM analytics.fact_perfume_listing f
    JOIN analytics.brand b ON b.brand_id = f.brand_id
    WHERE f.sold IS NOT NULL
    GROUP BY b.brand_name
    ORDER BY total_units_sold DESC
    LIMIT 5
),
title_rankings AS (
    SELECT
        b.brand_name,
        f.title,
        SUM(f.sold)            AS total_units_sold,
        ROUND(AVG(f.price), 2) AS avg_price,
        ROW_NUMBER() OVER (
            PARTITION BY b.brand_name
            ORDER BY SUM(f.sold) DESC
        ) AS rank
    FROM analytics.fact_perfume_listing f
    JOIN analytics.brand b ON b.brand_id = f.brand_id
    WHERE f.sold IS NOT NULL
    AND b.brand_name IN (SELECT brand_name FROM top_brands)
    GROUP BY b.brand_name, f.title
)
SELECT
    brand_name,
    title,
    total_units_sold,
    avg_price
FROM title_rankings
WHERE rank <= 3
ORDER BY brand_name, total_units_sold DESC;

-- QUERY 6
-- What is the average price per brand
-- for the top 5 most listed brands?

-- This combines listing count WITH average price in one view
-- Useful to see if popular brands are also expensive or affordable
SELECT
    b.brand_name,
    COUNT(*)               AS total_listings,
    ROUND(AVG(f.price), 2) AS avg_price,
    ROUND(MIN(f.price), 2) AS min_price,
    ROUND(MAX(f.price), 2) AS max_price
FROM analytics.fact_perfume_listing f
JOIN analytics.brand b ON b.brand_id = f.brand_id
GROUP BY b.brand_name
ORDER BY total_listings DESC
LIMIT 5;

-- QUERY 7
-- Which gender has more listings
-- and what is the average price per gender?

-- Simple comparison between men and women
-- Shows listings count, average price, and total units sold
SELECT
    g.gender_name,
    COUNT(*)               AS total_listings,
    ROUND(AVG(f.price), 2) AS avg_price,
    SUM(f.sold)            AS total_units_sold
FROM analytics.fact_perfume_listing f
JOIN analytics.gender g ON g.gender_id = f.gender_id
WHERE f.sold IS NOT NULL
GROUP BY g.gender_name
ORDER BY total_listings DESC;

-- QUERY 8
-- For each gender, which brand has the most listings?

-- WITH gender_brand_ranked: counts listings per gender + brand combo
-- ROW_NUMBER() OVER (PARTITION BY gender ORDER BY count DESC)
--   ranks brands within each gender: 1 = most listed brand
-- WHERE rank <= 3 shows top 3 brands per gender (not just top 1)
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
WHERE rank <= 3
ORDER BY gender_name, total_listings DESC;