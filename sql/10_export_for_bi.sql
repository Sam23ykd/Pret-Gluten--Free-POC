-- ============================================================
-- 10_export_for_bi.sql
-- Exporting Data for Power BI (COPY INTO + GET)
-- Run in: SnowSQL CLI ONLY (GET requires local filesystem access)
--
-- Exports each summary table to the stage as CSV, then
-- downloads it locally for loading into Power BI (flat-file
-- import, used after live-connection issues on the trial account).
-- ============================================================

COPY INTO @PRET_POC.RAW.OFF_STAGE/exports2/summary_category/
FROM PRET_POC.MART.SUMMARY_CATEGORY_GLUTENFREE
FILE_FORMAT = (TYPE = CSV, COMPRESSION = NONE, FIELD_DELIMITER = ',', FIELD_OPTIONALLY_ENCLOSED_BY = '"')
HEADER = TRUE SINGLE = TRUE MAX_FILE_SIZE = 200000000 OVERWRITE = TRUE;

COPY INTO @PRET_POC.RAW.OFF_STAGE/exports2/summary_allergen/
FROM PRET_POC.MART.SUMMARY_ALLERGEN_COUNTS
FILE_FORMAT = (TYPE = CSV, COMPRESSION = NONE, FIELD_DELIMITER = ',', FIELD_OPTIONALLY_ENCLOSED_BY = '"')
HEADER = TRUE SINGLE = TRUE MAX_FILE_SIZE = 200000000 OVERWRITE = TRUE;

COPY INTO @PRET_POC.RAW.OFF_STAGE/exports2/summary_nutriscore/
FROM PRET_POC.MART.SUMMARY_NUTRISCORE_BY_GF
FILE_FORMAT = (TYPE = CSV, COMPRESSION = NONE, FIELD_DELIMITER = ',', FIELD_OPTIONALLY_ENCLOSED_BY = '"')
HEADER = TRUE SINGLE = TRUE MAX_FILE_SIZE = 200000000 OVERWRITE = TRUE;

COPY INTO @PRET_POC.RAW.OFF_STAGE/exports2/summary_kpis/
FROM PRET_POC.MART.SUMMARY_KPIS
FILE_FORMAT = (TYPE = CSV, COMPRESSION = NONE, FIELD_DELIMITER = ',', FIELD_OPTIONALLY_ENCLOSED_BY = '"')
HEADER = TRUE SINGLE = TRUE MAX_FILE_SIZE = 200000000 OVERWRITE = TRUE;

-- --- Download to local machine (SnowSQL CLI) ---
GET @PRET_POC.RAW.OFF_STAGE/exports2/summary_category/ file:///Users/dtech/Downloads/pret_exports2/summary_category/;
GET @PRET_POC.RAW.OFF_STAGE/exports2/summary_allergen/ file:///Users/dtech/Downloads/pret_exports2/summary_allergen/;
GET @PRET_POC.RAW.OFF_STAGE/exports2/summary_nutriscore/ file:///Users/dtech/Downloads/pret_exports2/summary_nutriscore/;
GET @PRET_POC.RAW.OFF_STAGE/exports2/summary_kpis/ file:///Users/dtech/Downloads/pret_exports2/summary_kpis/;

-- --- Local terminal companion steps (not SQL, included for completeness) ---
-- mkdir -p ~/Downloads/pret_exports2/summary_category
-- mkdir -p ~/Downloads/pret_exports2/summary_allergen
-- mkdir -p ~/Downloads/pret_exports2/summary_nutriscore
-- mkdir -p ~/Downloads/pret_exports2/summary_kpis
--
-- cd ~/Downloads/pret_exports2
-- gunzip summary_category/data
-- gunzip summary_allergen/data
-- gunzip summary_nutriscore/data
-- gunzip summary_kpis/data
--
-- mv summary_category/data summary_category.csv
-- mv summary_allergen/data summary_allergen.csv
-- mv summary_nutriscore/data summary_nutriscore.csv
-- mv summary_kpis/data summary_kpis.csv
