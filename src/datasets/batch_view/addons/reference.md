# Addons Datasets

<!-- toc -->

# Introduction

{{#include ./intro.md}}

# Data Reference

## Example Queries

## Sampling

It contains one or more records for every
[Main Summary](../main_summary/reference.md)
record that contains a non-null value for `client_id`.
Each Addons record contains info for a single addon,
or if the main ping did not contain any active addons,
there will be a row with nulls for all the addon fields
(to identify `client_id`s/records without any addons).

Like the Main Summary dataset, No attempt is made to de-duplicate submissions by `documentId`, so any analysis that could be affected by duplicate records should take care to remove duplicates using the `documentId` field.

## Scheduling

This dataset is updated daily via the
[telemetry-airflow](https://github.com/mozilla/telemetry-airflow) infrastructure.
The job DAG runs every day after the Main Summary data has been generated.
The DAG is [here](https://github.com/mozilla/telemetry-airflow/blob/master/dags/main_summary.py#L36).

## Schema

As of 2017-03-16, the current version of the `addons` dataset is `v2`,
 and has a schema as follows:
```
root
 |-- document_id: string (nullable = true)
 |-- client_id: string (nullable = true)
 |-- subsession_start_date: string (nullable = true)
 |-- normalized_channel: string (nullable = true)
 |-- addon_id: string (nullable = true)
 |-- blocklisted: boolean (nullable = true)
 |-- name: string (nullable = true)
 |-- user_disabled: boolean (nullable = true)
 |-- app_disabled: boolean (nullable = true)
 |-- version: string (nullable = true)
 |-- scope: integer (nullable = true)
 |-- type: string (nullable = true)
 |-- foreign_install: boolean (nullable = true)
 |-- has_binary_components: boolean (nullable = true)
 |-- install_day: integer (nullable = true)
 |-- update_day: integer (nullable = true)
 |-- signed_state: integer (nullable = true)
 |-- is_system: boolean (nullable = true)
 |-- submission_date_s3: string (nullable = true)
 |-- sample_id: string (nullable = true)
```
For more detail on where these fields come from in the
[raw data](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/environment.html#addons),
please look
[in the `AddonsView` code](https://github.com/mozilla/telemetry-batch-view/blob/master/GRAVEYARD.md#main-summary-clients-daily-and-addons).

The fields are all simple scalar values.
