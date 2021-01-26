# Non-Desktop Day 2-7 Activation

<!-- toc -->

# Introduction

`firefox_nondesktop_day_2_7_activation` is designed for use in calculating the [Day 2-7 Activation metric](../../../metrics/metrics.md#day-2-7-activation), a key result in 2020 for non-desktop products.

# Contents

`firefox_nondesktop_day_2_7_activation` is a table with two key metrics: `new_profiles` and `day_2_7_activated`, aggregated over `submission_date`. It is derived from the [non-desktop clients last seen table](https://docs.telemetry.mozilla.org/cookbooks/clients_last_seen_bits.html).

- `new_profiles`: Unique count of client ids with a given profile creation date. As not all initial pings are received exactly on the day of profile creation, we wait for 7 days after the profile creation date before establishing the New Profile cohort to ensure the data is complete.
- `days_2_7_activated`: Unique count of client ids who use the product at any point starting the day after they created a profile up to 6 days after.
  We also include a variety of dimension information (e.g. `product`, `app_name`, `app_version`, `os`, `normalized_channel` and `country`) to aggregate on.

This dataset is backfilled through 2017-01-01.

# Accessing the Data

Access the data at [`moz-fx-data-shared-prod.telemetry.firefox_nondesktop_day_2_7_activation`](https://console.cloud.google.com/bigquery?project=moz-fx-data-shared-prod&p=moz-fx-data-shared-prod&d=telemetry&t=firefox_nondesktop_day_2_7_activation&page=table)

# Data Reference

## Example Queries

This query gives the `day 2-7 activation` by product:

```sql
SELECT
  cohort_date,
  product,
  SUM(day_2_7_activated) as day_2_7_activated,
  SUM(new_profiles) as new_profiles,
  SAFE_DIVIDE(SUM(day_2_7_activated), SUM(new_profiles)) as day_2_7_activation
FROM
  mozdata.telemetry.firefox_nondesktop_day_2_7_activation
WHERE
  cohort_date = "2020-03-01"
GROUP BY 1,2
ORDER BY 1
```

[Link to query in STMO](https://sql.telemetry.mozilla.org/queries/72054)

## Scheduling

This dataset is scheduled on Airflow ([source](https://github.com/mozilla/telemetry-airflow/blob/59effc6ead0b764a9ef3d30f40fbdb4b0b3394ec/dags/copy_deduplicate.py#L337)).

## Schema

As of 2020-07-24, the current version of `firefox_nondesktop_day_2_7_activation` is v1, and has a schema as follows:

```
root
    |- submission_date: date
    |- product: string
    |- app_name: string
    |- app_version: string
    |- os: string
    |- normalized_channel: string
    |- country: string
    |- new_profiles: integer
    |- day_2_7_activated: integer
```

# Code Reference

The `firefox_nondesktop_day_2_7_activation job is` [defined in `bigquery-etl`](https://github.com/mozilla/bigquery-etl/blob/master/sql/moz-fx-data-shared-prod/telemetry_derived/firefox_nondesktop_day_2_7_activation_v1/query.sql).

# Background and Caveats

Due to the delay in receiving all the initial pings and subsequent 7 day wait prior to establishing the new profile cohort, the table will lag `nondesktop_clients_last_seen` by 7 days.
