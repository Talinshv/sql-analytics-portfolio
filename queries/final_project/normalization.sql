-- 1. Create the schema
CREATE SCHEMA IF NOT EXISTS analytics;

-- 2. Create table for _stg_perfume
CREATE TABLE analytics._stg_perfume (
    brand             VARCHAR(255),
    title             VARCHAR(500),
    type              VARCHAR(255),
    price             NUMERIC(10, 2),
    "priceWithCurrency" VARCHAR(50),
    available         NUMERIC(10, 2),
    "availableText"   VARCHAR(255),
    sold              NUMERIC(10, 2),
    "lastUpdated"     VARCHAR(100),
    "itemLocation"    VARCHAR(500),
    gender            VARCHAR(50)
);

-- 3. Move data to pgadmin
COPY analytics._stg_perfume
FROM '/docker-entrypoint-initdb.d/data/final_project_schema/perfume_denormalized.csv'
CSV HEADER
NULL '';

-- 4. CHeck the number of rows
SELECT count(*) FROM analytics._stg_perfume;

-- 5. Show 5 line of the data
SELECT * FROM analytics._stg_perfume LIMIT 5;

-- 6. Create the Brand Table
CREATE TABLE analytics.brand (
    brand_id   SERIAL PRIMARY KEY,
    brand_name VARCHAR(255) NOT NULL UNIQUE
);
INSERT INTO analytics.brand (brand_name)
SELECT DISTINCT brand
FROM analytics._stg_perfume
WHERE brand IS NOT NULL;

SELECT * FROM analytics.brand LIMIT 10;

-- 7. Create the Fragrance Type Table
CREATE TABLE analytics.fragrance_type (
    type_id   SERIAL PRIMARY KEY,
    type_name VARCHAR(255) NOT NULL UNIQUE
);

INSERT INTO analytics.fragrance_type (type_name)
SELECT DISTINCT type
FROM analytics._stg_perfume
WHERE type IS NOT NULL;

SELECT * FROM analytics.fragrance_type LIMIT 10;

-- 8. Create the Location Table
CREATE TABLE analytics.location (
    location_id   SERIAL PRIMARY KEY,
    full_location VARCHAR(500) NOT NULL UNIQUE
);

INSERT INTO analytics.location (full_location)
SELECT DISTINCT "itemLocation"
FROM analytics._stg_perfume
WHERE "itemLocation" IS NOT NULL;

SELECT * FROM analytics.location LIMIT 10;

-- 9. Add city, state, country as separate columns
ALTER TABLE analytics.location
ADD COLUMN city    VARCHAR(255),
ADD COLUMN state   VARCHAR(255),
ADD COLUMN country VARCHAR(255);

-- 10. Split full location into the 3 new columns
UPDATE analytics.location
SET
    city    = TRIM(SPLIT_PART(full_location, ',', 1)),
    state   = TRIM(SPLIT_PART(full_location, ',', 2)),
    country = TRIM(SPLIT_PART(full_location, ',', 3));

SELECT full_location, city, state, country
FROM analytics.location
LIMIT 10;


-- 11.  Create the Gender Table
CREATE TABLE analytics.gender (
    gender_id   SERIAL PRIMARY KEY,
    gender_name VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO analytics.gender (gender_name)
SELECT DISTINCT gender
FROM analytics._stg_perfume
WHERE gender IS NOT NULL;

SELECT * FROM analytics.gender LIMIT 10;

-- 12. create main table
CREATE TABLE analytics.fact_perfume_listing (
    listing_id    SERIAL PRIMARY KEY,
    title         VARCHAR(500),
    price         NUMERIC(10, 2),
    available     NUMERIC(10, 2),
    sold          INT,
    last_updated  TIMESTAMP,
    brand_id      INT REFERENCES analytics.brand(brand_id),
    type_id       INT REFERENCES analytics.fragrance_type(type_id),
    location_id   INT REFERENCES analytics.location(location_id),
    gender_id     INT REFERENCES analytics.gender(gender_id)
);

-- 13. Fill the Fact Table from Your Raw Data
INSERT INTO analytics.fact_perfume_listing (
    title, price, available, sold, last_updated,
    brand_id, type_id, location_id, gender_id
)
SELECT
    s.title,
    s.price,
    s.available,
    s.sold::INT,
    CASE
        WHEN s."lastUpdated" ~ '^\d'
        THEN NULL
        ELSE TO_TIMESTAMP(s."lastUpdated", 'Mon DD, YYYY HH24:MI:SS TZ')
    END,
    b.brand_id,
    t.type_id,
    l.location_id,
    g.gender_id
FROM analytics._stg_perfume s
LEFT JOIN analytics.brand          b ON b.brand_name    = s.brand
LEFT JOIN analytics.fragrance_type t ON t.type_name     = s.type
LEFT JOIN analytics.location       l ON l.full_location = s."itemLocation"
LEFT JOIN analytics.gender         g ON g.gender_name   = s.gender;

--14. Verify Everything Worked 
SELECT 'staging'    AS source, COUNT(*) FROM analytics._stg_perfume
UNION ALL
SELECT 'fact_table' AS source, COUNT(*) FROM analytics.fact_perfume_listing;

SELECT * FROM analytics.location LIMIT 10;

--Questions:
--1.Which brands have the most listings?(counts how many rows (listings) exist per brand)
SELECT
    b.brand_name,
    COUNT(*) AS total_listings
FROM analytics.fact_perfume_listing f
JOIN analytics.brand b ON b.brand_id = f.brand_id
GROUP BY b.brand_name
ORDER BY total_listings DESC
LIMIT 10;

--2.Which brand has the highest average price?
SELECT
    b.brand_name,
    ROUND(AVG(f.price), 2) AS avg_price
FROM analytics.fact_perfume_listing f
JOIN analytics.brand b ON b.brand_id = f.brand_id
GROUP BY b.brand_name
ORDER BY avg_price DESC
LIMIT 10;

--3.Which brand has sold the most units in total?
SELECT
    b.brand_name,
    SUM(f.sold) AS total_units_sold
FROM analytics.fact_perfume_listing f
JOIN analytics.brand b ON b.brand_id = f.brand_id
WHERE f.sold IS NOT NULL
GROUP BY b.brand_name
ORDER BY total_units_sold DESC
LIMIT 10;

--4. Top 10 best selling perfumes by units sold?
SELECT
    b.brand_name,
    f.title,
    f.sold
FROM analytics.fact_perfume_listing f
JOIN analytics.brand b ON b.brand_id = f.brand_id
WHERE f.sold IS NOT NULL
ORDER BY f.sold DESC
LIMIT 10;

-- 5.Average price per fragrance type?
SELECT
    t.type_name,
    ROUND(AVG(f.price), 2) AS avg_price,
    COUNT(*)               AS total_listings
FROM analytics.fact_perfume_listing f
JOIN analytics.fragrance_type t ON t.type_id = f.type_id
GROUP BY t.type_name
ORDER BY avg_price DESC;

SELECT
    b.brand_name,
    COUNT(*)               AS total_listings,
    ROUND(AVG(f.price), 2) AS avg_price
FROM analytics.fact_perfume_listing f
JOIN analytics.brand b ON b.brand_id = f.brand_id
GROUP BY b.brand_name
ORDER BY total_listings DESC
LIMIT 10;
