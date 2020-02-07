# Search Clients Daily

<!-- toc -->

# Introduction

{{#include ./intro.md}}

# Data Reference

## Example Queries

[This query](https://sql.telemetry.mozilla.org/queries/51141/source)
calculates searches per `normalized_channel` for US clients on an arbitrary day.
If you have trouble viewing this query,
it's likely you don't have the proper permissions.
For more details see the [search data documentation].


## Scheduling

This dataset is scheduled on Airflow
([source](https://github.com/mozilla/telemetry-airflow/blob/9af06204f7073d7fd5b0240db9091b57a7454a74/dags/main_summary.py#L588)).

## Schema

As of 2019-11-27, the current version of `search_clients_daily` is `v8`,
and has a schema as follows.
It's backfilled through 2016-03-12

```
root
 |-- client_id: string (nullable = true)
 |-- submission_date: date (nullable = true)
 |-- submission_date_s3: date (nullable = true)
 |-- engine: string (nullable = true)
 |-- source: string (nullable = true)
 |-- country: string (nullable = true)
 |-- app_version: string (nullable = true)
 |-- distribution_id: string (nullable = true)
 |-- locale: string (nullable = true)
 |-- search_cohort: string (nullable = true)
 |-- addon_version: string (nullable = true)
 |-- os: string (nullable = true)
 |-- os_version: string (nullable = true)
 |-- channel: string (nullable = true)
 |-- profile_creation_date: long (nullable = true)
 |-- default_search_engine: string (nullable = true)
 |-- default_search_engine_data_load_path: string (nullable = true)
 |-- default_search_engine_data_submission_url: string (nullable = true)
 |-- default_private_search_engine: string (nullable = true)
 |-- default_private_search_engine_data_load_path: string (nullable = true)
 |-- default_private_search_engine_data_submission_url: string (nullable = true)
 |-- sample_id: long (nullable = true)
 |-- sessions_started_on_this_day: long (nullable = true)
 |-- profile_age_in_days: integer (nullable = true)
 |-- subsession_hours_sum: double (nullable = true)
 |-- active_addons_count_mean: double (nullable = true)
 |-- max_concurrent_tab_count_max: integer (nullable = true)
 |-- tab_open_event_count_sum: long (nullable = true)
 |-- active_hours_sum: double (nullable = true)
 |-- total_uri_count: long (nullable = true)
 |-- tagged-sap: long (nullable = true)
 |-- tagged-follow-on: long (nullable = true)
 |-- sap: long (nullable = true)
 |-- tagged_sap: long (nullable = true)
 |-- tagged_follow_on: long (nullable = true)
 |-- organic: long (nullable = true)
 |-- search_with_ads: long (nullable = true)
 |-- ad_click: long (nullable = true)
 |-- unknown: long (nullable = true)
```

# Code Reference

The `search_clients_daily` job is
[defined in `bigquery-etl`](https://github.com/mozilla/bigquery-etl/blob/master/sql/search_derived/search_clients_daily_v8/query.sql)


[search data documentation]: ../../search.md
