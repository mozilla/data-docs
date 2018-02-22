# Search Clients Daily

<!-- toc -->

# Introduction

{% include "./intro.md" %}

# Data Reference

## Example Queries

[This query](https://sql.telemetry.mozilla.org/queries/51141/source)
calculates searches per `normalized_channel` for US clients on an arbitrary day.
If you have trouble viewing this query,
it's likely you don't have the proper permissions.
For more details see the [search data documentation].


## Scheduling

This dataset is not currently scheduled.

## Schema

As of 2018-02-13, the current version of `search_clients_daily` is `v1`,
and has a schema as follows.
It's backfilled through 2016-06-07

```
root 
 |-- client_id: string (nullable = true) 
 |-- submission_date: string (nullable = true) 
 |-- engine: string (nullable = true) 
 |-- source: string (nullable = true) 
 |-- country: string (nullable = true) 
 |-- app_version: string (nullable = true) 
 |-- distribution_id: string (nullable = true) 
 |-- locale: string (nullable = true) 
 |-- search_cohort: string (nullable = true) 
 |-- addon_version: string (nullable = true) 
 |-- os: string (nullable = true) 
 |-- channel: string (nullable = true) 
 |-- profile_creation_date: long (nullable = true) 
 |-- default_search_engine: string (nullable = true) 
 |-- default_search_engine_data_load_path: string (nullable = true) 
 |-- default_search_engine_data_submission_url: string (nullable = true) 
 |-- sessions_started_on_this_day: long (nullable = true) 
 |-- profile_age_in_days: integer (nullable = true) 
 |-- subsession_hours_sum: double (nullable = true) 
 |-- active_addons_count_mean: double (nullable = true) 
 |-- max_concurrent_tab_count_max: integer (nullable = true) 
 |-- tab_open_event_count_sum: long (nullable = true) 
 |-- active_hours_sum: double (nullable = true) 
 |-- tagged-sap: long (nullable = true) 
 |-- tagged-follow-on: long (nullable = true) 
 |-- sap: long (nullable = true)
```

# Code Reference

The `search_clients_daily` job is 
[defined in python_mozetl](https://github.com/mozilla/python_mozetl/blob/master/mozetl/search/aggregates.py)


[search data documentation]: /datasets/search.md
