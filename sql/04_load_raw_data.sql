-- ============================================================
-- 04_load_raw_data.sql
-- Loading Raw Data (PUT + COPY INTO)
-- Run in: SnowSQL CLI ONLY
--         (PUT/GET require local filesystem access — not
--         available in the Snowsight web worksheet)
--
-- Source: Open Food Facts full CSV export (tab-delimited,
-- ~4.5M products, 200+ columns). Only ~18 relevant columns
-- are selected by position rather than loading the full schema.
-- ============================================================

-- Upload the source file to the stage
PUT file:///Users/dtech/Downloads/en.openfoodfacts.org.products.csv.gz
  @PRET_POC.RAW.OFF_STAGE
  AUTO_COMPRESS = FALSE;

LIST @PRET_POC.RAW.OFF_STAGE;

-- Create the RAW table
CREATE OR REPLACE TABLE PRET_POC.RAW.OFF_PRODUCTS_RAW (
  code STRING,
  product_name STRING,
  brands STRING,
  categories_tags STRING,
  labels_tags STRING,
  allergens STRING,
  traces_tags STRING,
  ingredients_text STRING,
  countries_tags STRING,
  origins STRING,
  nutriscore_grade STRING,
  environmental_score_grade STRING,
  energy_100g FLOAT,
  fat_100g FLOAT,
  sugars_100g FLOAT,
  fiber_100g FLOAT,
  proteins_100g FLOAT,
  salt_100g FLOAT
);

-- Load selected columns by position (see column-position notes below)
-- code=$1, product_name=$11, brands=$19, categories_tags=$23, labels_tags=$31,
-- allergens=$46, traces_tags=$49, ingredients_text=$43, countries_tags=$41,
-- origins=$25, nutriscore_grade=$59, environmental_score_grade=$71,
-- energy_100g=$91, fat_100g=$93, sugars_100g=$131, fiber_100g=$147,
-- proteins_100g=$151, salt_100g=$155
COPY INTO PRET_POC.RAW.OFF_PRODUCTS_RAW (
  code, product_name, brands, categories_tags, labels_tags,
  allergens, traces_tags, ingredients_text, countries_tags,
  origins, nutriscore_grade, environmental_score_grade,
  energy_100g, fat_100g, sugars_100g, fiber_100g, proteins_100g, salt_100g
)
FROM (
  SELECT
    $1, $11, $19, $23, $31,
    $46, $49, $43, $41,
    $25, $59, $71,
    $91, $93, $131, $147, $151, $155
  FROM @PRET_POC.RAW.OFF_STAGE
)
FILE_FORMAT = PRET_POC.RAW.OFF_TSV_FORMAT
ON_ERROR = 'CONTINUE';

SELECT COUNT(*) FROM PRET_POC.RAW.OFF_PRODUCTS_RAW;
-- Expect ~4,532,614 rows loaded (153 rows skipped due to malformed source data)
