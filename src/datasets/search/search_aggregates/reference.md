# Search Aggregates

<!-- toc -->

# Introduction

{{#include ./intro.md}}

# Data Reference

## Example Queries

### Daily US sap searches

```sql
SELECT
    submission_date,
    SUM(SAP) AS search_counts
FROM search.search_aggregates
WHERE
    country = 'US'
    AND submission_date BETWEEN '2019-01-01' AND '2019-01-07'
GROUP BY submission_date
ORDER BY submission_date
```

[link to query on STMO](https://sql.telemetry.mozilla.org/queries/51140/source)

## Scheduling

This job is
[scheduled on airflow](https://github.com/mozilla/bigquery-etl/blob/ad84a15d580333b41d36cfe8331e51238f3bafa1/dags/bqetl_search.py#L40)
to run daily.

## Schema

As of 2021-04-29,
the current version of `search_aggregates` is `v8`,
and has a schema as follows.
The dataset is backfilled through 2016-03-11.

```
root
 |-- submission_date: date (nullable = true)
 |-- submission_date_s3: date (nullable = true)
 |-- country: string (nullable = true)
 |-- engine: string (nullable = true)
 |-- normalized_engine: string (nullable = true)
 |-- source: string (nullable = true)
 |-- app_version: string (nullable = true)
 |-- distribution_id: string (nullable = true)
 |-- locale: string (nullable = true)
 |-- search_cohort: string (nullable = true)
 |-- addon_version: string (nullable = true)
 |-- tagged_sap: long (nullable = true)
 |-- tagged_follow_on: long (nullable = true)
 |-- sap: long (nullable = true)
 |-- organic: long (nullable = true)
 |-- search_with_ads: long (nullable = true)
 |-- search_with_ads_organic: long (nullable = true)
 |-- ad_click: long (nullable = true)
 |-- ad_click_organic: long (nullable = true)
 |-- unknown: long (nullable = true)
 |-- client_count: long (nullable = true)
 |-- default_search_engine: string (nullable = true)
 |-- default_private_search_engine: string (nullable = true)
 |-- os: string (nullable = true)
 |-- os_version: string (nullable = true)
 |-- is_default_browser: boolean (nullable = true)
```

# Code Reference

The `search_aggregates` job is
[defined in `bigquery-etl`](https://github.com/mozilla/bigquery-etl/blob/master/sql/moz-fx-data-shared-prod/search_derived/search_aggregates_v8/query.sql)

[search data documentation]: ../../search.md
