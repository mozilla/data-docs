# Sync Summary Reference

<!-- toc -->

# Introduction

{{#include ./intro.md}}

# Data Reference

## Example Queries

Work in progress.
Work is being tracked
[here](https://bugzilla.mozilla.org/show_bug.cgi?id=1364171)

## Sampling

Work in progress.
Work is being tracked
[here](https://bugzilla.mozilla.org/show_bug.cgi?id=1364171)

## Scheduling

This dataset is updated daily, shortly after midnight UTC.
The job is scheduled on [Airflow](https://github.com/mozilla/telemetry-airflow).
The DAG is [here](https://github.com/mozilla/telemetry-airflow/blob/master/dags/sync_view.py).

## Schema

```
root
 |-- app_build_id: string (nullable = true)
 |-- app_display_version: string (nullable = true)
 |-- app_name: string (nullable = true)
 |-- app_version: string (nullable = true)
 |-- app_channel: string (nullable = true)
 |-- uid: string
 |-- device_id: string (nullable = true)
 |-- when: integer
 |-- took: integer
 |-- why: string (nullable = true)
 |-- failure_reason: struct (nullable = true)
 |    |-- name: string
 |    |-- value: string (nullable = true)
 |-- status: struct (nullable = true)
 |    |-- sync: string (nullable = true)
 |    |-- status: string (nullable = true)
 |-- devices: array (nullable = true)
 |    |-- element: struct (containsNull = false)
 |    |    |-- id: string
 |    |    |-- os: string
 |    |    |-- version: string
 |-- engines: array (nullable = true)
 |    |-- element: struct (containsNull = false)
 |    |    |-- name: string
 |    |    |-- took: integer
 |    |    |-- status: string (nullable = true)
 |    |    |-- failure_reason: struct (nullable = true)
 |    |    |    |-- name: string
 |    |    |    |-- value: string (nullable = true)
 |    |    |-- incoming: struct (nullable = true)
 |    |    |    |-- applied: integer
 |    |    |    |-- failed: integer
 |    |    |    |-- new_failed: integer
 |    |    |    |-- reconciled: integer
 |    |    |-- outgoing: array (nullable = true)
 |    |    |    |-- element: struct (containsNull = false)
 |    |    |    |    |-- sent: integer
 |    |    |    |    |-- failed: integer
 |    |    |-- validation: struct (containsNull = false)
 |    |    |    |-- version: integer
 |    |    |    |-- checked: integer
 |    |    |    |-- took: integer
 |    |    |    |-- failure_reason: struct (nullable = true)
 |    |    |    |    |-- name: string
 |    |    |    |    |-- value: string (nullable = true)
 |    |    |    |-- problems: array (nullable = true)
 |    |    |    |    |-- element: struct (containsNull = false)
 |    |    |    |    |    |-- name: string
 |    |    |    |    |    |-- count: integer
```
