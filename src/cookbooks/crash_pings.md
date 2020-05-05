# Working with Crash Pings

Here are some snippets to get you started querying [crash pings](../datasets/pings.md#crash-ping) with [STMO](../tools/stmo.md) and 
[BigQuery](./bigquery.md). Using these tools, you can quickly get counts 
and other information on the nature of crash pings submitted day-to-day.

The simplest example is probably just to count all existing pings for a few days
across some dimensions: 

```sql
SELECT date(submission_timestamp) AS crash_date,
       count(*) AS crash_count
FROM telemetry.crash
WHERE date(submission_timestamp) >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
GROUP BY crash_date
```

You can see an example of this query, along with a simple graph in [this STMO query](https://sql.telemetry.mozilla.org/queries/67925/).

Normally, looking at total crash counts isn't so useful: you usually want to restrict
a query to a channel or some other dimensions, and also facet the results. This can
be done by adding a few more fields to our SQL:

```sql
SELECT date(submission_timestamp) AS crash_date,
       normalized_os AS os,
       count(*) AS crash_count
FROM telemetry.crash
WHERE date(submission_timestamp) >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
  AND normalized_channel='nightly'
GROUP BY normalized_os,
         crash_date
```

Here's [another STMO query](https://sql.telemetry.mozilla.org/queries/67927/) showing this in action.

These are just initial examples: it is possible to query across all the fields in
a telemetry crash ping, which can give you useful information about the crashes themselves. You can see a summary of the available fields in the STMO schema
browser, referring to [the documentation on the Firefox crash ping](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/data/crash-ping.html)
for more information where necessary.
