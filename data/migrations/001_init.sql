-- Role, warehouse, database, and the two schemas: APPS (what the gallery shows) and HUB (the gallery itself)
USE ROLE ACCOUNTADMIN;

CREATE ROLE IF NOT EXISTS gallery_admin;
GRANT ROLE gallery_admin TO ROLE SYSADMIN;

SET grant_stmt = 'GRANT ROLE gallery_admin TO USER "' || CURRENT_USER() || '"';
EXECUTE IMMEDIATE $grant_stmt;

CREATE WAREHOUSE IF NOT EXISTS gallery_wh
  WAREHOUSE_SIZE = XSMALL AUTO_SUSPEND = 60 AUTO_RESUME = TRUE INITIALLY_SUSPENDED = TRUE;
GRANT OWNERSHIP ON WAREHOUSE gallery_wh TO ROLE gallery_admin COPY CURRENT GRANTS;

CREATE DATABASE IF NOT EXISTS gallery_db;
GRANT OWNERSHIP ON DATABASE gallery_db TO ROLE gallery_admin COPY CURRENT GRANTS;

USE ROLE gallery_admin;
CREATE SCHEMA IF NOT EXISTS gallery_db.apps;
CREATE SCHEMA IF NOT EXISTS gallery_db.hub;

-- The gallery runs with owner's rights, so it lists what GALLERY_ADMIN can see.
-- Apps other roles create in APPS show up automatically through the future grant.
USE ROLE ACCOUNTADMIN;
GRANT USAGE ON ALL STREAMLITS IN SCHEMA gallery_db.apps TO ROLE gallery_admin;
GRANT USAGE ON FUTURE STREAMLITS IN SCHEMA gallery_db.apps TO ROLE gallery_admin;
