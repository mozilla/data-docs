# Events Daily

<!-- toc -->

## Introduction

The `events_daily` datasets can help answer questions about sequences of events (sometimes called "funnels").
It is used by the [Event Funnel Analysis Explore in Looker], but can also be queried directly using BigQuery.

As of this writing, variations of the `events_daily` dataset are available for Firefox Desktop, Firefox for Android, and Mozilla VPN.

[event funnel analysis explore in looker]: ../../../cookbooks/looker/funnel_analysis_explore.md

## Contents

`events_daily` has one row per-client per-day, much the same as `clients_daily`. The table is created in a two-step process:

1. An ancillary table, `event_types`, is updated with the new events seen on that day. Each event is mapped to a unique unicode character, and each event property (the `extras` fields) is also mapped to a unique unicode character.
2. For every user, that day's events are mapped to their associated unicode characters (including `event_properties`). The strings are aggregated and comma-separated, giving a single ordered string that represents all of that user's events on that day.

For most products, only events in the Glean [events ping] are aggregated (Firefox Desktop currently aggregates events in the [legacy desktop "event" ping]).
If you're looking for events sent in other pings, you'll need to query them directly.

Included in this data is a set of dimensional information about the user, also derived from the events ping.
The full list of fields is available in the [templated source query].

[events ping]: https://mozilla.github.io/glean/book/user/pings/events.html
[legacy desktop "event" ping]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/data/event-ping.html
[templated source query]: https://github.com/mozilla/bigquery-etl/blob/main/bigquery_etl/events_daily/query_templates/events_daily_v1/query.sql

## Limitations

This approach makes some queries fast and easy, but has some limits:

1. Each product is limited to at most 1 million unique event types
2. Each event property is limited to a set number of values ([currently set to 1000 for most products]). As a result, some properties will not be accessible in the table.
3. Queries do not know the amount of time that passed between events, only that they occurred on the same day. This can be alleviated by sessionizing and splitting the events string using an event which indicates the start of a session. For example, for Firefox for Android, this could be [`events.app_opened`].

[currently set to 1000 for most products]: https://github.com/mozilla/bigquery-etl/blob/128083330cccf27923366109686aa83b5bb17e4d/bigquery_etl/events_daily/query_templates/event_types_history_v1/templating.yaml#L10
[`events.app_opened`]: https://dictionary.telemetry.mozilla.org/apps/fenix/metrics/events_app_opened

## Accessing the Data

While it is possible to build queries that access this events data directly, the Data Platform instead recommends using a set of stored procedures we have available.
These procedures create BigQuery views that hide the complexity of the event representation.
The [`mozfun` library documentation] has information about these procedures and examples of their usage.

[`mozfun` library documentation]: https://mozilla.github.io/bigquery-etl/mozfun/event_analysis/

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
  `moz-fx-data-shared-prod`.fenix.events_daily
CROSS JOIN
  UNNEST(mozfun.event_analysis.extract_event_counts(events))
JOIN
  `moz-fx-data-shared-prod`.fenix.event_types
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

## Code Reference

The source for events daily is defined inside bigquery-etl as a set of templated queries which generate the `events_daily` tables as well as the dependent `event_types` tables for each supported application.
You can find the source under [bigquery_etl/sql_generators](https://github.com/mozilla/bigquery-etl/tree/main/sql_generators/events_daily).

## Background and Caveats

See [this presentation](https://docs.google.com/presentation/d/1hY82h_hP-pJd1j_7PsPPHn469XIQ7p4BfTH3aqRpYTk) for background.
