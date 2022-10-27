# Active Users Aggregates reference

<!-- toc -->

## Introduction

The `active_users_aggregates` is a set of 3 tables designed to analyze clients
activity on a daily basis, starting from the date of installation.
These aggregates are created to support the migration of the GUD
Growth and Usage Dashboard.

Here is the link to the [proposal](https://docs.google.com/document/d/1qvWO49Lr_Z_WErh3I3058A3B1YuiuURx19K3aTdmejM/edit?usp=sharing)
for implementation.

## Contents and access to the data

You can access each aggregate directly in BigQuery by querying the view
or in Looker using the link to the corresponding Looker explore.

#### `telemetry.active_users_aggregates`
This aggregates contains the metrics daily, weekly and monthly active users,
as well as new profile and search counts aggregated by Mozilla product and
business dimensions: attribution parameters, channel, country, city, date,
device model, distribution id, segment and OS details.

Explore [`active_users_aggregates`](https://mozilla.cloud.looker.com/explore/combined_browser_metrics/active_users_aggregates) in Looker.

#### `telemetry.active_users_aggregates_device`
This aggregate contains the metrics daily, weekly and monthly active users
as well as new profiles and search counts to analyze data per device.

The reason to have this aggregate in addition to `active_users_aggregates` is to
improve the query performance for final users, by separating the analysis per
device, which is the biggest size column in the table, as most devices have
unique identifiers.

Explore [`active_users_aggregates_device`](https://mozilla.cloud.looker.com/explore/combined_browser_metrics/active_users_aggregates_device) in Looker.

#### `telemetry.active_users_aggregates_attribution`
This aggregate contains the metrics daily, weekly and monthly active users
as well as new profiles and search counts to analyze where
the installations come from and the `cohorts` behaviour. This information is
retrieved by the attribution parameters and complemented with the core
dimensions: country, submission_date, `app_name` and if the browser is
set to default.

The reason to have this aggregate in addition to `active_users_aggregates`
is to improve the query performance for final users, by separating the analysis
of the numerous attribution parameters, which is required with less regularity
than other dimensions and mostly for specific purposes. E.g. During
investigations or marketing campaigns.

Explore [`active_users_aggregates_attribution`](https://mozilla.cloud.looker.com/explore/combined_browser_metrics/active_users_aggregates_attribution) in Looker.

## Looker visualizations with period over period analysis
The `Usage` folder for [Mobile and Desktop browsers](https://mozilla.cloud.looker.com/folders/748)
includes a set of visualizations that you can access directly and are enhanced
with the period over period analysis.

![img.png](img.png)

## Scheduling

These datasets are scheduled in the Airflow DAG
[`bqetl_analytics_aggregations`](https://workflow.telemetry.mozilla.org/home?search=bqetl_analytics_aggregations)
and updated daily.

## Code Reference

The query and metadata for the aggregates is defined in the corresponding
sub-folder in bigquery-etl under [`telemetry_derived`](https://github.com/mozilla/bigquery-etl/tree/main/sql/moz-fx-data-shared-prod/telemetry_derived).
