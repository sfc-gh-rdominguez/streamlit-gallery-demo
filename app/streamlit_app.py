import pandas as pd
import streamlit as st
from snowflake.snowpark.context import get_active_session

# Every Streamlit in this schema gets a card. Owner's rights: viewers see what GALLERY_ADMIN sees.
APPS_SCHEMA = "GALLERY_DB.APPS"

session = get_active_session()


@st.cache_data(ttl=300)
def load_apps():
    # Snowpark can't infer the schema of a SHOW ->> pipe, so collect the SHOW and shape it here
    rows = session.sql(f"SHOW STREAMLITS IN SCHEMA {APPS_SCHEMA}").collect()
    apps = pd.DataFrame([r.as_dict() for r in rows], columns=["name", "title", "comment", "url_id"])
    return apps.sort_values("title", key=lambda s: s.fillna(apps["name"]).str.lower())


@st.cache_data
def viewer_base_url():
    org, acct = session.sql(
        "SELECT LOWER(CURRENT_ORGANIZATION_NAME()), LOWER(CURRENT_ACCOUNT_NAME())"
    ).collect()[0]
    return f"https://app.snowflake.com/streamlit/{org}/{acct}/#/apps/"


st.title("App Gallery")

apps = load_apps()
search = st.text_input("Search apps")
if search:
    apps = apps[
        apps["name"].str.contains(search, case=False)
        | apps["title"].fillna("").str.contains(search, case=False)
        | apps["comment"].fillna("").str.contains(search, case=False)
    ]

if apps.empty:
    st.info("No apps found.")

base = viewer_base_url()
cols = st.columns(3)
for i, app in enumerate(apps.itertuples()):
    with cols[i % 3], st.container(border=True):
        st.markdown(f"### {app.title or app.name}")
        st.caption(app.comment or "")
        st.link_button("Open app →", base + app.url_id)
