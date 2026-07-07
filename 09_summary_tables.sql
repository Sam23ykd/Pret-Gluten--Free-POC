-- ============================================================
-- 09_summary_tables.sql
-- BI-Ready Summary Tables
-- Run in: Snowsight worksheet or SnowSQL CLI
--
-- Pre-aggregated tables sized for Power BI — keeps the BI layer
-- lightweight instead of shipping full row-level MART tables
-- to the dashboard (avoids Power BI file-size limits).
-- ============================================================

CREATE OR REPLACE TABLE PRET_POC.MART.SUMMARY_CATEGORY_GLUTENFREE AS
SELECT
  bc.category,
  COUNT(DISTINCT dp.product_id) AS total_products,
  COUNT(DISTINCT CASE WHEN dp.is_gluten_free = TRUE THEN dp.product_id END) AS gluten_free_products,
  ROUND(COUNT(DISTINCT CASE WHEN dp.is_gluten_free = TRUE THEN dp.product_id END)
        / NULLIF(COUNT(DISTINCT dp.product_id), 0) * 100, 1) AS pct_gluten_free
FROM PRET_POC.MART.DIM_PRODUCT dp
JOIN PRET_POC.MART.BRIDGE_PRODUCT_CATEGORY bc ON dp.product_id = bc.product_id
GROUP BY bc.category
HAVING COUNT(DISTINCT dp.product_id) >= 20  -- drop noise categories with tiny counts
ORDER BY total_products DESC;

CREATE OR REPLACE TABLE PRET_POC.MART.SUMMARY_ALLERGEN_COUNTS AS
SELECT
  ba.allergen,
  COUNT(DISTINCT ba.product_id) AS product_count
FROM PRET_POC.MART.BRIDGE_PRODUCT_ALLERGEN ba
GROUP BY ba.allergen
ORDER BY product_count DESC
LIMIT 20;

CREATE OR REPLACE TABLE PRET_POC.MART.SUMMARY_NUTRISCORE_BY_GF AS
SELECT
  dp.nutriscore_grade,
  dp.is_gluten_free,
  COUNT(DISTINCT dp.product_id) AS product_count
FROM PRET_POC.MART.DIM_PRODUCT dp
WHERE dp.nutriscore_grade IS NOT NULL
GROUP BY dp.nutriscore_grade, dp.is_gluten_free
ORDER BY dp.nutriscore_grade;

CREATE OR REPLACE TABLE PRET_POC.MART.SUMMARY_KPIS AS
SELECT
  COUNT(DISTINCT product_id) AS total_products,
  COUNT(DISTINCT CASE WHEN is_gluten_free = TRUE THEN product_id END) AS gluten_free_products,
  ROUND(COUNT(DISTINCT CASE WHEN is_gluten_free = TRUE THEN product_id END)
        / NULLIF(COUNT(DISTINCT product_id), 0) * 100, 1) AS pct_gluten_free
FROM PRET_POC.MART.DIM_PRODUCT;
