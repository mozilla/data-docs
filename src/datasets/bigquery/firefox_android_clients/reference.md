# Firefox Android Clients reference

<!-- toc -->

## Introduction

The table `firefox_android_clients` contains the first observations for Firefox
Android clients retrieved from the ping that reports first:
baseline, first_session and metrics pings.

The goals of this table, as described in the
[proposal](https://docs.google.com/document/d/12bj4DhCybelqHVgOVq8KJlzgtbbUw3f68palNrv-gaM/):
- Enable client segmentation based on the attribution dimensions
e.g. adjust_campaign, install source.
- Facilitate the investigation of data incidents and identifying the root cause
when of one or more metrics deviate from the expected values, by segmenting it
using different dimensions.
- Enable identifying bugs and data obtained via bots i.e. BrowserStack.
- Serve as the baseline to complement Glean's first_session ping for mobile browsers
in order to use it as a single source for first reported attributes.
- Serve as a baseline to create a first_session ping for Firefox Desktop.

Link to the [proposal](https://docs.google.com/document/d/12bj4DhCybelqHVgOVq8KJlzgtbbUw3f68palNrv-gaM/)

## Contents

The table granularity is one row per client_id.
It contains the attribution, isp, os version, device, channel and first
reported country for each client.
The field descriptions in BigQuery provide additional details of each column.

This table is limited to channel release, since it's the only channel where data
is available in the first_session_ping at the time of implementation.


## Scheduling

This dataset is scheduled to update daily in the Airflow DAG
[`bqetl_analytics_tables`](https://workflow.telemetry.mozilla.org/home?search=bqetl_analytics_tables)

The table is built using the init.sql and updates incrementally using query.sql
and re-writing historical data with the attribution details reported in pings
received by the server after the first_seen date.

## Code Reference

The query and metadata for the aggregates is defined in the corresponding
sub-folder in bigquery-etl under
[`fenix_derived`](https://github.com/mozilla/bigquery-etl/tree/main/sql/moz-fx-data-shared-prod/fenix_derived/firefox_android_clients_v1).

## How to query

This table can be joined using **client_id** and  should be accessed through
the user-facing view `fenix.firefox_android_clients` which implements
additional business logic for the attribution data.

For analysis, consider that the core business date for filtering is
`first_seen_date`, that corresponds to the date when the baseline ping
is actually collected.
