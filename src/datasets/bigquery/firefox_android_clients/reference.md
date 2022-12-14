# Firefox Android Clients reference

<!-- toc -->

## Introduction

The table `fenix_derived.firefox_android_clients` contains the first observations
for Firefox Android clients retrieved from the ping that reports first from:
baseline, `first_session` and metrics pings.

The goals of this table, as described in the
[proposal](https://docs.google.com/document/d/12bj4DhCybelqHVgOVq8KJlzgtbbUw3f68palNrv-gaM/):

- Enable client segmentation based on the attribution dimensions
  e.g. `adjust_campaign`, install source.
- Facilitate the investigation of data incidents and identifying the root cause
  when of one or more metrics deviate from the expected values, by segmenting it
  using different dimensions.
- Enable identifying bugs and data obtained via bots i.e. BrowserStack.
- Serve as the baseline to complement Glean's `first_session` ping for mobile browsers
  in order to use it as a single source for first reported attributes.
- Serve as a baseline to create a `first_session` ping for Firefox Desktop.

## Contents

The table granularity is one row per `client_id`.

It contains the attribution, isp, `os_version`, device, channel and first
reported country for each client. The field descriptions are fully
documented in BigQuery.

This table contains data only for channel `release`, since it's the only
channel where data is available in the `first_session` ping at the time
of implementation and suffices for the goals. Also, data is available
since August 2020, when the migration from Fennec to Fenix took place.

## Scheduling

Incremental updates happen on a daily basis in the Airflow DAG
[`bqetl_analytics_tables`](https://workflow.telemetry.mozilla.org/home?search=bqetl_analytics_tables)

The table is built and initialized using the `init.sql` file and
is incrementally updated using `query.sql`, including the update of
historical records when the attribution details are received from pings
that arrive to the server after the `first_seen` date.

## Code Reference

The query and metadata for the aggregates is defined in the corresponding
sub-folder in `bigquery-etl` under
[`fenix_derived`](https://github.com/mozilla/bigquery-etl/tree/main/sql/moz-fx-data-shared-prod/fenix_derived/firefox_android_clients_v1).

## How to query

This table should be accessed through the user-facing view
`fenix.firefox_android_clients` which implements additional
business logic for grouping attribution data, using a simple
join with the `client_id`.

For analysis purposes, it's important to use the business date
`first_seen_date` for filtering, which corresponds to the date when
the baseline ping is actually collected on the client side.
