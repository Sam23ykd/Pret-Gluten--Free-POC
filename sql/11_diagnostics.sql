-- ============================================================
-- 11_diagnostics.sql
-- Diagnostics & Verification Queries (Reference)
-- Run in: Snowsight worksheet or SnowSQL CLI
--
-- Used during setup and troubleshooting — session/account
-- checks, login history, and grants. Not part of the main
-- pipeline, kept here for reference.
-- ============================================================

SELECT CURRENT_ACCOUNT(), CURRENT_USER(), CURRENT_REGION();

SELECT
  EVENT_TIMESTAMP,
  REPORTED_CLIENT_TYPE,
  FIRST_AUTHENTICATION_FACTOR,
  IS_SUCCESS,
  ERROR_CODE,
  ERROR_MESSAGE
FROM TABLE(INFORMATION_SCHEMA.LOGIN_HISTORY())
WHERE IS_SUCCESS = 'NO'
ORDER BY EVENT_TIMESTAMP DESC
LIMIT 10;

SHOW GRANTS TO USER kalidaas23;

SHOW NETWORK POLICIES;
