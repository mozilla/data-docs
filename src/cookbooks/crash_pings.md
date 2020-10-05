# Working with Crash Pings

You can use the following snippets to start querying [crash pings](../datasets/pings.md#crash-ping) with [STMO](../tools/stmo.md) and
[BigQuery](../cookbooks/bigquery.md). Using these tools, you can quickly get counts
and other information about crash pings that are submitted day-to-day.

The following example just counts all existing pings for a few days across several dimensions:

```sql
SELECT date(submission_timestamp) AS crash_date,
       count(*) AS crash_count
FROM telemetry.crash
WHERE date(submission_timestamp) >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
GROUP BY crash_date
```

[Link to query in STMO](https://sql.telemetry.mozilla.org/queries/67925/).

Although the total crash counts is not always useful, you may want to restrict
a query to a channel or some other dimensions, and also facet the results. Therefore, you can add a few more fields to the SQL:

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

[Link to query in STMO](https://sql.telemetry.mozilla.org/queries/67927/)

These are just initial examples. You can query across all the fields in
a telemetry crash ping, which provides useful information about the crashes themselves. You can view a summary of the available fields in the STMO schema browser, referring to [the documentation on the Firefox crash ping](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/data/crash-ping.html)
for more information where necessary.
