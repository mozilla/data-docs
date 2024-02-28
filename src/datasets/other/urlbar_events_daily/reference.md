# Urlbar Events Daily

## Table of Contents

<!-- toc -->

## Introduction

The `urlbar_events_daily` table, derived from `urlbar_events`, which in turn is derived from Glean `urlbar` events, provides a daily aggregate table across the different user interactions with the urlbar. This data is Desktop-only.

Details on the `urlbar_events` table can be found [here](../urlbar_events/reference.md).

More details about the `urlbar` can be found [here](https://firefox-source-docs.mozilla.org/browser/urlbar/nontechnical-overview.html).

## Use Case

The aim of this table is to provide easy-to-use information to our Business Development partners and Product Management stakeholders. This table gives them accurate, up-to-date, easily accessible data.

This table will also power related dashboards in Looker. Its aim is to speed up processing and display time for dependent dashboards.

## Urlbar events daily table

### Dimensions

This table is grouped by the following dimensions:

- `submission_date`
- `normalized_country_code`
- `normalized_channel`
- `firefox_suggest_enabled`
- `sponsored_suggestions_enabled`
- `product_result_type`

These are the aggregates counts that are available in this table:

- `urlbar_impressions`
- `urlbar_clicks`
- `urlbar_annoyances`
- `urlbar_sessions`

For more information about the exact definition for these metrics, please visit [here](../urlbar_events/reference.md#measurement)

### Scheduling

This dataset is scheduled on Airflow and updated daily.

### Schema

The data is partitioned by `submission_date`.

### Code reference

This table is created from the following
[query](https://github.com/mozilla/bigquery-etl/blob/main/sql/moz-fx-data-shared-prod/firefox_desktop_derived/urlbar_events_daily_v1/query.sql).
