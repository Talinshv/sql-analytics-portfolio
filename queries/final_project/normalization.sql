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

-- 9.  Create the Gender Table
CREATE TABLE analytics.gender (
    gender_id   SERIAL PRIMARY KEY,
    gender_name VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO analytics.gender (gender_name)
SELECT DISTINCT gender
FROM analytics._stg_perfume
WHERE gender IS NOT NULL;

SELECT * FROM analytics.gender LIMIT 10;

-- 10. create main table
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

-- 11. Fill the Fact Table from Your Raw Data
INSERT INTO analytics.fact_perfume_listing (
    title, price, available, sold, last_updated,
    brand_id, type_id, location_id, gender_id
)
SELECT
    s.title,
    s.price,
    s.available,
    s.sold,
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

--12. Verify Everything Worked
SELECT 'staging'    AS source, COUNT(*) FROM analytics._stg_perfume
UNION ALL
SELECT 'fact_table' AS source, COUNT(*) FROM analytics.fact_perfume_listing;