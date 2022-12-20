# Working with Live Data

Live ping tables are the final destination for the telemetry ingestion pipeline. Incoming ping data is loaded into these tables approximately every 10 minutes, though a delay of up to 30 minutes is normal. Data in these tables is set to expire after 30 days.

Data from live ping tables is expected to be accessed through user-facing views. The names of all views accessing live data should include the `_live` suffix (for example `monitoring.topsites_click_rate_live`). Live tables are generally clustered and partitioned by `submission_timestamp`, which allows for writing more efficient queries that filter over short time windows. When querying live data by running the same query multiple times ensure that query caching is turned off, otherwise newly arrived data might not appear in the query results.

Of note, user-facing views for live ping tables, like the ones for historical ping tables, will not automatically be provisioned. Instead, it is expected for live views to be more curated, with each view being tied to a specific use case.

Live tables in `_derived` datasets can be queried from Redash and Looker, however it is best practice to set up user-facing views for accessing the data.

## Using Materialized Views

When creating a view on live data, engineers should consider the specific use cases for the view and do some analysis of the cost associated with query patterns. In particular, cost will likely be an issue if the view is going to be used for some type of monitoring that involves frequent queries on Firefox-scale data. [BigQuery offers support for materialized views](https://cloud.google.com/bigquery/docs/materialized-views-intro). Materialized views are precomputed views that periodically cache the results of a query for increased performance and efficiency. Creating a materialized view that provides the relevant aggregates will be a significant cost savings when working with a large volume of live data.

When a materialized view is appropriate, it should be created in a relevant `_derived` dataset with a version suffix (following the same conventions as we do for derived tables populated via scheduled queries). It is then made user-facing via a simple `SELECT * FROM my_materialized_view` virtual view in a relevant user-facing dataset. More complex cases may need to union together multiple materialized views at this user-facing view level.

It is generally recommended that materialized views over live data have `enable_refresh=true` and `refresh_interval_minutes=10`. The `refresh_interval_minutes` parameter determines the minimum time between refreshes.

Although partition expiration of a materialized view is inherited from the underlying table, each materialized view should include an explicit start date in a `WHERE` clause to limit the amount of data scanned for an initial backfill and that date should be advanced any time the view is recreated. Be aware that any change to the schema of the base table will invalidate the entire materialized view, meaning that the next scheduled refresh will incur a full backfill; keep this in mind when estimating cost of a materialized view.

Definitions for materialized views live in the [bigquery-etl repository](https://github.com/mozilla/bigquery-etl) and usually have the following structure:

```sql
CREATE MATERIALIZED VIEW
IF NOT EXISTS my_dataset_derived.my_new_materialized_view_live_v1
  OPTIONS
    (enable_refresh = TRUE, refresh_interval_minutes = 10)
  AS
    SELECT
      submission_timestamp,
      some_interesing_columns
    FROM
      `moz-fx-data-shared-prod.dataset_live.events_v1`
    submission_timestamp > DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAYS)  -- limit amount of data to be backfilled ($$$)
```

## Tools for Visualizing Live Data

Currently, live data in BigQuery could be considered "near real time" or nearline (as opposed to online), with latency usually below 1 hour to each live table in our ingestion-sink code base.

For near real time product monitoring use cases, it is recommended to use Looker for hosting dashboards that refresh on a regular interval such as every 10 minutes.

For real time operational monitoring use cases, it is recommended to rely on centralized SRE monitoring infrastructure, namely the InfluxCloud-hosted Grafana instance or the Stackdriver UI in the GCP console. For dashboards mixing monitoring data and (Mozilla Confidential) BigQuery data, then it should be possible to serve that need through the SRE Grafana infrastructure.

## Access Controls for Services Accessing Live Data in BigQuery

So far giving services access to the full data warehouse has been avoided, instead it is preferred to grant access only to the specific tables needed to support a documented use case. This reduces the possibility of data warehouse changes inadvertently breaking a consuming service.
When provisioning BigQuery access to a Mozilla service, it is recommended to create a use case-specific authorized view, granting the service access only to that specific view. It is also acceptable to grant the service access to a user-facing virtual view and all underlying tables or materialized views being referenced.
