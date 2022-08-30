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
