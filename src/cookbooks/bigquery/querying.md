# Querying BigQuery Tables

## Table of Contents

<!-- toc -->

## Projects, Datasets, and Tables in BigQuery

In GCP a [project](https://cloud.google.com/resource-manager/docs/creating-managing-projects) enables you to organize cloud resources. Mozilla uses multiple
projects to maintain BigQuery [datasets](https://cloud.google.com/bigquery/docs/datasets-intro).

> **Note**: The term _dataset_ has historically been used to describe a set of records that all follow the same schema, but this idea corresponds to a _table_
> in BigQuery. In BigQuery terminology,
> datasets represent top-level containers that are used to organize and
> control access to tables and views.

### Caveats

- The date partition field (e.g., `submission_date_s3`, `submission_date`) is mostly used as a partitioning column.
  However, it has changed from using a `YYYYMMDD` string form to a `DATE` type that uses string literals in the more standards-friendly `YYYY-MM-DD` form.
- Unqualified queries can become very costly very easily. Restrictions have been placed on large tables to avoid accidental querying "all data for all time". You must use the date partition fields for large tables (like `main_summary` or `clients_daily`).
- Read the [_Query Optimization Cookbook_](./optimization.md) that includes recommendations on how to reduce cost and improve query performance.
- STMO BigQuery data sources have a 10 TB data-scanned limit for each query. [Let us know](../../concepts/getting_help.md) if this becomes an issue.
- There is not any native map support available in BigQuery. Instead, structs are used with fields [key, value]. Convenience functions are available to access the like key-value maps, as described [below](#accessing-map-like-fields).

### Projects with BigQuery datasets

| Project                         | Dataset                 | Purpose                                                                                                                                                                                                                        |
| ------------------------------- | ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `mozdata`                       |                         | The primary home for user analysis; it has a short name that is easy to type and is filled with views that reference underlying tables in `moz-fx-data-shared-prod`; the default project for STMO and Looker |
|                                 | `analysis`              | User-generated tables for analysis; please prefix tables with your username |
|                                 | `tmp`                   | User-generated tables for ephemeral analysis results; tables created here are automatically deleted after 7 days. |
|                                 | `telemetry`             | Views into legacy desktop telemetry pings and many derived tables; see _user-facing (unsuffixed) datasets_ below                                                                                                               |
|                                 | `<namespace>`           | See _user-facing (unsuffixed) datasets_ below                                                                                                                                                                                  |
|                                 | `search`                | Search data imported from parquet (_restricted_)                                                                                                                                                                               |
|                                 | `static`                | Static tables, often useful for data-enriching joins                                                                                                                                                                           |
|                                 | `udf`                   | Internal persistent user-defined functions defined in SQL; see [Using UDFs](#using-udfs)                                                                                                                                       |
|                                 | `udf_js`                | Internal user-defined functions defined in JavaScript; see [Using UDFs](#using-udfs)                                                                                                                                 |
| `mozfun`                        |                         | The primary home for user-defined functions; see [Using UDFs](#using-udfs)        |
| `moz-fx-data-bq-<team-name>`    |                         | Some teams have specialized needs and can be provisioned a team-specific project |
| `moz-fx-data-shared-prod`       |                         | All production data including full pings and derived datasets defined in [bigquery-etl](https://github.com/mozilla/bigquery-etl)                                      |
|                                 | `<namespace>_live`      | See _live datasets_ below                                                                                                                                                                                                      |
|                                 | `<namespace>_stable`    | See _stable datasets_ below                                                                                                                                                                                                    |
|                                 | `<namespace>_derived`   | See _derived datasets_ below                                                                                                                                                                                                   |
|                                 | `<product>_external`    | Tables that reference external resources; these may be native BigQuery tables populated by a job that queries an third-party API, or they may be [federated data sources](https://cloud.google.com/bigquery/external-data-sources) that pull data from other GCP services like GCS at query time. |
|                                 | `backfill`              | Temporary staging area for back-fills                                                                                                                                                                                          |
|                                 | `blpadi`                | Blocklist ping derived data(_restricted_)                                                                                                                                                                                      |
|                                 | `payload_bytes_raw`     | Raw JSON payloads as received from clients, used for reprocessing scenarios, a.k.a. "landfill" (_restricted_)                                                                                                                  |
|                                 | `payload_bytes_decoded` | `gzip`-compressed decoded JSON payloads, used for reprocessing scenarios                                                                                                                                                       |
|                                 | `payload_bytes_error`   | `gzip`-compressed JSON payloads that were rejected in some phase of the pipeline; particularly useful for investigating schema validation errors                                                                               |
|                                 | `tmp`                   | Temporary staging area for parquet data loads                                                                                                                                                                                  |
|                                 | `validation`            | Temporary staging area for validation                                                                                                                                                                                          |
| `moz-fx-data-derived-datasets`  |                         | Legacy project that was a precursor to `mozdata`                                                          |
| `moz-fx-data-shar-nonprod-efed` |                         | Non-production data produced by stage ingestion infrastructure                                                                                                                                                                 |

### Table Layout and Naming

Under the single `moz-fx-data-shared-prod` project,
each document namespace (corresponding to folders underneath the [schemas directory of `mozilla-pipeline-schemas`](https://github.com/mozilla-services/mozilla-pipeline-schemas/tree/master/schemas)) has four BigQuery datasets provisioned with the following properties:

- _Live datasets_ (`telemetry_live`, `activity_stream_live`, etc.) contain live ping tables (see definitions of table types in the next paragraph)
- _Stable datasets_ (`telemetry_stable`, `activity_stream_stable`, etc.) contain historical ping tables
- _Derived datasets_ (`telemetry_derived`, `activity_stream_derived`, etc.) contain derived tables, primarily populated via nightly queries defined in [BigQuery ETL](https://github.com/mozilla/bigquery-etl) and managed by Airflow
- _User-facing (unsuffixed) datasets_ (`telemetry`, `activity_stream`, etc.) contain user-facing views on top of the tables in the corresponding stable and derived datasets.

The table and view types referenced above are defined as follows:

- _Live ping tables_ are the final destination for the [telemetry ingestion pipeline](https://mozilla.github.io/gcp-ingestion/). Dataflow jobs process incoming ping payloads from clients, batch them together by document type, and load the results to these tables approximately every five minutes, although a few document types are opted in to a more expensive streaming path that makes records available in BigQuery within seconds of ingestion. These tables are partitioned by date according to `submission_timestamp` and are also clustered on that same field, so it is possible to make efficient queries over short windows of recent data such as the last hour. They have a rolling expiration period of 30 days, but that window may be shortened in the future. Analyses should only use these tables if they need results for the current (partial) day.
- _Historical ping tables_ have exactly the same schema as their corresponding live ping tables, but they are populated only once per day via an Airflow job and have a 25 month retention period. These tables are superior to the live ping tables for historical analysis because they never contain partial days, they have additional deduplication applied, and they are clustered on `sample_id`, allowing efficient queries on a 1% sample of clients. It is guaranteed that `document_id` is distinct within each UTC day of each historical ping table, but it is still possible for a document to appear multiple times if a client sends the same payload across multiple days. Note that this requirement is relaxed for older telemetry ping data that was backfilled from AWS; approximately 0.5% of documents are duplicated in `telemetry.main` and other historical ping tables for 2019-04-30 and earlier dates.
- _Derived tables_ are populated by nightly [Airflow](https://workflow.telemetry.mozilla.org/home) jobs and are considered an implementation detail; their structure may change at any time at the discretion of the data platform team to allow refactoring or efficiency improvements.
- _User-facing views_ are the schema objects that users are primarily expected to use in analyses. Many of these views correspond directly to an underlying historical ping table or derived table, but they provide the flexibility to hide deprecated columns or present additional calculated columns to users. These views are the schema contract with users and they should not change in backwards-incompatible ways without a version increase or an announcement to users about a breaking change.

Spark and other applications relying on the BigQuery Storage API for data access need to reference derived tables or historical ping tables directly rather than user-facing views. Unless the query result is relatively large, we recommend instead that users run a query on top of user-facing views with the output saved in a destination table, which can then be accessed from Spark.

### Structure of Ping Tables in BigQuery

Unlike with the previous AWS-based data infrastructure, we don't have different mechanisms for accessing entire pings vs. "summary" tables. As such, there are no longer special libraries or infrastructure necessary for accessing full pings, rather each document type maps to a user-facing view that can be queried in STMO. For example:

- "main" pings are accessible from view `telemetry.main` ([see docs for faster-to-query tables](../../datasets/main_ping_tables.md))
- "crash" pings are accessible from view `telemetry.crash`
- "baseline" pings for the release version of Firefox for Android (Fenix) are accessible from view `org_mozilla_firefox.baseline`

All fields in the incoming pings are accessible in these views, and (where possible) match the nested data structures of the original JSON. Field names are converted from `camelCase` form to `snake_case` for consistency and SQL compatibility.

Any fields not present in the ping schemas are present in an `additional_properties` field containing leftover JSON. BigQuery provides [functions for parsing and manipulating JSON data via SQL](https://cloud.google.com/bigquery/docs/reference/standard-sql/json_functions).

Later in this document, we demonstrate the use of a few Mozilla-specific
functions that we have defined to allow ergonomic querying of
[map-like fields](#accessing-map-like-fields) (which are represented as arrays of structs in BigQuery) and
[histograms](#accessing-histograms) (which are encoded as raw JSON strings).

## Writing Queries

To query a BigQuery table you will need to specify the dataset and table name. It is good practice to specify the project however depending on which project the query
originates from this is optional.

```sql
SELECT
    col1,
    col2
FROM
    `project.dataset.table`
WHERE
    -- data_partition_field will vary based on table
    date_partition_field >= DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH)
```

An example query from [Clients Last Seen Reference](../../datasets/bigquery/clients_last_seen/reference.md)

```sql
SELECT
    submission_date,
    os,
    COUNT(*) AS count
FROM
    mozdata.telemetry.clients_last_seen
WHERE
    submission_date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 WEEK)
    AND days_since_seen = 0
GROUP BY
    submission_date,
    os
HAVING
    count > 10 -- remove outliers
    AND lower(os) NOT LIKE '%windows%'
ORDER BY
    os,
    submission_date DESC
```

Check out the [BigQuery Standard SQL Functions & Operators](https://cloud.google.com/bigquery/docs/reference/standard-sql/functions-and-operators) for detailed documentation.

### Writing query results to a permanent table

You can write query results to a BigQuery table you have access via [GCP BigQuery Console](access.md#gcp-bigquery-console) or [GCP BigQuery API Access](access.md#gcp-bigquery-api-access)

- For temporary experiments use `mozdata.tmp` (it will automatically be deleted after 7 days). For longer-lived results, use the `mozdata.analysis` dataset.
  - Prefix your table with your username. If your username is `username@mozilla.com` create a table with `username_my_table`.
- See [Writing query results](https://cloud.google.com/bigquery/docs/writing-results) documentation for detailed steps.

### Writing results to GCS (object store)

If a BigQuery table is not a suitable destination for your analysis results,
we also have a GCS bucket available for storing analysis results. It is usually
Spark jobs that will need to do this.

- Use bucket `gs://mozdata-analysis/`
  - Prefix object paths with your username. If your username is `username@mozilla.com`, you might store a file to `gs://mozdata-analysis/username/myresults.json`.

## Creating a View

You can create views in BigQuery if you have access via [GCP BigQuery Console](access.md#gcp-bigquery-console) or [GCP BigQuery API Access](access.md#gcp-bigquery-api-access).

- Use the `mozdata.analysis` dataset.
  - Prefix your view with your username. If your username is `username@mozilla.com` create a table with `username_my_view`.
- See [Creating Views](https://cloud.google.com/bigquery/docs/views) documentation for detailed steps.

## Using UDFs

BigQuery offers [user-defined functions](https://cloud.google.com/bigquery/docs/reference/standard-sql/user-defined-functions) (UDFs) that can be defined in SQL or JavaScript as part of a query or as a persistent function stored in a dataset. We have defined a suite of public persistent functions to enable transformations specific to our data formats, available in [`mozfun`](https://mozilla.github.io/bigquery-etl/). UDFs used internally in `moz-fx-data-shared-prod` are available in datasets `udf` (for functions defined in SQL) and `udf_js` (for functions defined in JavaScript). Note that JavaScript functions are potentially much slower than those defined in SQL, so use functions in `udf_js` with some caution, likely only after performing aggregation in your query.

We document a few of the most broadly useful UDFs below, but you can see the full list of `mozfun` UDFs in [https://mozilla.github.io/bigquery-etl](https://mozilla.github.io/bigquery-etl/) and or UDFs with source code used within `moz-fx-data-shared-prod` in [`bigquery-etl/sql/moz-fx-data-shared-prod/udf`](https://github.com/mozilla/bigquery-etl/tree/master/sql/moz-fx-data-shared-prod/udf) and [`bigquery-etl/sql/moz-fx-data-shared-prod/udf_js`](https://github.com/mozilla/bigquery-etl/tree/master/sql/moz-fx-data-shared-prod/udf_js).

## Accessing map-like fields

BigQuery currently lacks native map support and our workaround is to use a STRUCT type with fields named [key, value]. We've created a UDF that provides key-based access with the signature: `mozfun.map.get_key(<struct>, <key>)`. The example below generates a count per `reason` key in the `event_map_values` field in the telemetry events table for Normandy unenrollment events from yesterday.

```sql
SELECT mozfun.map.get_key(event_map_values, 'reason') AS reason,
       COUNT(*) AS EVENTS
FROM telemetry.events
WHERE submission_date = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
  AND event_category='normandy'
  AND event_method='unenroll'
GROUP BY 1
ORDER BY 2 DESC
```

## Accessing histograms

We considered many potential ways to represent histograms as BigQuery fields
and found the most efficient encoding was actually to leave them as raw JSON
strings. To make these strings easier to use for analysis, you can convert them
into nested structures using `mozfun.hist.extract`:

```sql
WITH
  extracted AS (
  SELECT
    submission_timestamp,
    mozfun.hist.extract(payload.histograms.a11y_consumers) AS a11y_consumers
  FROM
    telemetry.main )
  --
SELECT
  a11y_consumers.bucket_count,
  a11y_consumers.sum,
  a11y_consumers.range[ORDINAL(1)] AS range_low,
  udf.get_key(a11y_consumers.values, 11) AS value_11
FROM
  extracted
WHERE
  a11y_consumers.bucket_count IS NOT NULL
  AND DATE(submission_timestamp) = "2019-08-09"
LIMIT
  10
```
