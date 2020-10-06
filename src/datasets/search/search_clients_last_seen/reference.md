# Search Clients Last Seen

<!-- toc -->

# Introduction

{{#include ./intro.md}}

# Data Reference

## Example Queries

[This retention query](https://sql.telemetry.mozilla.org/queries/70349/source#177176)
gives the WoW retention of users in different segments. Similar to GUD, a user is
considered retained if they do they same activity the next week. Note here the
outage from Armagaddon, and the outage for ad click telemetry in October.

[This query](https://sql.telemetry.mozilla.org/queries/70348/source#177160)
shows the amount of different search activity taken by clients. We can use it
to determine the % of clients who partake in each activity, regardless of their
baseline amount of activity.

## Scheduling

This dataset is scheduled on Airflow
([source](https://github.com/mozilla/bigquery-etl/blob/ad84a15d580333b41d36cfe8331e51238f3bafa1/dags/bqetl_search.py#L52)).

## Schema

As of 2020-04-22, the current version of `search_clients_last_seee` is `v1`,
and has a schema as follows.
It's backfilled through 2020-01-01

```
root
    |- submission_date: date
    |- client_id: string
    |- sample_id: integer
    |- country: string
    |- app_version: string
    |- distribution_id: string
    |- locale: string
    |- search_cohort: string
    |- addon_version: string
    |- os: string
    |- channel: string
    |- profile_creation_date: integer
    |- default_search_engine: string
    |- default_search_engine_data_load_path: string
    |- default_search_engine_data_submission_url: string
    |- profile_age_in_days: integer
    |- active_addons_count_mean: float
    |- user_pref_browser_search_region: string
    |- os_version: string
    |- max_concurrent_tab_count_max: integer
    |- tab_open_event_count_sum: integer
    |- active_hours_sum: float
    |- subsession_hours_sum: float
    |- sessions_started_on_this_day: integer
    |- organic: integer
    |- sap: integer
    |- unknown: integer
    |- tagged_sap: integer
    |- tagged_follow_on: integer
    |- ad_click: integer
    |- search_with_ads: integer
    |- total_searches: integer
    |- tagged_searches: integer
    +- engine_searches: record (repeated)
    |  |- key: string
    |  +- value: record
    |  |  |- total_searches: integer (repeated)
    |  |  |- tagged_searches: integer (repeated)
    |  |  |- search_with_ads: integer (repeated)
    |  |  |- ad_click: integer (repeated)
    |- days_seen_bytes: bytes
    |- days_searched_bytes: bytes
    |- days_tagged_searched_bytes: bytes
    |- days_searched_with_ads_bytes: bytes
    |- days_clicked_ads_bytes: bytes
    |- days_created_profile_bytes: bytes
```

# Code Reference

The `search_clients_last_seen` job is
[defined in `bigquery-etl`](https://github.com/mozilla/bigquery-etl/blob/master/sql/moz-fx-data-shared-prod/search_derived/search_clients_last_seen_v1/query.sql)

[search data documentation]: ../../search.md
