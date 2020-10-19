# Events Daily

<!-- toc -->

## Introduction

`org_mozilla_firefox.events_daily` is designed to answer questions about events. These include:

- Funnels
- Event Counts
- User Flows

## Contents

`events_daily` has one row per-client per-day, much the same as `clients_daily`. The table is created in a two-step process:

1. An ancillary table, `event_types`, is updated with the new events seen on that day. Each event is mapped to a unique
   unicode character, and each event property (the `extras` fields) are also mapped to a unique unicode character.
2. For every user, that day's events are mapped to their associated unicode characters (including `event_properties`).
   The strings are aggregated and comma-separated, giving a single ordered string that represents all of that user's
   events on that day.

For Fenix, we aggregate the events ping data _only_. If you're looking for events in other pings, you'll need to query them directly.

Included in this data is a set of dimensional information about the user, also derived from the events ping. The full list of fields is available [in the query](https://github.com/mozilla/bigquery-etl/blob/master/sql/moz-fx-data-shared-prod/org_mozilla_firefox_derived/events_daily_v1/query.sql#L48).

## Limitations

This approach makes some queries fast and easy, but has some limits:

1. Each product is limited to at most 1 Million unique event types
2. Each event property is limited to at most 1 Million values. As a result, [some Fenix event properties are not included in this table](https://github.com/mozilla/bigquery-etl/blob/ad84a15d580333b41d36cfe8331e51238f3bafa1/sql/moz-fx-data-shared-prod/org_mozilla_firefox_derived/event_types_v1/query.sql#L89).
3. Queries do not know the amount of time that passed between events, only that they occurred on the same day
   _Note_: This can be alleviated by sessionizing and splitting the events string using a `session_start` event.
   For Fenix this could be [`events.app_opened_all_startup`](https://github.com/mozilla-mobile/fenix/blob/master/app/metrics.yaml#L11).

## Accessing the Data

While it is possible to build queries that access this events data directly, the Data Platform instead recommends using a set of stored procedures we have available.
These procedures create BigQuery views that hide the complexity of the event representation. The [`mozfun` library documentation](https://mozilla.github.io/bigquery-etl/mozfun/event_analysis/)
has information about these procedures and examples of their usage.

## Data Reference

### Example Queries

This query gives the event-count and client-counts per-event per-day.

```sql
SELECT
  submission_date,
  category,
  event,
  COUNT(*) AS client_count,
  SUM(count) AS event_count
FROM
  `moz-fx-data-shared-prod`.org_mozilla_firefox.events_daily
CROSS JOIN
  UNNEST(mozfun.event_analysis.extract_event_counts(events))
JOIN
  `moz-fx-data-shared-prod`.org_mozilla_firefox.event_types
  USING (index)
WHERE
  submission_date >= DATE_SUB(current_date, INTERVAL 28 DAY)
GROUP BY
  submission_date,
  category,
  event
```

[Link to a dashboard using this query in STMO](https://sql.telemetry.mozilla.org/dashboard/fenix-events).

## Scheduling

This dataset is scheduled on Airflow and updated daily.

## Schema

As of 2020-10-01, the current version of `events_daily` is v1, and has a schema as follows:

```
root
    |- submission_date: date
    |- client_id: string
    |- events: string
    |- android_sdk_version: string
    |- app_build: string
    |- app_channel: string
    |- app_display_version: string
    |- architecture: string
    |- device_manufacturer: string
    |- device_model: string
    |- first_run_date: string
    |- telemetry_sdk_build: string
    |- locale: string
    |- city: string
    |- country: string
    |- subdivision1: string
    |- channel: string
    |- os: string
    |- os_version: string
    |- experiments: record
    |  |- key: string
    |  |- value: string
```

## Code Reference

The job is [defined in `bigquery-etl`](https://github.com/mozilla/bigquery-etl/blob/master/sql/moz-fx-data-shared-prod/org_mozilla_firefox_derived/events_daily_v1/query.sql).
The job for updating `event_types` is [also defined in `bigquery-etl`](https://github.com/mozilla/bigquery-etl/blob/master/sql/moz-fx-data-shared-prod/org_mozilla_firefox_derived/event_types_v1/query.sql).

## Background and Caveats

See [this presentation](https://docs.google.com/presentation/d/1hY82h_hP-pJd1j_7PsPPHn469XIQ7p4BfTH3aqRpYTk) for background.
