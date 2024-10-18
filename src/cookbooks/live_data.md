# Working with Live Data

Use cases, such as real-time monitoring, dashboards, or personalized user experiences, require low-latency access to data. When working with live data, engineers need to carefully evaluate specific requirements, perform cost analysis on query patterns, and select an appropriate solution from the available options. Cost is a significant factor, particularly in high-frequency query scenarios like monitoring large datasets (e.g., Firefox-scale telemetry). This guide helps in choosing the right approach based on data size and latency needs.

## Options for working with Live Data

| Option                                 | Recommended Use Case                                   | Data Size/Complexity                                 | Latency   | Setup Complexity |
| -------------------------------------- | ------------------------------------------------------ | ---------------------------------------------------- | --------- | ---------------- |
| 1. Querying Live Tables Directly       | Small datasets or infrequent, simple queries           | Low                                                  | 10-30 min | Low              |
| 2. Scheduled queries                   | Medium                                                 | Periodic updates (e.g., hourly/daily) for dashboards | Medium    | 1h or more       | Medium |
| 3. Using Materialized Views            | Large datasets, complex queries with low-latency needs | Medium to High                                       | 10-30 min | Medium to High   |
| 4. Dataflow                            | Very low-latency streaming for large datasets          | High                                                 | <10 min   | High             |
| 5. Cloud function with Pub/Sub trigger | Low-latency for smaller subsets of data                | Medium                                               | <10 min   | Medium to High   |

Live ping tables are the final destination for the telemetry ingestion pipeline. Incoming ping data is loaded into these tables approximately every 10 minutes, though a delay of up to 30 minutes is normal. Data in these tables is set to expire after 30 days.

### 1. Querying Live Tables Directly

Data from live ping tables is expected to be accessed through user-facing views. The names of all views accessing live data should include the `_live` suffix (for example `monitoring.topsites_click_rate_live`). Live tables are generally clustered and partitioned by `submission_timestamp`, which allows for writing more efficient queries that filter over short time windows. When querying live data by running the same query multiple times ensure that query caching is turned off, otherwise newly arrived data might not appear in the query results.

Live tables in `_derived` datasets can be queried from Redash and Looker, however it is best practice to set up user-facing views for accessing the data.

Directly querying live tables allows access to the most up-to-date data. A user-facing view is typically set up to pull data from the last two days from live tables, with older data coming from stable tables. To ensure fresh data is returned, caching must be disabled.

- **Recommended Use:** For smaller data volumes and low-complexity queries, or when queries are infrequent.
- **Pros:**
  - Easy to set up via bigquery-etl
- **Cons:**
  - High cost and slow performance when querying large datasets or running frequent complex queries.
- **Example:** [Active Hub Subscriptions](https://github.com/mozilla/bigquery-etl/blob/12470a846ef379cfba42995044f592c00fbc4e5b/sql/moz-fx-data-shared-prod/hubs/active_subscription_ids/view.sql#L1-L23)

### 2. Scheduled Queries

Scheduled queries run periodically (e.g., hourly or daily) using Airflow. They can write results to derived tables, which should be partitioned by the update interval (e.g., hourly) for efficiency. Scheduled queries typically backfill from stable tables and query live tables for recent data (e.g., the current day). For better efficiency, the destination tables should be partitioned based on the update interval (e.g. hourly), otherwise destination tables might need to be re-written.
To support backfilling, the scheduled queries should combine querying historical data from stable tables, and only query live tables for recently added data (e.g. current and/or past day).

- **Recommended Use:** For medium to high data sizes and query complexity, especially when higher lag is acceptable and update intervals match table partitioning.
- **Pros:**
  - Built-in monitoring and notifications via Airflow.
  - Faster for dashboards by querying pre-aggregated data.
- **Cons:**
  - Slightly more complex to set up via bigquery-etl.
  - High cost or slow performance when querying large amounts of live data or running complex queries frequently.
  - Increased load on Airflow with frequent updates.
  - Duplicates from live tables written to derived table.
  - Potentially more complicated logic required for tables updates (appending columns, rewriting partitions, ...).
- **Other Considerations:**
  - Partition limits (10,000 in BigQuery) might restrict data storage.
  - Delays in event writes to live tables can lead to scheduling adjustments and lag in destination tables.

### 3. Using Materialized Views

[BigQuery offers support for materialized views](https://cloud.google.com/bigquery/docs/materialized-views-intro). Materialized views are precomputed views that periodically cache the results of a query for increased performance and efficiency. Creating a materialized view that provides the relevant aggregates will be a significant cost savings when working with a large volume of live data.

When a materialized view is appropriate, it should be created in a relevant `_derived` dataset with a version suffix (following the same conventions as we do for derived tables populated via scheduled queries). It is then made user-facing via a simple `SELECT * FROM my_materialized_view` virtual view in a relevant user-facing dataset. More complex cases may need to union together multiple materialized views at this user-facing view level. The user-facing view should combine querying historical data from stable tables, and only query data from materialized views for the current day.

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

- **Recommended Use:** For medium to large datasets, complex queries, and when low data latency is essential.
- **Pros:**
  - Cost-effective as it only queries new data.
  - Historical data is coming from stable tables, so eventually the queried data is consistent without any duplicates.
  - Fast query performance due to data aggregation.
- **Cons:**
  - Complex to set up and maintain.
  - Materialized views querying very large datasets may fall behind, causing BigQuery to default to querying base tables directly.
  - Limitations around materialized views such as no support for UDFs and restricted JOIN capabilities.
  - Delay in permissions being applied after creating materialized views.
- **Other Considerations:**
  - Materialized views inherit expiration settings from underlying tables.
  - Clustering can improve performance.
- **Example:** [Experiment Monitoring](https://github.com/mozilla/bigquery-etl/tree/77f8facb93908dc22b6c94ca98e72f8c38e9534b/sql_generators/experiment_monitoring/templates)

### 4. Dataflow

The telemetry ingestion pipeline is built using Apache Beam and Dataflow. Additional jobs can be created to read incoming messages directly from Pub/Sub and stream them into BigQuery.

- **Recommended Use:** For very low-latency data processing when higher operational costs are acceptable.
- **Pros:**
  - Low latency
- **Cons:**
  - High setup and operational complexity.
  - Expensive to maintain.
- **Example:** [Contextual Services Pipeline](https://github.com/mozilla/gcp-ingestion/tree/main/ingestion-beam/src/main/java/com/mozilla/telemetry/contextualservices)

### 5. Cloud function with Pub/Sub trigger

Google Cloud Functions can process incoming messages in Pub/Sub and stream the data to BigQuery.

- **Recommended Use:** For low-latency data processing with smaller data volumes or subsets.
- **Pros:**
  - Easier to set up and operate than Dataflow.
  - Low latency.
- **Cons:**
  - More expensive than Dataflow for large volumes of data.
  - Subscription filtering can reduce costs, but not entirely.
- **Example:** [Glean Debug Viewer](https://github.com/mozilla/debug-ping-view/blob/main/functions/index.js#L52)

## Tools for Visualizing Live Data

Currently, live data in BigQuery could be considered "near real time" or nearline (as opposed to online), with latency usually below 1 hour to each live table in our ingestion-sink code base.

For near real time product monitoring use cases, it is recommended to use Looker for hosting dashboards that refresh on a regular interval such as every 10 minutes.

For real time operational monitoring use cases, it is recommended to rely on centralized SRE monitoring infrastructure, namely the InfluxCloud-hosted Grafana instance or the Stackdriver UI in the GCP console. For dashboards mixing monitoring data and (Mozilla Confidential) BigQuery data, then it should be possible to serve that need through the SRE Grafana infrastructure.

## Access Controls for Services Accessing Live Data in BigQuery

So far giving services access to the full data warehouse has been avoided, instead it is preferred to grant access only to the specific tables needed to support a documented use case. This reduces the possibility of data warehouse changes inadvertently breaking a consuming service.
When provisioning BigQuery access to a Mozilla service, it is recommended to create a use case-specific authorized view, granting the service access only to that specific view. It is also acceptable to grant the service access to a user-facing virtual view and all underlying tables or materialized views being referenced.
