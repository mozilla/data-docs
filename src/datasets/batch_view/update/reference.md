# Update

<!-- toc -->

# Introduction

{{#include ./intro.md}}

# Data Reference

## Schema

As of 2017-09-07, the current version of the `telemetry_update_parquet` dataset is `v1`, and has a schema as follows:

```
root
 |-- id: string (nullable = true)
 |-- client_id: string (nullable = true)
 |-- metadata: struct (nullable = true)
 |    |-- timestamp: long (nullable = true)
 |    |-- date: string (nullable = true)
 |    |-- normalized_channel: string (nullable = true)
 |    |-- geo_country: string (nullable = true)
 |    |-- geo_city: string (nullable = true)
 |    |-- creation_timestamp: long (nullable = true)
 |    |-- x_ping_sender_version: string (nullable = true)
 |-- application: struct (nullable = true)
 |    |-- displayVersion: string (nullable = true)
 |-- environment: struct (nullable = true)
 |    |-- build: struct (nullable = true)
 |    |    |-- application_name: string (nullable = true)
 |    |    |-- architecture: string (nullable = true)
 |    |    |-- version: string (nullable = true)
 |    |    |-- build_id: string (nullable = true)
 |    |    |-- vendor: string (nullable = true)
 |    |    |-- hotfix_version: string (nullable = true)
 |    |-- partner: struct (nullable = true)
 |    |    |-- distribution_id: string (nullable = true)
 |    |    |-- distribution_version: string (nullable = true)
 |    |    |-- partner_id: string (nullable = true)
 |    |    |-- distributor: string (nullable = true)
 |    |    |-- distributor_channel: string (nullable = true)
 |    |    |-- partner_names: array (nullable = true)
 |    |    |    |-- element: string (containsNull = true)
 |    |-- settings: struct (nullable = true)
 |    |    |-- telemetry_enabled: boolean (nullable = true)
 |    |    |-- locale: string (nullable = true)
 |    |    |-- update: struct (nullable = true)
 |    |    |    |-- channel: string (nullable = true)
 |    |    |    |-- enabled: boolean (nullable = true)
 |    |    |    |-- auto_download: boolean (nullable = true)
 |    |-- system: struct (nullable = true)
 |    |    |-- os: struct (nullable = true)
 |    |    |    |-- name: string (nullable = true)
 |    |    |    |-- version: string (nullable = true)
 |    |    |    |-- locale: string (nullable = true)
 |    |-- profile: struct (nullable = true)
 |    |    |-- creation_date: long (nullable = true)
 |-- payload: struct (nullable = true)
 |    |-- reason: string (nullable = true)
 |    |-- target_channel: string (nullable = true)
 |    |-- target_version: string (nullable = true)
 |    |-- target_build_id: string (nullable = true)
 |    |-- target_display_version: string (nullable = true)
 |    |-- previous_channel: string (nullable = true)
 |    |-- previous_version: string (nullable = true)
 |    |-- previous_build_id: string (nullable = true)
 |-- submission_date_s3: string (nullable = true)
```

For more detail on the raw ping these fields come from, see the
[raw data](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/update-ping.html).
