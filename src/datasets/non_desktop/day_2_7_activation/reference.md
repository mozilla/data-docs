# Non Desktop Day 2 - 7 Activation  

<!-- toc -->

# Introduction
`firefox_nondesktop_day_2_7_activation` is designed for use in calculating the day 2-7 activation metric, a key result in 2020 for the nondesktop products.


# Contents
`firefox_nondesktop_day_2_7_activation` is an aggregate table with two key metrics: `new_profiles` and `day_2_7_activated`. These are primarily aggregated by `submission_date`.

- `new_profiles`: Unique count of client ids with a given profile creation date. As not all initial pings are received exactly on the day of profile creation, we wait for 7 days after the profile creation date before establishing the New Profile cohort to ensure the data is complete.
- `days_2_7_activated`: Unique count of client ids who use the product at any point starting the day after they created a profile up to 6 days after.

Due to the delay in receiving all the initial pings and subsequent 7 day wait prior to establishing the new profile cohort, the table will lag other daily usage nondesktop tables e.g. `nondesktop_clients_last_seen` by 7 days. 

We also include a variety of dimension information (e.g. `product`, `app_name`, `app_version`, `os`, `normalized_channel` and `country`) to aggregate on. 

# Background and Caveats
Currently (as of Aug 24 2020) Fenix and Firefox Preview are not included in the table. These products ping sending schedules are not similar to the other products and thus would not be a fair comparison. Work is undergoing to make the reporting comparable and Fenix and Firefox Preview will be included once this is complete. Please see [JIRA DS-696](https://jira.mozilla.com/browse/DS-696) and [JIRA DS-1018](https://jira.mozilla.com/browse/DS-1018) for more information and current status.

# Accessing the Data
Access the data at [`moz-fx-data-shared-prod.telemetry.firefox_nondesktop_day_2_7_activation`](https://console.cloud.google.com/bigquery?project=moz-fx-data-shared-prod&p=moz-fx-data-shared-prod&d=telemetry&t=firefox_nondesktop_day_2_7_activation&page=table)

# Data Reference
## Example Queries
[This activation query](https://sql.telemetry.mozilla.org/queries/72054/source) gives the `day 2-7 activation` by product. A new profile is considered activated if the client uses the browser at any point starting 1 day up to 6 days after the `profile creation date`.

## Scheduling
This dataset is scheduled on Airflow ([source](https://github.com/mozilla/telemetry-airflow/blob/59effc6ead0b764a9ef3d30f40fbdb4b0b3394ec/dags/copy_deduplicate.py#L337)).

## Schema
As of 2020-07-24, the current version of firefox_nondesktop_day_2_7_activation is v1, and has a schema as follows. It's backfilled through 2017-01-01
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
The firefox_nondesktop_day_2_7_activation job is [defined in `bigquery-etl`](https://github.com/mozilla/bigquery-etl/blob/master/sql/telemetry_derived/firefox_nondesktop_day_2_7_activation_v1/query.sql).

