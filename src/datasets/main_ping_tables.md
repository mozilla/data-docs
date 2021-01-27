# Main Ping Tables

As described in the [pipeline schemas deployment docs](https://docs.telemetry.mozilla.org/concepts/pipeline/schemas.html),
data engineering has a process of generating schemas for pings and deploying them to BigQuery. The Main Ping table (`telemetry.main`)
is one of those generated tables.

## Problems Querying the Main Ping Table: `telemetry.main`

Because we generate a schema with all of the probes for the main ping, the number of columns has grown by a large amount: at this point,
there are over 10k columns. When querying this table, it causes [BQ to scan a very large number of files](https://console.cloud.google.com/support/cases/detail/25679061?project=moz-fx-data-shared-prod).
An end-user will see this as a _very_ slow query. Queries remain slow even when filtering on clustered columns, like `sample_id`.

To reduce the time for querying main ping data, we have included two new tables: `telemetry.main_1pct`, and `telemetry.main_nightly`.

# Main Ping Sample: `telemetry.main_1pct`

This table includes a 1% sample across all channels from `telemetry.main`. It includes 6 months of history.

# Nightly Main Ping Data: `telemetry.main_nightly`

This table includes only data from the nightly release channel. It includes 6 months of history.
