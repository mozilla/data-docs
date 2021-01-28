# Main Ping Tables

As described in the [pipeline schemas deployment docs](https://docs.telemetry.mozilla.org/concepts/pipeline/schemas.html),
data engineering has a process of generating schemas for pings and deploying them to BigQuery. The Main Ping table (`telemetry.main`)
is one of those generated tables.

As the number of telemetry probes defined in Firefox grows, so does the number of columns in `telemetry.main`. As of January 2021, we have nearly 10,000 columns, and we ingest many terabytes of main ping data per day. This combination of a very wide schema and a high data volume means that [BigQuery has to reference metadata for a very large number of files](https://console.cloud.google.com/support/cases/detail/25679061?project=moz-fx-data-shared-prod) each time it runs a query, even if it only ends up needing to read a small fraction of those files. This has led to a problematic experience for iterative analysis use cases.

To reduce the time for querying main ping data, we have included two new tables: `telemetry.main_1pct`, and `telemetry.main_nightly`. These can return results for simple queries in a matter of seconds where a logically equivalent query on `telemetry.main` may take minutes.

## Main Ping Sample: `telemetry.main_1pct`

This table includes a 1% sample across all channels from `telemetry.main` (`sample_id = 0`).
It includes 6 months of history.

It includes an additional `subsample_id` field that is similar to `sample_id` and allows
efficient sampling for even smaller population sizes. The following query would reflect
a 0.01% sample (one thousandth) of the total desktop Firefox population:

```sql
SELECT
  COUNT(*) AS n
FROM
  mozdata.telemetry.main_1pct
WHERE
  subsample_id = 0
  AND DATE(submission_timestamp) = '2021-01-01'
```

The choice of implementation for `subsample_id` is not particularly well vetted;
it's simply chosen to be a hash that's stable, has a reasonable
avalanche effect, and is _different_ from `sample_id`.
The definition is `MOD(ABS(FARM_FINGERPRINT(client_id)), 100) AS subsample_id`
which is the same approach we use for choosing `id_bucket` in Exact MAU tables.

## Nightly Main Ping Data: `telemetry.main_nightly`

This table includes only data from the nightly release channel (`normalized_channel = 'nightly'`).
It includes 6 months of history.
