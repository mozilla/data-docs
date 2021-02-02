# Accessing Public Data

A public dataset is a dataset in [BigQuery][bigquery] which is made available to the general public
in BigQuery or through our [public HTTP endpoint][public_data_endpoint].

## Table of Contents

<!-- toc -->

## Accessing Public Data in BigQuery

To access public datasets in BigQuery, a [Google Cloud Platform][gcp] (GCP) account is required.
GCP also offers [a free tier][gcp_free] which offers free credits to use and run queries in BigQuery. [BigQuery sandbox][bigquery_sandbox] enables users to use BigQuery for free without requiring payment information.

To get started, log into the [BigQuery console][bigquery_console] or use the
[BigQuery command line tools][bigquery_command_line] to [create a new project][bigquery_new_project].
After selecting the project, Mozilla's public datasets in the `mozilla-public-data` project can
be accessed and queried. For example:

```sql
SELECT *
FROM `mozilla-public-data.telemetry_derived.ssl_ratios_v1`
WHERE submission_date = "2020-04-16"
```

## Accessing Public Data Through the Public HTTP Endpoint

Some BigQuery datasets are also published as gzipped JSON files through the public HTTP endpoint:
[https://public-data.telemetry.mozilla.org][public_data_endpoint].

A list of available public datasets is available at: [https://public-data.telemetry.mozilla.org/all-datasets.json](https://public-data.telemetry.mozilla.org/all-datasets.json)
This list contains the names of available datasets, additional metadata and links to the
storage locations of the files containing the data.

For example:

```json
{
  "telemetry_derived": {
    // ^ dataset name
    "deviations": {
      // ^ table name
      "v1": {
        // ^ table version
        "friendly_name": "Deviations",
        "description": "Deviation of different metrics from forecast.",
        "incremental": true,
        "incremental_export": false,
        "review_link": "https://bugzilla.mozilla.org/show_bug.cgi?id=1624528",
        "files_uri": "https://public-data.telemetry.mozilla.org/api/v1/tables/telemetry_derived/deviations/v1/files",
        "last_updated": "https://public-data.telemetry.mozilla.org/api/v1/tables/telemetry_derived/deviations/v1/last_updated"
      }
    },
    "ssl_ratios": {
      "v1": {
        "friendly_name": "SSL Ratios",
        "description": "Percentages of page loads Firefox users have performed that were  conducted over SSL broken down by country.",
        "incremental": true,
        "incremental_export": false,
        "review_link": "https://bugzilla.mozilla.org/show_bug.cgi?id=1414839",
        "files_uri": "https://public-data.telemetry.mozilla.org/api/v1/tables/telemetry_derived/ssl_ratios/v1/files",
        "last_updated": "https://public-data.telemetry.mozilla.org/api/v1/tables/telemetry_derived/ssl_ratios/v1/last_updated"
      }
    }
    // [...]
  }
}
```

The keys within each dataset have the following meanings:

- `incremental`:
  - `true`: data gets incrementally updated which means that new data gets added periodically
    (for most datasets on a daily basis)
  - `false`: the entire table data gets updated periodically
- `incremental_export`:
  - `true`: data for each `submission_date` gets exported into separate directories (e.g.
    `files/2020-04-15`, `files/2020-04-16`, ...)
  - `false`: all data gets exported into one `files/` directory
- `review_link`: links to the Bugzilla bug for the data review
- `files_uri`: lists links to all available data files
- `last_updated`: link to a `last_updated` file containing the timestamp for when the data files were
  last updated

Data files are gzipped and up to 1 GB in size. If the data exceeds 1 GB, then it gets split up into multiple
files named `000000000000.json`, `000000000001.json`, ...
For example: [https://public-data.telemetry.mozilla.org/api/v1/tables/telemetry_derived/ssl_ratios/v1/files/000000000000.json](https://public-data.telemetry.mozilla.org/api/v1/tables/telemetry_derived/ssl_ratios/v1/files/000000000000.json)

## Let us know!

If this public data has proved useful to your research, or you've built a cool visualization with it, let us know! You can email [`publicdata@mozilla.com`](mailto:publicdata@mozilla.com) or reach us on the [#telemetry:mozilla.org] channel on [Mozilla's instance of matrix].

[bigquery]: https://cloud.google.com/bigquery
[bigquery_console]: https://console.cloud.google.com/bigquery
[bigquery_command_line]: https://cloud.google.com/bigquery/docs/bq-command-line-tool
[bigquery_new_project]: https://cloud.google.com/appengine/docs/standard/nodejs/building-app/creating-project
[gcp]: https://cloud.google.com
[gcp_free]: https://cloud.google.com/free
[bigquery_sandbox]: https://cloud.google.com/blog/products/data-analytics/query-without-a-credit-card-introducing-bigquery-sandbox
[public_data_endpoint]: https://public-data.telemetry.mozilla.org
[public_data_datasets]: https://public-data.telemetry.mozilla.org/all-datasets.json
[#telemetry:mozilla.org]: https://chat.mozilla.org/#/room/#telemetry:mozilla.org
[mozilla's instance of matrix]: https://wiki.mozilla.org/Matrix
