-- ============================================================
-- 06_staging_layer.sql
-- Staging Layer — Cleaning, Typing & Deduplication
-- Run in: Snowsight worksheet or SnowSQL CLI
--
-- Derives the gluten-free flag, defensively types numeric
-- fields with TRY_CAST, and removes duplicate product codes
-- using QUALIFY + ROW_NUMBER().
-- ============================================================

CREATE OR REPLACE TABLE PRET_POC.STAGING.STG_PRODUCTS AS
SELECT
  code AS product_id,
  TRIM(product_name) AS product_name,
  TRIM(brands) AS brand,
  categories_tags,
  labels_tags,
  allergens,
  traces_tags,
  countries_tags,
  origins,
  nutriscore_grade,
  environmental_score_grade,

  -- Gluten-free derivation logic:
  -- explicit label -> TRUE; explicit allergen mention -> FALSE;
  -- otherwise NULL (unknown), never assumed FALSE by default.
  CASE
    WHEN labels_tags ILIKE '%gluten-free%' OR labels_tags ILIKE '%no-gluten%' THEN TRUE
    WHEN allergens ILIKE '%gluten%' THEN FALSE
    ELSE NULL
  END AS is_gluten_free,

  TRY_CAST(energy_100g AS FLOAT) AS energy_100g,
  TRY_CAST(fat_100g AS FLOAT) AS fat_100g,
  TRY_CAST(sugars_100g AS FLOAT) AS sugars_100g,
  TRY_CAST(fiber_100g AS FLOAT) AS fiber_100g,
  TRY_CAST(proteins_100g AS FLOAT) AS proteins_100g,
  TRY_CAST(salt_100g AS FLOAT) AS salt_100g

FROM PRET_POC.RAW.OFF_PRODUCTS_SCOPED
WHERE product_name IS NOT NULL
  AND TRIM(product_name) != ''
  AND code IS NOT NULL
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY code
  ORDER BY
    -- keep the most "complete" row per duplicated product code
    (CASE WHEN product_name IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN energy_100g IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN nutriscore_grade IS NOT NULL THEN 1 ELSE 0 END) DESC
) = 1;

-- --- Verification ---
SELECT COUNT(*) FROM PRET_POC.STAGING.STG_PRODUCTS;

SELECT is_gluten_free, COUNT(*) AS product_count
FROM PRET_POC.STAGING.STG_PRODUCTS
GROUP BY is_gluten_free
ORDER BY is_gluten_free;

-- Confirm no duplicate product_ids remain (should return 0 rows)
SELECT product_id, COUNT(*) c
FROM PRET_POC.STAGING.STG_PRODUCTS
GROUP BY product_id
HAVING c > 1;
