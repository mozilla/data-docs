# Telemetry Aggregates Reference

<!-- toc -->

# Introduction

{{#include ./intro.md}}

# Data Reference

## Example Queries

Here's an example query that shows the number of pings received per
`submission_date` for the dimensions provided.

```sql
SELECT
    submission_date,
    SUM(count) AS pings
FROM
    telemetry_aggregates
WHERE
    channel = 'nightly'
    AND metric = 'GC_MS'
    AND aggregate_type = 'build_id'
    AND period = '201901'
GROUP BY
    submission_date
ORDER BY
    submission_date
;
```

## Sampling

### Invalid Pings

We ignore invalid pings in our processing. Invalid pings are defined as those that:

- The submission dates are invalid or missing.
- The build ID is malformed.
- The `docType` field is missing or unknown.
- The build ID is older than a defined cutoff days.
  (See the `BUILD_ID_CUTOFFS` variable in the
  [code](https://github.com/mozilla/python_mozaggregator/) for the max days per channel)

## Scheduling

The `telemetry_aggregates` job is run daily, at midnight UTC.
The job is scheduled on [Airflow](https://github.com/mozilla/telemetry-airflow).
The DAG is [here](https://github.com/mozilla/telemetry-airflow/blob/831fe84a36347f440ede4f5a90e0bf83d4fa1e1e/dags/mozaggregator_parquet.py)

## Schema

The `telemetry_aggregates` table has a set of dimensions and set of
aggregates for those dimensions.

The partitioned dimensions are the following columns. Filtering by one of
these fields to limit the resulting number of rows can run significantly
faster:

- `metric` is the name of the metric, like `"GC_MS"`.
- `aggregate_type` is the type of aggregation, either `"build_id"` or
  `"submission_date"`, representing how this aggregation was grouped.
- `period` is a string representing the month in `YYYYMM` format that a ping
  was submitted, like `'201901'`.

The rest of the dimensions are:

- `submission_date` is the date pings were submitted for a particular aggregate.
- `channel` is the channel, like `release` or `beta`.
- `version` is the program version, like `46.0a1`.
- `build_id` is the `YYYYMMDDhhmmss` timestamp the program was built, like
  `20190123192837`.
- `application` is the program name, like `Firefox` or `Fennec`.
- `architecture` is the architecture that the program was built for (not
  necessarily the one it is running on).
- `os` is the name of the OS the program is running on, like `Darwin` or `Windows_NT`.
- `os_version` is the version of the OS the program is running on.
- `key` is the key of a keyed metric. This will be empty if the underlying
  metric is not a keyed metric.
- `process_type` is the process the histogram was recorded in, like `content`
  or `parent`.

The aggregates are:

- `count` is the aggregate sum of the number of pings per dimensions.
- `sum` is the aggregate sum of the histogram values per dimensions.
- `histogram` is the aggregated histogram per dimensions.
