-- ============================================================
-- 03_file_format_and_stage.sql
-- File Format & Internal Stage Setup
-- Run in: Snowsight worksheet or SnowSQL CLI
--
-- Defines how the tab-delimited Open Food Facts export is parsed,
-- and creates the internal stage used to hold the uploaded file.
-- ============================================================

CREATE OR REPLACE FILE FORMAT PRET_POC.RAW.OFF_TSV_FORMAT
  TYPE = 'CSV'
  FIELD_DELIMITER = '\t'
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  NULL_IF = ('', 'NULL')
  EMPTY_FIELD_AS_NULL = TRUE
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
  COMPRESSION = 'GZIP';

CREATE OR REPLACE STAGE PRET_POC.RAW.OFF_STAGE
  FILE_FORMAT = PRET_POC.RAW.OFF_TSV_FORMAT;
