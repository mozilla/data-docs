# Experiment monitoring datasets

<!-- toc -->

Experiment monitoring datasets are designed to power dashboards, such as [Experiment Enrollment Grafana dashboard](https://grafana.telemetry.mozilla.org/d/XspgvdxZz/experiment-enrollment?orgId=1), for monitoring experiments in real time. Currently, datasets for monitoring the number or enrollments and number of searches performed by clients enrolled in experiments are available.

## Experiment enrollment data

`moz-fx-data-shared-prod.telemetry_derived.experiment_enrollment_aggregates_live` provides enrollment, unenrollment, graduate, update and failure aggregates for experiments and branches over 5-minute intervals. This live view is also the basis of several derived tables:

| Dataset name                                                             | Description                                                         |
| ------------------------------------------------------------------------ | ------------------------------------------------------------------- |
| `mozdata.telemetry.experiment_unenrollment_overall`                      | Overall number of clients that unenrolled from experiments          |
| `mozdata.telemetry.experiment_enrollment_other_events_overall`           | Number of events other than `enroll` and `unenroll` sent by clients |
| `mozdata.telemetry.experiment_enrollment_cumulative_population_estimate` | Cumulative number of clients enrolled in experiments                |
| `mozdata.telemetry.experiment_enrollment_overall`                        | Overall number of clients enrolled in experiments                   |
| `mozdata.telemetry.experiment_enrollment_daily_active_population`        | Number of daily active clients enrolled in experiments              |

## Experiment search metrics data

`moz-fx-data-shared-prod.telemetry_derived.experiment_search_aggregates_live_v1` provides aggregated search metrics of clients enrolled in experiments, such as the number of searches performed, the number of searches with ads and the number of ad clicks. This live view is also the basis of several derived tables:

| Dataset name                                                    | Description                                                               |
| --------------------------------------------------------------- | ------------------------------------------------------------------------- |
| `mozdata.telemetry.experiment_cumulative_ad_clicks`             | Cumulative number of ad clicks by clients enrolled in experiments         |
| `mozdata.telemetry.experiment_cumulative_search_count`          | Cumulative number of searches by clients enrolled in experiments          |
| `mozdata.telemetry.experiment_cumulative_search_with_ads_count` | Cumulative number of searches with ads by clients enrolled in experiments |

## Derived tables

Derived tables all have the same schema:

| Column name  | Type        | Description                       |
| ------------ | ----------- | --------------------------------- |
| `time`       | `TIMESTAMP` | Timestamp when value was recorded |
| `branch`     | `STRING`    | Experiment branch                 |
| `experiment` | `STRING`    | Experiment slug                   |
| `value`      | `INT64`     | Aggregated value                  |

As an example of how these derived tables can be used, the following query determines the number of cumulative clients enrolled
in a the `multi-stage-aboutwelcome-set-default-as-first-screen` experiment to date in each branch of a study:

```sql
SELECT
    branch,
    SUM(value) AS total_enrolled
FROM `mozdata.telemetry.experiment_enrollment_cumulative_population_estimate`
WHERE experiment = 'multi-stage-aboutwelcome-set-default-as-first-screen'
GROUP BY 1
ORDER BY 2
```

## GCS data export

As some dashboard solutions, such as the Experimenter console, might not have access to BigQuery, data from derived experiment monitoring tables is also exported as JSON to `monitoring/` in the `mozanalysis` bucket in `moz-fx-data-experiments`. JSON files are named like: `<experiment_slug>_<monitoring_dataset_name>.json`, for example: `gs://mozanalysis/monitoring/bug-1683348-rollout-tab-modal-print-ui-roll-out-release-84-85_experiment_unenrollment_overall.json`

A script for exporting this data is [scheduled to run via Airflow](https://github.com/mozilla/telemetry-airflow/blob/ad3d678cb45c7ac67cb96a46efb6b4e731b856f0/dags/experiments_live.py#L70) every 5 minutes.

## Scheduling

To keep cost low for populating the monitoring live tables, several jobs have been set up for each enrollments and search metrics monitoring live tables:

- [Hourly jobs](https://github.com/mozilla/bigquery-etl/blob/master/dags/bqetl_experiments_hourly.py) that materialize data from the live tables from the past hour and write it to the hourly-partitioned `telemetry_derived.experiment_enrollment_aggregates_hourly_v1` and `telemetry_derived.experiment_search_aggregates_hourly_v1` tables. The jobs are scheduled with some lag (30 minutes) to account for BigQuery sink delays.
- [Daily jobs](https://github.com/mozilla/bigquery-etl/blob/master/dags/bqetl_experiments_daily.py) for updating `telemetry_derived.experiment_enrollment_aggregates_v1` and `telemetry_derived.experiment_search_aggregates_v1` to finalize numbers from the stable tables.
- [Jobs scheduled to run every 5 minutes](https://github.com/mozilla/telemetry-airflow/blob/ad3d678cb45c7ac67cb96a46efb6b4e731b856f0/dags/experiments_live.py#L18) that dump experiment enrollment aggregates and experiment search metrics aggregates that are very recent and have not been processed by the hourly job yet into `telemetry_derived.experiment_enrollment_aggregates_recents_v1` and `telemetry_derived.experiment_search_aggregates_recents_v1`.

The tables derived from the experiment monitoring live tables are also [scheduled to run every 5 minutes together with the data export script](https://github.com/mozilla/telemetry-airflow/blob/ad3d678cb45c7ac67cb96a46efb6b4e731b856f0/dags/experiments_live.py#L18).

## Code reference

[`moz-fx-data-shared-prod.telemetry_derived.experiment_enrollment_aggregates_live`](https://github.com/mozilla/bigquery-etl/blob/master/sql/moz-fx-data-shared-prod/telemetry_derived/experiment_enrollment_aggregates_live/view.sql) and derived datasets are part of bigquery-etl:

- [`mozdata.telemetry.experiment_enrollment_other_events_overall`](https://github.com/mozilla/bigquery-etl/blob/master/sql/moz-fx-data-shared-prod/telemetry_derived/experiment_enrollment_other_events_overall_v1/query.sql)
- [`mozdata.telemetry.experiment_enrollment_cumulative_population_estimate`](https://github.com/mozilla/bigquery-etl/blob/master/sql/moz-fx-data-shared-prod/telemetry_derived/experiment_enrollment_cumulative_population_estimate_v1/query.sql)
- [`mozdata.telemetry.experiment_enrollment_overall`](https://github.com/mozilla/bigquery-etl/blob/master/sql/moz-fx-data-shared-prod/telemetry_derived/experiment_enrollment_overall_v1/query.sql)
- [`mozdata.telemetry.experiment_unenrollment_overall`](https://github.com/mozilla/bigquery-etl/blob/master/sql/moz-fx-data-shared-prod/telemetry_derived/experiment_unenrollment_overall_v1/query.sql)
- [`mozdata.telemetry.experiment_enrollment_daily_active_population`](https://github.com/mozilla/bigquery-etl/blob/master/sql/moz-fx-data-shared-prod/telemetry_derived/experiment_enrollment_daily_active_population_v1/query.sql)

[`moz-fx-data-shared-prod.telemetry_derived.experiment_search_aggregates_live_v1`](https://github.com/mozilla/bigquery-etl/blob/master/sql/moz-fx-data-shared-prod/telemetry_derived/experiment_search_aggregates_live_v1/view.sql) and derived datasets are part of bigquery-etl:

- [`mozdata.telemetry.experiment_cumulative_ad_clicks`](https://github.com/mozilla/bigquery-etl/blob/master/sql/moz-fx-data-shared-prod/telemetry_derived/experiment_cumulative_ad_clicks_v1/query.sql)
- [`mozdata.telemetry.experiment_cumulative_search_count`](https://github.com/mozilla/bigquery-etl/blob/master/sql/moz-fx-data-shared-prod/telemetry_derived/experiment_cumulative_search_count_v1/query.sql)
- [`mozdata.telemetry.experiment_cumulative_search_with_ads_count`](https://github.com/mozilla/bigquery-etl/blob/master/sql/moz-fx-data-shared-prod/telemetry_derived/experiment_cumulative_search_with_ads_count_v1/query.sql)
