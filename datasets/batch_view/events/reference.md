# Introduction

{% include "./intro.md" %}

# Data Reference

## Example Queries

This is a work in progress.
The work is being tracked
[here](https://bugzilla.mozilla.org/show_bug.cgi?id=1364170).

## Sampling

The events dataset contains one row for each event in a main ping.
This dataset is derived from [main_summary](../main_summary/reference.md)
so any of `main_summary`'s filters affect this dataset as well.

Data is currently available from 2017-01-05 on.

## Scheduling

The events dataset is updated daily, shortly after 
[main_summary](../main_summary/reference.md) is updated.
The job is scheduled on [Airflow](https://github.com/mozilla/telemetry-airflow).
The DAG is [here](https://github.com/mozilla/telemetry-airflow/blob/master/dags/main_summary.py#L63).


## Schema

As of 2017-01-26, the current version of the `events` dataset is `v1`, and has a schema as follows:
```
root
 |-- document_id: string (nullable = true)
 |-- client_id: string (nullable = true)
 |-- normalized_channel: string (nullable = true)
 |-- country: string (nullable = true)
 |-- locale: string (nullable = true)
 |-- app_name: string (nullable = true)
 |-- app_version: string (nullable = true)
 |-- os: string (nullable = true)
 |-- os_version: string (nullable = true)
 |-- subsession_start_date: string (nullable = true)
 |-- subsession_length: long (nullable = true)
 |-- sync_configured: boolean (nullable = true)
 |-- sync_count_desktop: integer (nullable = true)
 |-- sync_count_mobile: integer (nullable = true)
 |-- timestamp: long (nullable = true)
 |-- sample_id: string (nullable = true)
 |-- event_timestamp: long (nullable = false)
 |-- event_category: string (nullable = false)
 |-- event_method: string (nullable = false)
 |-- event_object: string (nullable = false)
 |-- event_string_value: string (nullable = true)
 |-- event_map_values: map (nullable = true)
 |    |-- key: string
 |    |-- value: string
 |-- submission_date_s3: string (nullable = true)
 |-- doc_type: string (nullable = true)
```

Currently, client-side event telemetry is undocumented.
This doc will link to those once they're published.
