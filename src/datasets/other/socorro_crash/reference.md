# Socorro Crash Reports

<!-- toc -->

## Introduction

{% include "./intro.md" %}

## Data Reference

### Example

The dataset can be queried using SQL.
For example, we can aggregate the number of crashes and total up-time by date and reason.

```sql
SELECT crash_date,
       reason,
       count(*) as n_crashes,
       avg(uptime) as avg_uptime,
       stddev(uptime) as stddev_uptime,
       approx_percentile(uptime, ARRAY [0.25, 0.5, 0.75]) as qntl_uptime
FROM socorro_crash
WHERE crash_date='20180520'
GROUP BY 1,
         2
```

[STMO Source](https://sql.telemetry.mozilla.org/queries/53884/source)

### Scheduling
The job is schedule on a nightly basis on airflow.
The dag is available under [`mozilla/telemetry-airflow:/dags/socorro_import.py`](https://github.com/mozilla/telemetry-airflow/blob/930790116d8d5c924cd61a07311fc8a34340f3d6/dags/socorro_import.py).

### Schema 
The source schema is available on the [`mozilla/socorro` GitHub repository](https://raw.githubusercontent.com/mozilla/socorro/master/socorro/schemas/crash_report.json).
This schema is transformed into a Spark-SQL structure and serialized to parquet after transforming column names from `camelCase` to `snake_case`.


### Code Reference

The code is [a notebook in the `mozilla-services/data-pipeline` repository](https://github.com/mozilla-services/data-pipeline/blob/master/reports/socorro_import/ImportCrashData.ipynb).
