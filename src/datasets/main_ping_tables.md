# Main Ping Tables

As described in the [pipeline schemas deployment docs](https://docs.telemetry.mozilla.org/concepts/pipeline/schemas.html),
data engineering has a process of generating schemas for pings and deploying them to BigQuery. The Main Ping table (`telemetry.main`)
is one of those generated tables.

As the number of telemetry probes defined in Firefox grows, so does the number of columns in `telemetry.main`. At this point, we have nearly 10,000 columns, and we ingest many terabytes of main ping data per day. This combination of a very wide schema and a high data volume means that [BQ has to reference metadata for a very large number of files](https://console.cloud.google.com/support/cases/detail/25679061?project=moz-fx-data-shared-prod) each time it runs a query, even if it only ends up needing to read a small fraction of those files. This has led to a problematic experience for iterative analysis use cases.

To reduce the time for querying main ping data, we have included two new tables: `telemetry.main_1pct`, and `telemetry.main_nightly`. These can return results for simple queries in a matter of seconds where a logically equivalent query on `telemetry.main` may take minutes.

## Main Ping Sample: `telemetry.main_1pct`

This table includes a 1% sample across all channels from `telemetry.main`. It includes 6 months of history.

## Nightly Main Ping Data: `telemetry.main_nightly`

This table includes only data from the nightly release channel. It includes 6 months of history.
