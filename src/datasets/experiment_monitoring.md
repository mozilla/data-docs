# Experiment monitoring datasets

<!-- toc -->

Experiment monitoring datasets are designed to power dashboards, such as [Experiment Enrollment Grafana dashboard](https://mozilla.cloud.looker.com/dashboards/216), for monitoring experiments in real time. Currently, datasets for monitoring the number or enrollments and number of searches performed by clients enrolled in experiments are available.

## Experiment enrollment data

`moz-fx-data-shared-prod.telemetry_derived.experiment_enrollment_aggregates_live_v1` provides enrollment, unenrollment, graduate, update and failure aggregates for experiments and branches over 5-minute intervals for Fenix and desktop experiments. This live view is also the basis of several derived views:

| Dataset name                                                             | Description                                                         |
| ------------------------------------------------------------------------ | ------------------------------------------------------------------- |
| `mozdata.telemetry.experiment_unenrollment_overall`                      | Overall number of clients that unenrolled from experiments          |
| `mozdata.telemetry.experiment_enrollment_other_events_overall`           | Number of events other than `enroll` and `unenroll` sent by clients |
| `mozdata.telemetry.experiment_enrollment_cumulative_population_estimate` | Cumulative number of clients enrolled in experiments                |
| `mozdata.telemetry.experiment_enrollment_overall`                        | Overall number of clients enrolled in experiments                   |
| `mozdata.telemetry.experiment_enrollment_daily_active_population`        | Number of daily active clients enrolled in experiments              |

## Experiment search metrics data

`moz-fx-data-shared-prod.telemetry_derived.experiment_search_aggregates_live_v1` provides aggregated search metrics of clients enrolled in Fenix and desktop experiments, such as the number of searches performed, the number of searches with ads and the number of ad clicks. This live view is also the basis of several derived views:

| Dataset name                                                    | Description                                                               |
| --------------------------------------------------------------- | ------------------------------------------------------------------------- |
| `mozdata.telemetry.experiment_cumulative_ad_clicks`             | Cumulative number of ad clicks by clients enrolled in experiments         |
| `mozdata.telemetry.experiment_cumulative_search_count`          | Cumulative number of searches by clients enrolled in experiments          |
| `mozdata.telemetry.experiment_cumulative_search_with_ads_count` | Cumulative number of searches with ads by clients enrolled in experiments |

## Derived dataset

The derived views have the following schema:

| Column name  | Type        | Description                       |
| ------------ | ----------- | --------------------------------- |
| `time`       | `TIMESTAMP` | Timestamp when value was recorded |
| `branch`     | `STRING`    | Experiment branch                 |
| `experiment` | `STRING`    | Experiment slug                   |
| `value`      | `INT64`     | Aggregated value                  |

As an example of how these views can be used, the following query determines the number of cumulative clients enrolled
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

As some dashboard solutions, such as the Experimenter console, might not have access to BigQuery, data from derived experiment monitoring views is also exported as JSON to `monitoring/` in the `mozanalysis` bucket in `moz-fx-data-experiments`. JSON files are named like: `<experiment_slug>_<monitoring_dataset_name>.json`, for example: `gs://mozanalysis/monitoring/bug-1683348-rollout-tab-modal-print-ui-roll-out-release-84-85_experiment_unenrollment_overall.json`

A script for exporting this data is [scheduled to run via Airflow](https://github.com/mozilla/telemetry-airflow/blob/ad3d678cb45c7ac67cb96a46efb6b4e731b856f0/dags/experiments_live.py#L70) every 5 minutes.

## Implementation

To keep the cost low for retrieving live monitoring data, [BigQuery materialized views](https://cloud.google.com/bigquery/docs/materialized-views-intro) have been set up. These materialized views read delta changes from the base live tables to compute up-to-date results every 5 minutes.

As materialized views do not support `UNION ALL`, separate materialized views are deployed for legacy desktop telemetry and every Fenix related dataset.

Materialized views for experiment enrollment events:

- `org_mozilla_fenix_derived.experiment_events_live_v1`
- `org_mozilla_firefox_derived.experiment_events_live_v1`
- `org_mozilla_firefox_beta_derived.experiment_events_live_v1`
- `telemetry_derived.experiment_events_live_v1`

The `moz-fx-data-shared-prod.telemetry_derived.experiment_enrollment_aggregates_live_v1` view combines data of the past 2 days from all of the materialized views for experiment enrollments with data older than 2 days from `telemetry_derived.experiment_enrollment_aggregates_v1`.

Materialized view for search metrics:

- `org_mozilla_fenix_derived.experiment_search_events_live_v1`
- `org_mozilla_firefox_derived.experiment_search_events_live_v1`
- `org_mozilla_firefox_beta_derived.experiment_search_events_live_v1`
- `telemetry_derived.experiment_search_events_live_v1`

The `moz-fx-data-shared-prod.telemetry_derived.experiment_search_aggregates_live_v1` view combines data of the past 2 days from all of the materialized views for search metrics with data older than 2 days from `telemetry_derived.search_aggregates_v1`.

## Code reference

- [`moz-fx-data-shared-prod.telemetry_derived.experiment_enrollment_aggregates_live_v1`](https://github.com/mozilla/bigquery-etl/blob/master/sql/moz-fx-data-shared-prod/telemetry_derived/experiment_enrollment_aggregates_live_v1/view.sql)
- [`org_mozilla_fenix_derived.experiment_events_live_v1`](https://github.com/mozilla/bigquery-etl/tree/master/sql/moz-fx-data-shared-prod/org_mozilla_fenix_derived/experiment_events_live_v1/init.sql)
- [`org_mozilla_firefox_derived.experiment_events_live_v1`](https://github.com/mozilla/bigquery-etl/tree/master/sql/moz-fx-data-shared-prod/org_mozilla_firefox_derived/experiment_events_live_v1/init.sql)
- [`org_mozilla_firefox_beta_derived.experiment_events_live_v1`](https://github.com/mozilla/bigquery-etl/tree/master/sql/moz-fx-data-shared-prod/org_mozilla_firefox_beta_derived/experiment_events_live_v1/init.sql)

-[`moz-fx-data-shared-prod.telemetry_derived.experiment_search_aggregates_live_v1`](https://github.com/mozilla/bigquery-etl/blob/master/sql/moz-fx-data-shared-prod/telemetry_derived/experiment_search_aggregates_live_v1/view.sql)

- [`org_mozilla_fenix_derived.experiment_search_events_live_v1`](https://github.com/mozilla/bigquery-etl/tree/master/sql/moz-fx-data-shared-prod/org_mozilla_fenix_derived/experiment_search_events_live_v1/init.sql)
- [`org_mozilla_firefox_derived.experiment_search_events_live_v1`](https://github.com/mozilla/bigquery-etl/tree/master/sql/moz-fx-data-shared-prod/org_mozilla_firefox_derived/experiment_search_events_live_v1/init.sql)
- [`org_mozilla_firefox_beta_derived.experiment_search_events_live_v1`](https://github.com/mozilla/bigquery-etl/tree/master/sql/moz-fx-data-shared-prod/org_mozilla_firefox_beta_derived/experiment_search_events_live_v1/init.sql)
