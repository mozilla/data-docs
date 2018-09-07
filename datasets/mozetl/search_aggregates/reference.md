# Search Aggregates

<!-- toc -->

# Introduction

{% include "./intro.md" %}

# Data Reference

## Example Queries

[This query](https://sql.telemetry.mozilla.org/queries/51140/source)
calculates daily US searches.
If you have trouble viewing this query,
it's likely you don't have the proper permissions.
For more details see the [search data documentation].


## Scheduling

This job is
[scheduled on airflow](https://github.com/mozilla/telemetry-airflow/blob/master/dags/main_summary.py#L135)
to run daily.

## Schema

As of 2018-02-13,
the current version of `search_aggregates` is `v3`,
and has a schema as follows.
The dataset is backfilled through 2016-06-06

```
root
 |-- country: string (nullable = true)
 |-- engine: string (nullable = true)
 |-- source: string (nullable = true)
 |-- submission_date: string (nullable = true)
 |-- app_version: string (nullable = true)
 |-- distribution_id: string (nullable = true)
 |-- locale: string (nullable = true)
 |-- search_cohort: string (nullable = true)
 |-- addon_version: string (nullable = true)
 |-- tagged-sap: long (nullable = true)
 |-- tagged-follow-on: long (nullable = true)
 |-- sap: long (nullable = true)
```

# Code Reference

The `search_aggregates` job is
[defined in `python_mozetl`](https://github.com/mozilla/python_mozetl/blob/master/mozetl/search/aggregates.py)


[search data documentation]: ../../search.md
