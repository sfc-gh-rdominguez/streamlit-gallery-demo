-- Two placeholder apps so the gallery has something to show. With no FROM, Snowflake uses its default app.
-- TITLE and COMMENT become the card heading and description.
USE ROLE gallery_admin;

CREATE STREAMLIT IF NOT EXISTS gallery_db.apps.sales_dashboard
  QUERY_WAREHOUSE = gallery_wh
  TITLE = 'Sales Dashboard'
  COMMENT = 'Daily bookings and revenue by region.';
ALTER STREAMLIT gallery_db.apps.sales_dashboard ADD LIVE VERSION FROM LAST;

CREATE STREAMLIT IF NOT EXISTS gallery_db.apps.inventory_tracker
  QUERY_WAREHOUSE = gallery_wh
  TITLE = 'Inventory Tracker'
  COMMENT = 'Stock levels and reorder alerts by warehouse.';
ALTER STREAMLIT gallery_db.apps.inventory_tracker ADD LIVE VERSION FROM LAST;
