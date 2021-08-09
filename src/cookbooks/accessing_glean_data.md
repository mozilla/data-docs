# Accessing Glean Data in BigQuery

This document describes how to access Glean data using BigQuery, such as in [Redash](https://sql.telemetry.mozilla.org).
This is intended for in-depth analysis: [GUD](../introduction/tools.md#mozilla-growth--usage-dashboard-gud) or [GLAM](../introduction/tools.md#glean-aggregated-metrics-dashboard-glam) can answer many simple questions.

The data that Glean applications generates maps cleanly to structures we create in
BigQuery: see the section on [Glean Data](../concepts/pipeline/glean_data.md) in the data pipeline
reference. The exact method to use depends on the metric type you want to access.

<!-- toc -->

## Counter, boolean, and most other metrics

Most metrics Glean collects map to a single column in a BigQuery table.
The [Glean Dictionary] shows the mapping to access these mappings
when writing queries.
For example, say you wanted to get a count of top sites as measured in Firefox for Android.
You can get the information you need to build your query by following this procedure:

- Go to the [Glean Dictionary] home page.
- Navigate to the [Firefox for Android application]
- Under metrics, search for "top", select [`metrics.top_sites_count`](https://dictionary.protosaur.dev/apps/fenix/metrics/metrics_top_sites_count).
- Scroll down to the bottom. Under BigQuery, you should see an entry like: "In `org_mozilla_fenix.metrics` as `metrics.counter.metrics_top_sites_count`".
  The former corresponds to the table name whilst the latter corresponds to the column name.
  You can select which channel you want to view information for and the table name will update accordingly.

With this information in hand, you can now proceed to writing a query. For example, to get the
average of this metric on the first of January, you could write something like this:

```sql
-- Count number of pings where Fenix is the default browser
SELECT
  AVG(metrics.counter.metrics_top_sites_count)
FROM
  -- We give the table an alias so that the table name `metrics` and field name
  -- `metrics` don't conflict.
  org_mozilla_fenix.metrics AS m
WHERE
  date(submission_timestamp) = '2021-01-01'
```

Note that we alias the table used in the query, otherwise the BigQuery parser gets confused.
This can also happen with the tables and columns corresponding to the events ping.
Another option is to explicitly qualify the table when selecting the column (so `metrics.counter.metrics_top_sites_count` becomes `metrics.metrics.counter.metrics_top_sites_count`):

```sql
SELECT AVG(metrics.metrics.counter.metrics_top_sites_count)
FROM org_mozilla_fenix.metrics
WHERE DATE(submission_timestamp) = '2021-01-01'
```

## Event metrics

Event metrics are stored slightly differently: since each ping sent by a Glean application sends a _group_ of metrics, they are mapped into a set of records within a single column.
To query them individually, you need to unnest them into their own table.
For example, let's say you wanted to investigate the foreground metrics for tab engine.
You can get the information you need to build your query by following this procedure:

- Go to the [Glean Dictionary] home page.
- Navigate to the [Firefox for Android application]
- Under metrics, search for "foreground", select [`engine_tab.foreground_metrics`](https://dictionary.telemetry.mozilla.org/apps/fenix/metrics/engine_tab_foreground_metrics).
- Scroll down to the bottom until you see "Access". Under BigQuery, you should see an entry like: "In `org_mozilla_fenix.events`".

This tells you the BigQuery table in which this data is stored.
With this information, plus knowledge of the metric's category (`engine_tab`) and name (`foreground_metrics`) we now know enough to write a simple query:

```sql
WITH events AS (
SELECT
    submission_timestamp,
    client_info.client_id,
    event.timestamp AS event_timestamp,
    event.category AS event_category,
    event.name AS event_name,
    event.extra AS event_extra,
FROM org_mozilla_fenix.events AS e
CROSS JOIN UNNEST(e.events) AS event
WHERE
    submission_timestamp = '2021-05-03'
    AND sample_id = 42 -- 1% sample for development
    AND event.category = 'engine_tab'
    AND event.name = 'foreground_metrics'
)
SELECT * FROM events
```

The extra fields are stored as a structure. For more information on accessing those, see [accessing map-like fields in the querying documentation](./bigquery/querying.md#accessing-map-like-fields).

[glean dictionary]: https://dictionary.telemetry.mozilla.org
[firefox for android application]: https://dictionary.telemetry.mozilla.org/apps/fenix
