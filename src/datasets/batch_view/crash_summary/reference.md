# Crash Summary Reference

<!-- toc -->

# Introduction

{{#include ./intro.md}}

# Data Reference

## Example Queries

Here is an example query to get the total number of main crashes by `gfx_compositor`:

```sql
select gfx_compositor, count(*)
from crash_summary
where application = 'Firefox'
and (payload.processType IS NULL OR payload.processType = 'main')
group by gfx_compositor
```

## Sampling

`CrashSummary` contains one record for every
[crash ping](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/crash-ping.html)
submitted by Firefox.

## Scheduling

This dataset is updated daily, shortly after midnight UTC.
The job is scheduled on
[telemetry-airflow](https://github.com/mozilla/telemetry-airflow).
The DAG is [here](https://github.com/mozilla/telemetry-airflow/blob/master/dags/crash_summary.py).

## Schema

```
root
 |-- client_id: string (nullable = true)
 |-- normalized_channel: string (nullable = true)
 |-- build_version: string (nullable = true)
 |-- build_id: string (nullable = true)
 |-- channel: string (nullable = true)
 |-- crash_time: string (nullable = true)
 |-- application: string (nullable = true)
 |-- os_name: string (nullable = true)
 |-- os_version: string (nullable = true)
 |-- architecture: string (nullable = true)
 |-- country: string (nullable = true)
 |-- experiment_id: string (nullable = true)
 |-- experiment_branch: string (nullable = true)
 |-- experiments: map (nullable = true)
 |    |-- key: string
 |    |-- value: string (valueContainsNull = true)
 |-- e10s_enabled: boolean (nullable = true)
 |-- gfx_compositor: string (nullable = true)
 |-- profile_created: integer (nullable = true)
 |-- payload: struct (nullable = true)
 |    |-- crashDate: string (nullable = true)
 |    |-- processType: string (nullable = true)
 |    |-- hasCrashEnvironment: boolean (nullable = true)
 |    |-- metadata: map (nullable = true)
 |    |    |-- key: string
 |    |    |-- value: string (valueContainsNull = true)
 |    |-- version: integer (nullable = true)
 |-- submission_date: string (nullable = true)
```

For more detail on where these fields come from in the
[raw data](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/crash-ping.html),
please look at the case classes
[in the `CrashSummaryView` code](https://github.com/mozilla/telemetry-batch-view/blob/master/src/main/scala/com/mozilla/telemetry/views/CrashSummaryView.scala).

