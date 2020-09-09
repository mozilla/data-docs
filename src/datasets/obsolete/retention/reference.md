# 1 Day Retention

> As of 2019-08-13, this dataset has been deprecated and is no longer
> maintained. See [Bug
> 1571565](https://bugzilla.mozilla.org/show_bug.cgi?id=1571565) for historical
> sources. See the [retention cookbook](../../../cookbooks/retention.md) for
> current best practices.

<!-- toc -->

# Introduction

{{#include ./intro.md}}

# Data Reference

## Example Queries

See the [Example Usage Dashboard][example_usage] for more usages of datasets of
the same shape.

## Scheduling

The job is scheduled on Airflow on a daily basis after `main_summary` is run
for the day. This job requires both `mozetl` and `telemetry-batch-view` as
dependencies.

## Schema

As of 2017-10-10, the current version of `retention` is `v1` and has a schema
as follows:

```
root
 |-- subsession_start: string (nullable = true)
 |-- profile_creation: string (nullable = true)
 |-- days_since_creation: long (nullable = true)
 |-- channel: string (nullable = true)
 |-- app_version: string (nullable = true)
 |-- geo: string (nullable = true)
 |-- distribution_id: string (nullable = true)
 |-- is_funnelcake: boolean (nullable = true)
 |-- source: string (nullable = true)
 |-- medium: string (nullable = true)
 |-- content: string (nullable = true)
 |-- sync_usage: string (nullable = true)
 |-- is_active: boolean (nullable = true)
 |-- hll: binary (nullable = true)
 |-- usage_hours: double (nullable = true)
 |-- sum_squared_usage_hours: double (nullable = true)
 |-- total_uri_count: long (nullable = true)
 |-- unique_domains_count: double (nullable = true)
```

# Code Reference

The ETL script for processing the data before aggregation is found in
[`mozetl.engagement.retention`][mozetl_job]. The aggregate job is found in
[telemetry-batch-view][tbv_job] as the `RetentionView`.

The [runner script][airflow_job] performs all the necessary setup to run on
EMR. This script can be used to perform backfill.

[example_usage]: https://sql.telemetry.mozilla.org/dashboard/firefox-telemetry-retention-dataset-example-usage
[mozetl_job]: https://github.com/mozilla/python_mozetl/blob/ba51f539e5f1218954b7f3536e96f50c57a1b55c/mozetl/engagement/retention/job.py
[tbv_job]: https://github.com/mozilla/telemetry-batch-view/blob/9428b1951545dcd7517a3e72c81e7891a6dfa1fa/src/main/scala/com/mozilla/telemetry/views/RetentionView.scala
[airflow_job]: https://github.com/acmiyaguchi/telemetry-airflow/blob/1b4b11d23cdd1191ed2d2be905f116d7c3c67533/jobs/retention.sh
