-- ============================================================
-- 07_bridge_tables.sql
-- Bridge Tables — Normalizing Comma-Separated Tags
-- Run in: Snowsight worksheet or SnowSQL CLI
--
-- Open Food Facts stores categories, allergens, and labels as
-- comma-separated strings. LATERAL SPLIT_TO_TABLE explodes each
-- into one row per product-tag pair for proper relational modeling.
-- ============================================================

CREATE OR REPLACE TABLE PRET_POC.STAGING.STG_PRODUCT_CATEGORIES AS
SELECT
  product_id,
  TRIM(c.value) AS category
FROM PRET_POC.STAGING.STG_PRODUCTS,
LATERAL SPLIT_TO_TABLE(categories_tags, ',') c
WHERE TRIM(c.value) != '';

CREATE OR REPLACE TABLE PRET_POC.STAGING.STG_PRODUCT_ALLERGENS AS
SELECT
  product_id,
  TRIM(a.value) AS allergen
FROM PRET_POC.STAGING.STG_PRODUCTS,
LATERAL SPLIT_TO_TABLE(allergens, ',') a
WHERE TRIM(a.value) != '';

CREATE OR REPLACE TABLE PRET_POC.STAGING.STG_PRODUCT_LABELS AS
SELECT
  product_id,
  TRIM(l.value) AS label
FROM PRET_POC.STAGING.STG_PRODUCTS,
LATERAL SPLIT_TO_TABLE(labels_tags, ',') l
WHERE TRIM(l.value) != '';

-- --- Quick sanity check ---
SELECT category, COUNT(DISTINCT product_id) AS product_count
FROM PRET_POC.STAGING.STG_PRODUCT_CATEGORIES
GROUP BY category
ORDER BY product_count DESC
LIMIT 20;
