-- ============================================================
-- 01_setup.sql
-- Environment Setup
-- Run in: Snowsight worksheet or SnowSQL CLI
--
-- Creates the warehouse, database, and the three-layer schema
-- (RAW / STAGING / MART) used throughout the pipeline.
-- ============================================================

CREATE WAREHOUSE IF NOT EXISTS PRET_WH
  WITH WAREHOUSE_SIZE = 'XSMALL' AUTO_SUSPEND = 60 AUTO_RESUME = TRUE;

CREATE DATABASE IF NOT EXISTS PRET_POC;

CREATE SCHEMA IF NOT EXISTS PRET_POC.RAW;
CREATE SCHEMA IF NOT EXISTS PRET_POC.STAGING;
CREATE SCHEMA IF NOT EXISTS PRET_POC.MART;

USE WAREHOUSE PRET_WH;
USE DATABASE PRET_POC;
USE SCHEMA RAW;
