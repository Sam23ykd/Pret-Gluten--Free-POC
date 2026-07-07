-- ============================================================
-- 05_scope_data.sql
-- Scoping to the Business Use Case
-- Run in: Snowsight worksheet or SnowSQL CLI
--
-- Filters the full raw load down to categories relevant to
-- Pret's product range (bread, snacks, bakery, etc.)
-- ============================================================

CREATE OR REPLACE TABLE PRET_POC.RAW.OFF_PRODUCTS_SCOPED AS
SELECT *
FROM PRET_POC.RAW.OFF_PRODUCTS_RAW
WHERE categories_tags ILIKE '%bread%'
   OR categories_tags ILIKE '%sandwich%'
   OR categories_tags ILIKE '%cake%'
   OR categories_tags ILIKE '%snack%'
   OR categories_tags ILIKE '%salad%'
   OR categories_tags ILIKE '%wrap%'
   OR categories_tags ILIKE '%pastry%'
   OR categories_tags ILIKE '%bakery%';

SELECT COUNT(*) FROM PRET_POC.RAW.OFF_PRODUCTS_SCOPED;
-- Expect ~437,770 rows
