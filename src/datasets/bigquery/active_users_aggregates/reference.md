# Active Users Aggregates reference

<!-- toc -->

## Introduction

The `active_users_aggregates` is a set of 3 tables designed to analyze clients
activity on a daily basis, starting from the date of installation.
These aggregates are created to support the migration of the GUD
Growth and Usage Dashboard.

Here is the link to the [proposal](https://docs.google.com/document/d/1qvWO49Lr_Z_WErh3I3058A3B1YuiuURx19K3aTdmejM/edit?usp=sharing).

## Contents

#### Active users aggregates
This aggregates contains the metrics daily, weekly and monthly active users,
as well as new profile and search counts aggregated by Mozilla product and
business dimensions: attribution parameters, channel, country, city, date,
device model, distribution id, segment and OS details.

#### Active users aggregates for device
The `active_users_aggregates_device` contains the metrics of
daily, weekly and monthly active users, new profiles and search counts
to analyze data per device.

The reason to have this aggregate in addition to `active_users_aggregates`
is to improve the query performance for final users, by separating the
device analysis, which makes one of the biggest size columns in the table,
as most devices have unique identifiers.

#### Active users aggregates for attribution
The `active_users_aggregates_attribution` contains the metrics of
daily, weekly and monthly active users, new profiles and search counts
to analyze the source and context of client installations and the `cohorts`
behaviour.
It can be used to query the set attribution parameters in the context
of the business core dimensions: country, submission_date, `app_name`
and if the browser is set to default.

The reason to have this aggregate in addition to `active_users_aggregates`
is to improve the query performance for final users, by separating the
analysis of the numerous attribution parameters, which is required with
less regularity  than other dimensions and mostly for specific purposes.
E.g. During investigations or marketing campaigns.

## Scheduling

These datasets are scheduled to update daily in the Airflow DAG
[`bqetl_analytics_aggregations`](https://workflow.telemetry.mozilla.org/home?search=bqetl_analytics_aggregations)

## Code Reference

The query and metadata for the aggregates is defined in the corresponding
sub-folder in bigquery-etl under
[`telemetry_derived`](https://github.com/mozilla/bigquery-etl/tree/main/sql/moz-fx-data-shared-prod/telemetry_derived).

## How to query

| Dataset | BigQuery | Looker |
|---|---|---|
| `active_users_aggregates` | Table `telemetry.active_users_aggregates` | [Explore](https://mozilla.cloud.looker.com/explore/combined_browser_metrics/active_users_aggregates) |
| `active_users_aggregates_device` | Table `telemetry.active_users_aggregates_device` | [Explore](https://mozilla.cloud.looker.com/explore/combined_browser_metrics/active_users_aggregates_device) |
| `active_users_aggregates_attribution` | Table `telemetry.active_users_aggregates_attribution` | [Explore](https://mozilla.cloud.looker.com/explore/combined_browser_metrics/active_users_aggregates_attribution) |

## Looker visualizations with period over period analysis
The `Usage` folder for [Mobile and Desktop browsers](https://mozilla.cloud.looker.com/folders/748)
includes a set of visualizations that you can access directly and are enhanced
with the period over period analysis.

![img.png](img.png)
