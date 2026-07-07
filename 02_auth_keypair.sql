-- ============================================================
-- 02_auth_keypair.sql
-- Authentication — Key-Pair Auth for BI Tool Connections
-- Run in: local Terminal (key generation) + SnowSQL CLI (registration)
--
-- Used to connect Power BI to Snowflake without interactive MFA —
-- the production-appropriate method for service/tool accounts.
-- ============================================================

-- --- Terminal (bash/zsh), NOT SQL — generate the RSA key pair ---
-- openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out rsa_key.p8 -nocrypt
-- openssl rsa -in rsa_key.p8 -pubout -out rsa_key.pub
-- cat rsa_key.pub   -- copy the contents between BEGIN/END PUBLIC KEY lines

-- --- SnowSQL CLI — register the public key on the user ---
ALTER USER kalidaas23 SET RSA_PUBLIC_KEY='<paste public key content here>';

DESCRIBE USER kalidaas23;
-- Confirm HAS_KEYPAIR = true and RSA_PUBLIC_KEY_FP shows a fingerprint

-- --- Troubleshooting only — temporary MFA bypass (not for production use) ---
ALTER USER kalidaas23 SET MINS_TO_BYPASS_MFA = 60;
