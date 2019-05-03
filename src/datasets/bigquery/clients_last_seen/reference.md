# Clients Last Seen Reference

<!-- toc -->

# Introduction

{{#include ./intro.md}}

# Data Reference

## Example Queries

#### Compute DAU for non-windows clients for the last week

```sql
SELECT
    submission_date,
    os,
    COUNT(*) AS count
FROM
    clients_last_seen
WHERE
    submission_date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 WEEK)
    AND last_seen_date = submission_date
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

#### Compute WAU by Channel for the last week

```sql
SELECT
    submission_date,
    normalized_channel,
    COUNT(*) AS count
FROM
    clients_last_seen
WHERE
    submission_date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 WEEK)
    AND last_seen_date > DATE_SUB(submission_date, INTERVAL 1 WEEK)
GROUP BY
    submission_date,
    normalized_channel
HAVING
    count > 10 -- remove outliers
ORDER BY
    normalized_channel,
    submission_date DESC
```

## Scheduling

This dataset is updated daily via the
[telemetry-airflow](https://github.com/mozilla/telemetry-airflow)
infrastructure. The job runs as part of the
[`main_summary` DAG](https://github.com/mozilla/telemetry-airflow/blob/89a6dc3/dags/main_summary.py#L365).

## Schema

The data is partitioned by `submission_date`.

As of 2019-03-25, the current version of the `clients_last_seen` dataset is
`v1`, and the schema is visible in the BigQuery console
[here](https://console.cloud.google.com/bigquery?p=moz-fx-data-derived-datasets&d=telemetry&t=clients_last_seen_v1&page=table).
