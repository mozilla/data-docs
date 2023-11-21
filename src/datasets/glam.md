# GLAM datasets

[GLAM](https://glam.telemetry.mozilla.org) aims to answer a majority of the "easy" questions of how a probe or metric has changed over time.
The GLAM aggregation tables are useful for accessing the data that drives GLAM if more exploration is required.
Exploring the GLAM tables could take that a little farther, but still has some limitations.
If you need to dive deeper or aggregate on a field that isn't included here, consider reading [Visualizing Percentiles of a Main Ping Exponential Histogram](https://docs.telemetry.mozilla.org/cookbooks/main_ping_exponential_histograms.html).

The GLAM tables:

- Are aggregated at the client level, not the submission ping level
- Provide a set of dimensions for subsets: channel, OS, process or ping type
- Are aggregated by build ID and version
- For each aggregation, the distribution and percentiles over time are calculated
- Have the last 3 versions of data aggregated every day
- Retain data for up to 10 major versions

## Firefox Desktop

### Data source table

- `moz-fx-data-shared-prod.telemetry.client_probe_counts`

### Data reference

- `os`: One of Windows, Mac, Linux, or NULL for all OSes
- `app_version`: Integer representing the major version
- `app_build_id`: The full build ID, or NULL if aggregated by major version
- `channel`: One of nightly, beta, or release
- `metric`: The name of the metric
- `metric_type`: The type of metric, e.g. `histogram-enumerated`
- `key`: The key if the metric is a keyed metric
- `process`: The process
- `client_agg_type`: The type of client aggregation used, e.g. `summed_histogram`
- `agg_type`: One of histogram or percentiles representing what data will be in the `aggregates` column
- `total_users`: The number of users that submitted data for the combination of dimensions
- `aggregates`: The data as a key/value record, either percentiles or histogram

### Sample query

```sql
SELECT
  os,
  app_version,
  app_build_id,
  channel,
  metric,
  metric_type,
  key,
  process,
  client_agg_type,
  agg_type,
  total_users,
  mozfun.glam.histogram_cast_json(aggregates) AS aggregates
FROM
  `moz-fx-data-shared-prod.telemetry.client_probe_counts`
WHERE
  metric="checkerboard_severity"
  AND channel="nightly"
  AND os IS NULL
  AND process="parent"
  AND app_build_id IS NULL
```

Notes:

- To query all OSes, use: `WHERE os IS NULL`
- To query by build ID, use: `WHERE app_build_id IS NOT NULL`
- To query by version, use: `WHERE app_build_id IS NULL`

## Firefox for Android

### Data source tables

- `org_mozilla_fenix_glam_release__view_probe_counts_v1`
- `org_mozilla_fenix_glam_beta__view_probe_counts_v1`
- `org_mozilla_fenix_glam_nightly__view_probe_counts_v1`

## Data reference

- `os`: Just "Android" for now
- `app_version`: Integer representing the major version
- `app_build_id`: The full build ID, or "\*" if aggregated by major version
- `channel`: Always "\*", use the different source tables to select a channel
- `metric`: The name of the metric
- `metric_type`: The type of metric, e.g. `timing_distribution`
- `key`: The key if the metric is a keyed metric
- `ping_type`: The type of ping, or "\*" for all ping types
- `client_agg_type`: The type of client aggregation used, e.g. `summed_histogram`
- `agg_type`: One of histogram or percentiles representing what data will be in the `aggregates` column
- `total_users`: The number of users that submitted data for the combination of dimensions
- `aggregates`: The data as a key/value record, either percentiles or histogram

### Sample query

```sql
SELECT
  ping_type,
  os,
  app_version,
  app_build_id,
  metric,
  metric_type,
  key,
  client_agg_type,
  agg_type,
  total_users,
  mozfun.glam.histogram_cast_json(aggregates) AS aggregates,
FROM
  `moz-fx-data-shared-prod.glam_etl.org_mozilla_fenix_glam_release__view_probe_counts_v1`
WHERE
  metric="performance_time_dom_complete"
  AND os="Android"
  AND ping_type="*"
  AND app_build_id!="*"
```

Notes:

- To query all ping types, use: `WHERE ping_type = "*"`
- To query by build ID, use: `WHERE app_build_id != "*"`
- To query by version, use: `WHERE app_build_id = "*"`

## GLAM Intermediate Tables

In addition to the above tables, the GLAM ETL produces intermediate tables that can be useful outside of the GLAM ETL in some cases.
These tables include the client ID and could be joined with other tables to filter by client based data (e.g. specific hardware).

### Firefox Desktop

Data sources:

- `moz-fx-data-shared-prod.telemetry.clients_daily_histogram_aggregates`
- `moz-fx-data-shared-prod.telemetry.clients_daily_scalar_aggregates`

These tables are:

- Preprocessed from main telemetry to intermediate data with one row per client per metric per day, then aggregated normalizing across clients.
- Clients daily aggregates analogous to clients daily with:
  - all metrics aggregated
  - each scalar includes min, max, average, sum, and count aggregations
  - each histogram aggregated over all client data per day
  - each date is further aggregated over the dimensions: channel, os, version, build ID

## ETL Pipeline

### Scheduling

GLAM is scheduled to run daily via Airflow. There are two separate ETL pipelines for computing GLAM datasets for [Firefox Desktop legacy](https://workflow.telemetry.mozilla.org/dags/glam/grid), [Fenix](https://workflow.telemetry.mozilla.org/dags/glam_fenix/grid) and [Firefox on Glean](https://workflow.telemetry.mozilla.org/dags/glam_fog/grid).

### Source Code

The ETL code base lives in the [bigquery-etl repository](https://github.com/mozilla/bigquery-etl) and is partially generated. The scripts for generating ETL queries for Firefox Desktop Legacy currently live [here](https://github.com/mozilla/bigquery-etl/tree/main/script/glam) while the GLAM logic for Glean apps lives [here](https://github.com/mozilla/bigquery-etl/tree/main/bigquery_etl/glam).

### Steps

GLAM has a separate set of steps and intermediate tables to aggregate scalar and histogram probes.

#### `latest_versions`

- This task pulls in the most recent version for each channel from https://product-details.mozilla.org/1.0/firefox_versions.json

#### `clients_daily_histogram_aggregates_<process>`

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

#### `clients_histogram_aggregates_new`

- This step groups together all rows that have the same `submission_date` and `logical_date` from different processes and keyed and non-keyed sources, and combines them into a single row in the `histogram_aggregates` column. It sums the histogram values with the same key.
- This process is only applied to the last three versions.
- The table is overwritten at every execution of this step.

#### `clients_histogram_aggregates`

- New entries from `clients_histogram_aggregates_new` are merged with the 3 last versions of previous day’s partition and written to the current day’s partition.
- The most recent partition contains the current snapshot of the last three versions of data.
- The partitions expire in 7 days.

#### `clients_histogram_buckets_counts`

- This process starts by creating wildcards for `os` and `app_build_id` which are needed for aggregating values across os and build IDs later on.
- It then filters out builds that have less than 0.5% of WAU (which can vary per channel). This is referenced in https://github.com/mozilla/glam/issues/1575#issuecomment-946880387.
- The process then normalizes histograms per client - it sets the sum of histogram values for each client for a given metric to 1.
- Finally, it removes the `client_id` dimension by aggregating all histograms for a given metric and adding the clients' histogram values.

#### `clients_histogram_probe_counts`

- This process generates buckets - which can be linear or exponential - based on the `metric_type`.
- It then aggregates metrics per wildcards (`os`, `app_build_id`).
- Finally, it rebuilds histograms using the Dirichlet Distribution, normalized using the number of clients that contributed to that histogram in the `clients_histogram_buckets_counts` step.

#### `histogram_percentiles`

- Uses `mozfun.glam.percentile` UDF to build histogram percentiles, from [0.1 to 99.9]

---

#### `clients_daily_scalar_aggregates`

- The set of steps that load data to this table are divided into non-keyed `scalar`, `keyed_boolean` and `keyed_scalar`. The non-keyed scalar job creates or overwrites the partition corresponding to the `logical_date`, and other processes append data to that partition.
- The process uses `telemetry.buildhub2` to select rows with valid `build_ids`.
- Aggregations are done per client, per day and include a line for each `client`, `os`, `app_version`, `build_id`, and `channel`.
- The queries for the different steps are generated and run as part of each step. All steps include probes regardless of process (`parent`, `content`, `gpu`).
- As a result of the subdivisions in this step, it generates different rows for each keyed/non-keyed, boolean/scalar metric, which will be grouped together in `clients_scalar_aggregates`.
- Clients that are on the release channel of the Windows operating system get sampled to reduce the data size.
- Partitions expire in 7 days.

#### `clients_scalar_aggregates`

- The process starts by taking the `clients_daily_scalar_aggregates` as the primary source.
- It then groups all rows that have the same `submission_date` and `logical_date` from the keyed and non-keyed, scalar and boolean sources, and combines them into a single row in the `scalar_aggregates` column.
- If the `agg_type` is `count`, `sum`, `true`, or `false`, the process will sum the values.
- If the `agg_type` is `max`, it will take the maximum value, and if it is `min`, it will take the minimum value.
- This process is only applied to the last three versions.
- The partitions expire in 7 days.

#### `scalar_percentiles`

- This process produces a user count and percentiles for scalar metrics.
- It generates wildcard combinations of `os` and `app_build_id` and merges all submissions from a client for the same `os`, `app_version`, `app_build_id` and channel into the `scalar_aggregates` column.
- The `user_count` column is computed taking sampling into account.
- Finally it splits the aggregates into percentiles from [0.1 to 99.9]

#### `client_scalar_probe_counts`

- This step processes booleans and scalars, although booleans are not supported by GLAM.
  - For boolean metrics the process aggregates their values with the following rule: "never" if all values for a metric are false, "always" if all values are true, and sometimes if there's a mix.
  - For scalar and `keyed_scalar` probes the process starts by building the buckets per metric, then it generates wildcards for os and `app_build_id`. It then aggregates all submissions from the same `client_id` under one row and assigns the `user_count` column to it with the following rule: 10 if os is "Windows" and channel is "release", 1 otherwise. After that it finishes by aggregating the rows per metric, placing the scalar values in their appropriate buckets and summing up all `user_count` values for that metric.

---

#### `glam_user_counts`

- Combines both aggregated scalar and histogram values.
- This process produces a user count for each combination of `os`, `app_version`, `app_build_id`, channel.
- It builds a client count from the union of histograms and scalars, including all combinations in which `os`, `app_version`, `app_build_id`, and `channel` are wildcards.

#### `glam_sample_counts`

- This process calculates the `total_sample` column by adding up all the `aggregates` values.
- This works because in the primary sources the values also represent a count of the samples that registered their respective keys

#### `extract_user_counts`

- This step exports user counts in its final shape to GCS as a CSV.
- It first copies a deduplicated version of the primary source to a temporary table, removes the previously exported CSV files from GCS, then exports the temporary table to GCS as CSV files.
