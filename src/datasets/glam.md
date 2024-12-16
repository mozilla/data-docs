# GLAM datasets

[GLAM](https://glam.telemetry.mozilla.org) provides aggregated telemetry data in a way that makes it easy to understand how a given probe or metric has been changing over subsequent builds. GLAM aggregations are statistically validated by data scientists to ensure an accurate picture of the observed behavior of telemetry data.

GLAM data is also meant to be explored by itself: GLAM aggregation tables are useful for accessing the data that drives GLAM if more digging is required. Please read through the next section to learn more!

## GLAM final tables (Aggregates dataset)

The following datasets are split in three categories: Firefox Desktop Glean, Firefox Desktop Legacy and Firefox for Android. The tables contain the final aggregated data that powers GLAM.

Each link below points to the dataset's page on [Mozilla's Data Catalog](https://mozilla.acryl.io/) where you can find the dataset's full documentation.

> **_NOTE:_** You may realize that the Aggregates dataset does not have the dimensions you need. For example, the dataset does not contain client-level or day-by-day aggregations.
> If you need to dive deeper or aggregate on a field that isn't included in the Aggregates dataset, you will need to write queries against raw telemetry tables. Should that be your quest we don't want you to start from scratch, this is why GLAM has the `View SQL Query` -> `Telemetry SQL` feature, which gives you a query that already works so you can tweak it. The feature is accessible once you pick a metric or probe. Additionally, you can read other material such as [Visualizing Percentiles of a Main Ping Exponential Histogram](https://docs.telemetry.mozilla.org/cookbooks/main_ping_exponential_histograms.html) in order to learn how to write queries that can give you what you need. Finally, #data-help on slack is a place where all questions related to data are welcome.

### Firefox Desktop (Glean)

- [`moz-fx-data-shared-prod.glam_etl.glam_fog_nightly_aggregates`](<https://mozilla.acryl.io/dataset/urn:li:dataset:(urn:li:dataPlatform:bigquery,moz-fx-data-shared-prod.glam_etl.glam_fog_nightly_aggregates,PROD)/Schema?is_lineage_mode=false&schemaFilter=>)
- [`moz-fx-data-shared-prod.glam_etl.glam_fog_beta_aggregates`](<https://mozilla.acryl.io/dataset/urn:li:dataset:(urn:li:dataPlatform:bigquery,moz-fx-data-shared-prod.glam_etl.glam_fog_beta_aggregates,PROD)/Schema?is_lineage_mode=false&schemaFilter=>)
- [`moz-fx-data-shared-prod.glam_etl.glam_fog_release_aggregates`](<https://mozilla.acryl.io/dataset/urn:li:dataset:(urn:li:dataPlatform:bigquery,moz-fx-data-shared-prod.glam_etl.glam_fog_release_aggregates,PROD)/Schema?is_lineage_mode=false&schemaFilter=>)

### Firefox for Android

- [`moz-fx-data-shared-prod.glam_etl.glam_fenix_nightly_aggregates`](<https://mozilla.acryl.io/dataset/urn:li:dataset:(urn:li:dataPlatform:bigquery,moz-fx-data-shared-prod.glam_etl.glam_fenix_nightly_aggregates,PROD)/Schema?is_lineage_mode=false&schemaFilter=>)
- [`moz-fx-data-shared-prod.glam_etl.glam_fenix_beta_aggregates`](<https://mozilla.acryl.io/dataset/urn:li:dataset:(urn:li:dataPlatform:bigquery,moz-fx-data-shared-prod.glam_etl.glam_fenix_beta_aggregates,PROD)/Schema?is_lineage_mode=false&schemaFilter=>)
- [`moz-fx-data-shared-prod.glam_etl.glam_fenix_release_aggregates`](<https://mozilla.acryl.io/dataset/urn:li:dataset:(urn:li:dataPlatform:bigquery,moz-fx-data-shared-prod.glam_etl.glam_fenix_release_aggregates,PROD)/Schema?is_lineage_mode=false&schemaFilter=>)

### Firefox Desktop (Legacy Telemetry)

- [`moz-fx-data-shared-prod.glam_etl.glam_desktop_nightly_aggregates`](<https://mozilla.acryl.io/dataset/urn:li:dataset:(urn:li:dataPlatform:bigquery,moz-fx-data-shared-prod.glam_etl.glam_desktop_nightly_aggregates,PROD)/Schema?is_lineage_mode=false&schemaFilter=>)
- [`moz-fx-data-shared-prod.glam_etl.glam_desktop_beta_aggregates`](<https://mozilla.acryl.io/dataset/urn:li:dataset:(urn:li:dataPlatform:bigquery,moz-fx-data-shared-prod.glam_etl.glam_desktop_beta_aggregates,PROD)/Schema?is_lineage_mode=false&schemaFilter=>)
- [`moz-fx-data-shared-prod.glam_etl.glam_desktop_release_aggregates`](<https://mozilla.acryl.io/dataset/urn:li:dataset:(urn:li:dataPlatform:bigquery,moz-fx-data-shared-prod.glam_etl.glam_desktop_release_aggregates,PROD)/Schema?is_lineage_mode=false&schemaFilter=>)

In addition to the above tables, the GLAM ETL saves intermediate data transformed after each step. The next section provides an overview of each of the steps with the dataset they produce.

## ETL Pipeline

### Scheduling

Most of the GLAM ETL is scheduled to run daily via Airflow. There are separate ETL pipelines for computing GLAM datasets:

- [Firefox Desktop on Glean](https://workflow.telemetry.mozilla.org/dags/glam_fog/grid)
  - Runs daily
  - Only `daily_` (first "half") jobs for release are processed
- [Firefox Desktop on Glean (release)](https://workflow.telemetry.mozilla.org/dags/glam_fog_release/grid)
  - Runs weekly
  - Second "half" of release ETL is processed
- [Firefox Desktop legacy](https://workflow.telemetry.mozilla.org/dags/glam/grid)
  - Runs daily
- [Firefox for Android](https://workflow.telemetry.mozilla.org/dags/glam_fenix/grid)
  - Runs daily

### Source Code

The ETL code base lives in the [bigquery-etl repository](https://github.com/mozilla/bigquery-etl) and is partially generated. The scripts for generating ETL queries for Firefox Desktop Legacy currently live [here](https://github.com/mozilla/bigquery-etl/tree/main/script/glam) while the GLAM logic for Glean apps lives [here](https://github.com/mozilla/bigquery-etl/tree/main/bigquery_etl/glam).

### Steps

GLAM has a separate set of steps and intermediate tables to aggregate scalar and histogram probes.

#### [`latest_versions`](<https://mozilla.acryl.io/dataset/urn:li:dataset:(urn:li:dataPlatform:bigquery,moz-fx-data-shared-prod.telemetry.latest_versions,PROD)/Schema?is_lineage_mode=false&schemaFilter=>)

- This task pulls in the most recent version for each channel from https://product-details.mozilla.org/1.0/firefox_versions.json

#### [`clients_daily_histogram_aggregates_<process>`](<https://mozilla.acryl.io/dataset/urn:li:dataset:(urn:li:dataPlatform:bigquery,moz-fx-data-shared-prod.telemetry.clients_daily_histogram_aggregates,PROD)/View%20Definition?is_lineage_mode=false>)

- The set of steps that load data to this table are divided into different processes (`parent`, `content`, `gpu`) plus a keyed step for keyed histograms.
- The parent job creates or overwrites the partition corresponding to the `logical_date`, and other processes append data to that partition.
- The process uses `telemetry.buildhub2` to select rows with valid `build_ids`.
- Aggregations are done per client, per day, and include a line for each `submission_date`, `client_id`, `os`, `app_version`, `build_id`, and `channel`.
- The aggregation is done by adding histogram values with the same key for the dimensions listed above.
- The queries for the different steps are generated and run as part of each step.
- The "keyed" step includes all Keyed Histogram probes, regardless of process (`parent`, `content`, `gpu`).
- As a result of the subdivisions in this step, it generates different rows for each process and keyed/non-keyed metric, which will be grouped together in the `clients_histogram_aggregates` step.
- Clients that are on the release channel of the Windows operating system get sampled to reduce the data size.
- The partitions are set to expire after 7 days.

#### [`clients_histogram_aggregates_new`](<https://mozilla.acryl.io/dataset/urn:li:dataset:(urn:li:dataPlatform:bigquery,moz-fx-data-shared-prod.telemetry_derived.clients_histogram_aggregates_new_v1,PROD)/Schema?is_lineage_mode=false&schemaFilter=>)

- This step groups together all rows that have the same `submission_date` and `logical_date` from different processes and keyed and non-keyed sources, and combines them into a single row in the `histogram_aggregates` column. It sums the histogram values with the same key.
- This process is only applied to the last three versions.
- The table is overwritten at every execution of this step.

#### [`clients_histogram_aggregates`](<https://mozilla.acryl.io/dataset/urn:li:dataset:(urn:li:dataPlatform:bigquery,moz-fx-data-shared-prod.telemetry_derived.clients_histogram_aggregates_v2,PROD)/Schema?is_lineage_mode=false&schemaFilter=>)

- This is the most important histogram table in the intermediate dataset, where each row represents a `client_id` with its cumulative sum of the histograms for the last 3 versions of all metrics.
- New entries from `clients_histogram_aggregates_new` are merged with the 3 last versions of previous day’s partition and written to the current day’s partition.
- This table only holds the most recent `submission_date`, which marks the most recent date of data ingestion. A check before running this jobs ensures that the ETL does not skip days. In other words, the ETL only processes date `d` if the last date processed was `d-1`.
- In case of failures in the GLAM ETL this table must be backfilled one day at a time.

#### [`clients_histogram_buckets_counts`](<https://mozilla.acryl.io/dataset/urn:li:dataset:(urn:li:dataPlatform:bigquery,moz-fx-data-shared-prod.telemetry_derived.clients_histogram_bucket_counts_v1,PROD)/Schema?is_lineage_mode=false&schemaFilter=>)

- This process creates wildcards for `os` and `app_build_id`, which are needed for aggregating values across os and build IDs later on.
- It then adds a normalized histogram per client, while keeping a non-normalized histogram.
- Finally, it removes the `client_id` dimension by breaking histograms into key/value pairs and doing the `SUM` all values of the same key for the same metric/os/version/build.

#### [`clients_histogram_probe_counts`](<https://mozilla.acryl.io/dataset/urn:li:dataset:(urn:li:dataPlatform:bigquery,moz-fx-data-shared-prod.telemetry_derived.clients_histogram_probe_counts_v1,PROD)/Schema?is_lineage_mode=false&schemaFilter=>)

- This process uses the `metric_type` information to pick a specific algorithm to build histograms from the broken down buckets from the previous step. Histograms can be `linear`, `exponential` or `custom`.
- It then aggregates metrics per wildcards (`os`, `app_build_id`).
- Finally, it rebuilds histograms using the Dirichlet Distribution, normalized using the number of clients that contributed to that histogram in the `clients_histogram_buckets_counts` step.

---

#### [`clients_daily_scalar_aggregates`](<https://mozilla.acryl.io/dataset/urn:li:dataset:(urn:li:dataPlatform:bigquery,moz-fx-data-shared-prod.telemetry.clients_daily_scalar_aggregates,PROD)/Schema?is_lineage_mode=false&schemaFilter=>)

- The set of steps that load data to this table are divided into non-keyed `scalar`, `keyed_boolean` and `keyed_scalar`. The non-keyed scalar job creates or overwrites the partition corresponding to the `logical_date`, and other processes append data to that partition.
- The process uses `telemetry.buildhub2` to select rows with valid `build_ids`.
- Aggregations are done per client, per day and include a line for each `client`, `os`, `app_version`, `build_id`, and `channel`.
- The queries for the different steps are generated and run as part of each step. All steps include probes regardless of process (`parent`, `content`, `gpu`).
- As a result of the subdivisions in this step, it generates different rows for each keyed/non-keyed, boolean/scalar metric, which will be grouped together in `clients_scalar_aggregates`.
- Clients that are on the release channel of the Windows operating system get sampled to reduce the data size.
- Partitions expire in 7 days.

#### [`clients_scalar_aggregates`](<https://mozilla.acryl.io/dataset/urn:li:dataset:(urn:li:dataPlatform:bigquery,mozdata.telemetry.clients_scalar_aggregates,PROD)/Schema?is_lineage_mode=false&schemaFilter=>)

- This process groups all rows with the same `submission_date` and `logical_date` from `clients_daily_scalar_aggregates` and combines them into a single row in the `scalar_aggregates` column.
- If the `agg_type` is `count`, `sum`, `true`, or `false`, the process will sum the values.
- If the `agg_type` is `max`, it will take the maximum value, and if it is `min`, it will take the minimum value.
- This process is only applied to the last three versions.
- The table is partitioned by `submission_date`. The partitions expire in 7 days.

#### [`client_scalar_probe_counts`](<https://mozilla.acryl.io/tasks/urn:li:dataJob:(urn:li:dataFlow:(airflow,glam,prod),client_scalar_probe_counts)/Documentation?is_lineage_mode=false>)

- This step processes booleans and scalars, although booleans are not supported by GLAM.
- For boolean metrics the process aggregates their values with the following rule: "never" if all values for a metric are false, "always" if all values are true, and "sometimes" if there's a mix.
- For scalar and `keyed_scalar` probes the process starts by building the buckets per metric, then it generates wildcards for os and `app_build_id`. It then aggregates all submissions from the same `client_id` under one row and assigns the `user_count` column to it with the following rule: 10 if os is "Windows" and channel is "release", 1 otherwise. After that it finishes by aggregating the rows per metric, placing the scalar values in their appropriate buckets and summing up all `user_count` values for that metric.

---

#### [`glam_sample_counts`](<https://mozilla.acryl.io/dataset/urn:li:dataset:(urn:li:dataPlatform:bigquery,moz-fx-data-shared-prod.telemetry_derived.glam_sample_counts_v1,PROD)/Schema?is_lineage_mode=false&schemaFilter=>)

- This process calculates the `total_sample` column.
