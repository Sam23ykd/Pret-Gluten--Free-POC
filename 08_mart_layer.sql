-- ============================================================
-- 08_mart_layer.sql
-- MART Layer — Star Schema for Analysis
-- Run in: Snowsight worksheet or SnowSQL CLI
--
-- Analysis-ready dimensional model: one product dimension,
-- one category dimension, two bridge tables, one fact table.
-- This is the layer Power BI connects to.
-- ============================================================

CREATE OR REPLACE TABLE PRET_POC.MART.DIM_PRODUCT AS
SELECT
  product_id,
  product_name,
  brand,
  is_gluten_free,
  nutriscore_grade,
  environmental_score_grade,
  origins,
  countries_tags
FROM PRET_POC.STAGING.STG_PRODUCTS;

CREATE OR REPLACE TABLE PRET_POC.MART.DIM_CATEGORY AS
SELECT DISTINCT category
FROM PRET_POC.STAGING.STG_PRODUCT_CATEGORIES
WHERE category IS NOT NULL;

CREATE OR REPLACE TABLE PRET_POC.MART.BRIDGE_PRODUCT_CATEGORY AS
SELECT product_id, category
FROM PRET_POC.STAGING.STG_PRODUCT_CATEGORIES;

CREATE OR REPLACE TABLE PRET_POC.MART.BRIDGE_PRODUCT_ALLERGEN AS
SELECT product_id, allergen
FROM PRET_POC.STAGING.STG_PRODUCT_ALLERGENS;

CREATE OR REPLACE TABLE PRET_POC.MART.FACT_PRODUCT_NUTRITION AS
SELECT
  product_id,
  energy_100g,
  fat_100g,
  sugars_100g,
  fiber_100g,
  proteins_100g,
  salt_100g
FROM PRET_POC.STAGING.STG_PRODUCTS;

-- --- Validation rollup: gluten-free share by category ---
SELECT
  bc.category,
  COUNT(DISTINCT dp.product_id) AS total_products,
  COUNT(DISTINCT CASE WHEN dp.is_gluten_free = TRUE THEN dp.product_id END) AS gluten_free_products,
  ROUND(gluten_free_products / NULLIF(total_products, 0) * 100, 1) AS pct_gluten_free
FROM PRET_POC.MART.DIM_PRODUCT dp
JOIN PRET_POC.MART.BRIDGE_PRODUCT_CATEGORY bc ON dp.product_id = bc.product_id
GROUP BY bc.category
ORDER BY total_products DESC
LIMIT 20;
