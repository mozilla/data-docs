# Making Datasets Publicly Available

Currently, only datasets and query results that are available in BigQuery and
defined in the [bigquery-etl][bigquery_etl] repository can be made publicly available.
See the [bigquery-etl documentation](https://mozilla.github.io/bigquery-etl/cookbooks/creating_a_derived_dataset/)
for information on how to create and schedule datasets. Before data can be published, a data review is
required.

To make query results publicly available, a [`metadata.yaml` file][bigquery_etl_metadata]
must be added alongside the query in bigquery-etl. For example:

```yaml
friendly_name: SSL Ratios
description: >-
  Percentages of page loads Firefox users have performed that were 
  conducted over SSL broken down by country.
owners:
  - example@mozilla.com
labels:
  application: firefox
  incremental: true # incremental queries add data to existing tables
  schedule: daily # scheduled in Airflow to run daily
  public_json: true
  public_bigquery: true
  review_bug: 1414839 # Bugzilla bug ID of data review
  incremental_export: false # non-incremental JSON export writes all data to a single location
```

The following options define how data is published:

- `public_json`: data is available through the [public HTTP endpoint][public_data_endpoint]
- `public_bigquery`: data is publicly available on BigQuery
  - tables will get published in the `mozilla-public-data` GCP project which is accessible
    by everyone, also external users
- `incremental_export`: determines how data gets split up
  - `true`: data for each `submission_date` gets exported into separate directories (e.g.
    `files/2020-04-15`, `files/2020-04-16`, ...)
    - `false`: all data gets exported into one `files/` directory
- `incremental`: indicates how data gets updated based on the query and Airflow configuration
  - `true`: data gets incrementally updated
  - `false`: the entire table data gets updated
- `review_bug`: Bugzilla bug number to the data review

Data will get published when the query is executed in Airflow. Metadata of available public
data on Cloud Storage is updated daily through a separate Airflow task.

More information about accessing public data can be found in
[Accessing Public Data](../cookbooks/public_data.md).

[bigquery_etl]: https://github.com/mozilla/bigquery-etl
[bigquery_etl_metadata]: https://github.com/mozilla/bigquery-etl#query-metadata
[public_data_endpoint]: https://public-data.telemetry.mozilla.org
