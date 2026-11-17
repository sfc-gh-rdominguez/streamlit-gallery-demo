# Streamlit App Gallery

One Streamlit in Snowflake app that lists every Streamlit in `GALLERY_DB.APPS` as a searchable card, each linking to
the app-viewer URL. No hardcoded list: a new app in the schema shows up within five minutes.

- **Warehouse runtime, owner's rights.** The gallery lists what `GALLERY_ADMIN` can see, so every viewer sees the same
  cards. Snowflake still blocks an app for anyone without `USAGE` on it.
- **Metadata is the catalog.** Each app's `TITLE` and `COMMENT` become its card.

## Quick start

```sh
just up <connection>              # objects, two demo apps, the gallery, and its URL
just share <connection> <role>    # let a role open the gallery
```

Viewers also need `USAGE` on each app they open (and on `GALLERY_DB.APPS`).

## Layout

```
data/migrations/   001: role, warehouse, database, schemas, future grants   002: demo apps
app/               streamlit_app.py and snowflake.yml
```

`just teardown <connection>` drops everything.
