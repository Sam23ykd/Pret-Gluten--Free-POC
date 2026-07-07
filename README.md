# Pret Gluten-Free Opportunity Analysis — Data Engineering POC

A proof-of-concept data pipeline built for Pret A Manger's Data Engineering exercise. Uses the [Open Food Facts](https://world.openfoodfacts.org/data) dataset to identify where gluten-free product alternatives are strongest and weakest across categories, supporting Pret's product range decisions.

## Business Problem

Pret's food team wants to broaden its gluten-free range but needs evidence on where gaps and opportunities exist before committing sourcing effort. This project evaluates whether Open Food Facts can serve as a reliable, low-cost signal for that decision.

## Tech Stack

- **Data source:** Open Food Facts full CSV export (~4.5M products)
- **Warehouse:** Snowflake
- **BI / Visualization:** Power BI
- **Loading:** SnowSQL CLI (`PUT` / `COPY INTO` / `GET`)

## Pipeline Architecture

```
Open Food Facts (CSV export)
        │
        ▼
   RAW layer          ── source-fidelity copy, no transformation
        │
        ▼
   STAGING layer       ── typed, deduplicated, gluten-free flag derived
        │
        ▼
   MART layer          ── star schema: dimensions, bridge tables, fact table
        │
        ▼
   Summary tables       ── pre-aggregated, BI-ready
        │
        ▼
   Power BI dashboard
```

Three-layer (RAW → STAGING → MART) design chosen so the pipeline can be re-run from any stage without re-extracting from source, and so the BI layer only ever queries clean, deduplicated, pre-aggregated data.

## Repository Structure

```
/sql/
  01_setup.sql                  Warehouse, database, schema creation
  02_auth_keypair.sql           Key-pair auth setup for Power BI connection
  03_file_format_and_stage.sql  File format + internal stage definition
  04_load_raw_data.sql          PUT + COPY INTO — raw data load (~4.5M rows)
  05_scope_data.sql             Filter to Pret-relevant categories (~438K rows)
  06_staging_layer.sql          Cleaning, typing, gluten-free flag, dedup
  07_bridge_tables.sql          Normalize comma-separated tags (categories/allergens/labels)
  08_mart_layer.sql             Star schema: DIM_PRODUCT, DIM_CATEGORY, bridge & fact tables
  09_summary_tables.sql         Pre-aggregated tables for Power BI
  10_export_for_bi.sql          Export MART tables to CSV + download via GET
  11_diagnostics.sql            Reference queries used for troubleshooting
/docs/
  Pret_SnowSQL_Scripts.docx     All SQL scripts in a single reference document
/presentation/
  Pret_GlutenFree_Presentation.pptx   Slide deck: problem, approach, insights, next steps
/dashboard/
  Pret_GlutenFree_Dashboard.pbix      Power BI dashboard (interactive, requires Power BI Desktop/service)
  Pret_GlutenFree_Dashboard.pdf       Static export for quick viewing without Power BI
README.md
```

Run the `/sql` scripts in numeric order to reproduce the pipeline end to end.

## Key Results

See the full interactive dashboard in [`/dashboard/Pret_GlutenFree_Dashboard.pbix`](./dashboard/Pret_GlutenFree_Dashboard.pbix) (or the static [PDF export](./dashboard/Pret_GlutenFree_Dashboard.pdf) if you don't have Power BI installed).

| Metric | Value |
|---|---|
| Total products in scope | 423,879 |
| Gluten-free products identified | 30,389 |
| Share of scoped range that is gluten-free | 7.2% |
| Raw load success rate | 99.997% (153 rows skipped) |

**Headline insight:** Snacks lead in raw gluten-free product volume, but smaller categories over-index on *share* — chips & fries (19.2%) and appetizers (14.7%) are proportionally far more gluten-free than biscuits & cakes (4.1%), pointing to a clearer whitespace opportunity than volume alone suggests.

## Known Trade-offs

- **Category-filtered, not full dataset** — scoped to Pret-relevant categories rather than loading all 4.5M products, to keep the POC fast and focused.
- **NULL vs. FALSE for gluten status** — absence of a gluten-free label is treated as "unknown," not "contains gluten," to avoid overstating confidence. Roughly 75% of products with a known Nutriscore grade carry no explicit gluten label.
- **Flat-file BI connection, not live query** — Power BI connects to CSV exports of the summary tables rather than a live Snowflake connection, after MFA/connector issues on the trial account. A live connection (key-pair auth, already configured — see `02_auth_keypair.sql`) is the recommended production setup.
- **Single-pass deduplication** — 12 duplicate product codes were resolved by keeping the most "complete" row, a simple and defensible approach for a POC rather than a full survivorship model.

## Next Steps

- Move Power BI to a live Snowflake connection using the key-pair auth already configured.
- Adopt Open Food Facts' daily delta files for incremental loading instead of full reloads; consider dbt for transformation orchestration.
- Add automated data-quality tests (null rates, duplicate keys, category coverage).
- Extend the same pipeline pattern to other focus areas (allergens, sourcing/trade risk, nutrition).
