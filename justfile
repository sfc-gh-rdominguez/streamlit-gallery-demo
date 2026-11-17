# List recipes
default:
  @just --list

# Preflight: local tools and Snowflake reachability
doctor connection:
  @command -v snow >/dev/null && echo "✓ snow" || { echo "✗ snow missing"; exit 1; }
  @snow sql -c {{connection}} -q "SELECT CURRENT_ACCOUNT()" >/dev/null 2>&1 && echo "✓ Snowflake reachable via '{{connection}}'" || { echo "✗ cannot reach Snowflake via '{{connection}}'"; exit 1; }

# One shot: objects, demo apps, gallery, and its URL (safe to re-run)
up connection: (doctor connection) (setup connection) (demo connection) (deploy connection) (url connection)

# Role, warehouse, database, and schemas
setup connection:
  snow sql -c {{connection}} -f data/migrations/001_init.sql

# Two placeholder apps in GALLERY_DB.APPS
demo connection:
  snow sql -c {{connection}} -f data/migrations/002_demo_apps.sql

# Deploy the gallery (warehouse runtime, owner's rights)
deploy connection:
  snow streamlit deploy --replace -c {{connection}} --role gallery_admin -p app

# App-viewer URL of the gallery
url connection:
  @snow sql -c {{connection}} --role gallery_admin -q "SHOW STREAMLITS IN SCHEMA gallery_db.hub ->> SELECT 'https://app.snowflake.com/streamlit/' || LOWER(CURRENT_ORGANIZATION_NAME()) || '/' || LOWER(CURRENT_ACCOUNT_NAME()) || '/#/apps/' || \"url_id\" AS gallery_url FROM \$1"

# Let a role open the gallery: just share <conn> analyst
share connection role:
  snow sql -c {{connection}} --role gallery_admin -q "GRANT USAGE ON DATABASE gallery_db TO ROLE {{role}}; GRANT USAGE ON SCHEMA gallery_db.hub TO ROLE {{role}}; GRANT USAGE ON STREAMLIT gallery_db.hub.gallery TO ROLE {{role}}"

# Remove every Snowflake object
[confirm("Drop GALLERY_DB, GALLERY_WH, and GALLERY_ADMIN? [y/N]")]
teardown connection:
  snow sql -c {{connection}} -f data/teardown/teardown.sql
