# Search Revenue Levers Datasets

<!-- toc -->

# Introduction

The `search_revenue_levers` datasets isolate key components of the search monetization funnel, e.g. revenue levers, to more effectively support search revenue analyses. The suite of `search_revenue_levers` datasets are as follows:

- `search_revenue_levers_daily`: provides daily search metrics at \*_minimum country granularity_ (e.g. SAP by device, partner, channel, and specific country)
- `search_revenue_levers_monthly`: provides monthly search and revenue metrics at _search funnel granularity_ (e.g. SAP by device, partner, and US vs Rest of World)

**[Revenue data access permissions](https://mozilla-hub.atlassian.net/wiki/spaces/DATA/pages/747176558/Search+Revenue+Documentation#Revenue-Data-Access-Policies) of category 2 or higher are required to access `search_revenue_levers_monthly`.**

For most search and revenue analyses, we recommend using `search_revenue_levers_monthly`. By aggregating to the search monetization funnel granularity, this table is used to support the Monthly and Quarterly Business Reviews. Most ad hoc search revenue analyses should align with this internal standard of reporting.

That being said, there are cases when Mozillians require more granularity for search analyses. By aggregating to the daily reporting granularity, `search_revenue_levers_daily` is designed to support forecasting and deep dives into performance by search partner. Revenue is not included in `search_revenue_levers_daily` because search revenue is reported monthly, not daily. 

In practice, Mozillians focused on search-only analyses may prefer the other existing search tables: [`search_aggregates`](https://docs.telemetry.mozilla.org/datasets/search/search_aggregates/reference) (fastest to query!) or [`search_clients_engines_sources_daily`](https://docs.telemetry.mozilla.org/datasets/search/search_clients_engines_sources_daily/reference) (most data possible!).

## Contents

The differences between the aggregation structures are summarized as follows:

| Column Name     | `search_revenue_levers_daily`         | `search_revenue_levers_monthly` |
| --------------- | ------------------------------ | ------------------------------- |
| device          | `desktop`, `mobile`            | `desktop`, `mobile`             |
| partner         | `Google`, `Bing`, `DuckDuckGo` | `Google`, `Bing`, `DuckDuckGo`  |
| channel         | `NULL`, `personal`, `ESR`      | column does not exist           |
| country         | `US`, `DE`, `FR`, ...          | All partners: `US`, `ROW`       |
| submission_date | minimum aggregation: daily     | minimum aggregation: monthly    |

There are 14 possible revenue levers measures available:

- 3 [daily active users metrics](https://mozilla-hub.atlassian.net/wiki/spaces/DATA/pages/747176558/Search+Revenue+Documentation#Search-DAU): `Eligible Markets DAU`, `Default Engine DAU`, `Search-Engaged DAU`
- 9 [search engagement metrics](https://mozilla.cloud.looker.com/dashboards/314): `SAP`, `Tagged SAP`, `Tagged Follow On`, `Monetizable SAP`, `Search with Ads`, `Ad Click`, `Organic Search`, `Organic Search with Ads`, `Organic Ad Click`
- 2 revenue metrics (monthly tables only): `Revenue paid to Mozilla`, `Revenue per Ad Click`

# Data Reference

## Example Queries

### Daily Google desktop SAP search from US vs. DE

[`Search Revenue Levers Daily in Looker`](https://mozilla.cloud.looker.com/x/3VYWJPqOyTTHkzMi36T64p)

```sql
SELECT
    submission_date,
    COALESCE(SUM(sap), 0) AS sap
FROM `mozdata.search.search_revenue_levers_daily`
WHERE country IN ('DE', 'US') AND device = 'desktop' AND partner = 'Google' AND submission_date >= '2024-01-01'
GROUP BY
    1
```

### Monthly Google desktop SAP search & revenue from US vs. ROW

[`Search Revenue Levers Monthly in Looker`](https://mozilla.cloud.looker.com/x/EAhpcf5bMdWjEO1007me6y)

```sql
SELECT
    country,
    submission_month,
    COALESCE(SUM(sap), 0) AS sap,
    COALESCE(SUM(revenue), 0) AS revenue
FROM `mozdata.revenue.search_revenue_levers_monthly`
WHERE device = 'desktop' AND partner_name = 'Google' AND submission_month >= "2023-01-01"
GROUP BY
    1,
    2
```

## Scheduling

- `search_revenue_levers_daily`: This job is
  [scheduled on airflow](https://workflow.telemetry.mozilla.org/dags/bqetl_search_dashboard/grid?search=bqetl_search_dashboard)
  to run daily.
- `search_revenue_levers_monthly_detail` and `search_revenue_levers_monthly`: These jobs are
  [scheduled on airflow](https://workflow.telemetry.mozilla.org/dags/private_bqetl_revenue/grid?search=private_bqetl_revenue)
  to run daily. However, the most recent month does not populate until the calendar month is completed.

## Schema

### `search_revenue_levers_daily`

As of 2024-05-25,
the current version of `search_revenue_levers_daily` is `v1` and has a schema as follows. The dataset is backfilled through 2018-01-01.

```
root
 |-- submission_date: date (nullable = true)
 |-- partner: string (nullable = true)
 |-- device: string (nullable = true)
 |-- channel: string (nullable = true)
 |-- country: string (nullable = true)
 |-- dau: integer (nullable = true)
 |-- dau_engaged_w_sap: integer (nullable = true)
 |-- sap: integer (nullable = true)
 |-- tagged_sap: integer (nullable = true)
 |-- tagged_follow_on: integer (nullable = true)
 |-- ad_click: integer (nullable = true)
 |-- search_with_ads: integer (nullable = true)
 |-- organic: integer (nullable = true)
 |-- ad_click_organic: integer (nullable = true)
 |-- search_with_ads_organic: integer (nullable = true)
 |-- monetizable_sap: integer (nullable = true)
 |-- dau_w_engine_as_default: integer (nullable = true)
```

### `search_revenue_levers_monthly`

As of 2024-05-25,
the current version of `search_revenue_levers_monthly` is `v3` and has a schema as follows. The dataset is backfilled through 2018-01-01.

```
root
 |-- device: string (nullable = true)
 |-- country: string (nullable = true)
 |-- partner_name: string (nullable = true)
 |-- submission_month: date (nullable = true)
 |-- dau: integer (nullable = true)
 |-- dau_w_engine_as_default: integer (nullable = true)
 |-- dau_engaged_w_sap: integer (nullable = true)
 |-- sap: integer (nullable = true)
 |-- tagged_sap: integer (nullable = true)
 |-- tagged_follow_on: integer (nullable = true)
 |-- ad_click: integer (nullable = true)
 |-- search_with_ads: integer (nullable = true)
 |-- organic: integer (nullable = true)
 |-- ad_click_organic: integer (nullable = true)
 |-- search_with_ads_organic: integer (nullable = true)
 |-- monetizable_sap: integer (nullable = true)
 |-- revenue: float (nullable = true)
```

# Code Reference

- `search_revenue_levers_daily` is [defined in `bigquery-etl`](https://github.com/mozilla/bigquery-etl/tree/main/sql/moz-fx-data-shared-prod/search_derived/search_revenue_levers_daily_v1).
- `search_revenue_levers_monthly_detail` is TBA.
- `search_revenue_levers_monthly` job is [defined in `private-bigquery-etl`](https://github.com/mozilla/private-bigquery-etl/tree/main/sql/moz-fx-data-shared-prod/revenue_derived/search_revenue_levers_monthly_v3).
