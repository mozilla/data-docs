# Accessing and working with BigQuery

This guide will give you a quick introduction to working with data stored
in [BigQuery](https://cloud.google.com/bigquery/)

BigQuery uses a columnar data storage format called [Capacitor](https://cloud.google.com/blog/products/gcp/inside-capacitor-bigquerys-next-generation-columnar-storage-format) which supports semi-structured data.

There is a cost associated with using BigQuery based on operations. As of right now we pay an on-demand pricing for queries based on how much data a query scans. To minimize costs see [_Query Optimizations_](bigquery.md#query-optimizations). More detailed pricing information can be found [here](https://cloud.google.com/bigquery/pricing).

As we transition to [GCP](https://cloud.google.com) we will use BigQuery as our primary data warehouse and
SQL Query engine. BigQuery will eventually replace our previous SQL Query
Engines, Presto and Athena, and our Parquet data lake.


## Table of Contents
<!-- toc -->

# Access
There are multiple ways to access BigQuery. For most users the primary interface will be [re:dash](https://sql.telemetry.mozilla.org/).

See below for additional interfaces. All other interfaces will require access to be provisioned.

## Interfaces
BigQuery datasets and tables can be accessed by the following methods:

- [re:dash](bigquery.md#from-redash)
- [GCP BigQuery Console](bigquery.md#gcp-bigquery-console)
    - For advanced use cases including managing query outputs, table management. Requires GCP access to be granted by Data Operations.
- [GCP BigQuery API Access](bigquery.md#gcp-bigquery-api-access)
    - For advanced use cases including automated workloads, ETL, [BigQuery Storage API](https://cloud.google.com/bigquery/docs/reference/storage/). Requires GCP access to be granted by Data Operations.
    - Allows access to BigQuery via [`bq` command-line tool](https://cloud.google.com/bigquery/docs/bq-command-line-tool)
- [Spark/Databricks](bigquery.md#from-spark-/-databricks)
- [Spark/Dataproc](bigquery.md#from-spark-/-dataproc)
- [Colaboratory](bigquery.md#from-colaboratory)

## Access Request

For access to BigQuery via GCP Console and API please file a bug [here](https://bugzilla.mozilla.org/enter_bug.cgi?assigned_to=jthomas%40mozilla.com&bug_file_loc=https%3A%2F%2Fmana.mozilla.org%2Fwiki%2Fx%2FiIPeB&bug_ignored=0&bug_severity=normal&bug_status=NEW&bug_type=task&cf_fx_iteration=---&cf_fx_points=---&comment=Please%20grant%20me%20access%20to%20the%20BigQuery%20GCP%20console%20and%20API%20Access.%20I%20work%20on%20%3Cteam%3E.%0D%0A%0D%0AMy%20mozilla.com%20ldap%20login%20is%20%3Cyour%20ldap%20login%3E%40mozilla.com.&component=Operations&contenttypemethod=list&contenttypeselection=text%2Fplain&defined_groups=1&flag_type-4=X&flag_type-607=X&flag_type-800=X&flag_type-803=X&flag_type-936=X&form_name=enter_bug&maketemplate=Remember%20values%20as%20bookmarkable%20template&op_sys=Unspecified&priority=--&product=Data%20Platform%20and%20Tools&qa_contact=jthomas%40mozilla.com&rep_platform=Unspecified&short_desc=BigQuery%20GCP%20Console%20and%20API%20Access%20for%20%3Cyour%20ldap%20login%3E%40mozilla.com&target_milestone=---&version=unspecified). As part of this request we will add you to the appropriate Google Groups and provision a GCP Service Account.

## From re:dash
All Mozilla users will be able to access BigQuery via [re:dash](https://sql.telemetry.mozilla.org/) through the following Data Sources:
- `BigQuery (Beta)`
- `BigQuery Search (Beta)`
    - This group is restricted to users in the re:dash `search` group.

Access via re:dash is read-only. You will not be able to create views or tables via re:dash.

## GCP BigQuery Console

- File a [bug](bigquery.md#access-request) with Data Operations for access to GCP Console.
- Visit [GCP BigQuery Console](https://console.cloud.google.com/bigquery)
- Switch to the project provided to you during your access request e.g `moz-fx-data-bq-<team-name>`

See [Using the BigQuery web UI in the GCP Console](https://cloud.google.com/bigquery/docs/bigquery-web-ui) for more details.

## GCP BigQuery API Access

- File a [bug](bigquery.md#access-request) with Data Operations for access to GCP BigQuery API Access.

A list of supported BigQuery client libraries can be found [here](https://cloud.google.com/bigquery/docs/reference/libraries).

Detailed REST reference can be found [here](https://cloud.google.com/bigquery/docs/reference/rest/).

### From `bq` Command-line Tool

- Install the [GCP SDK](https://cloud.google.com/sdk/)
- Authorize `gcloud` with either your user account or provisioned service account. See documentation [here](https://cloud.google.com/sdk/docs/authorizing).
    - `gcloud auth login`
- Set your google project to your team project
    - `gcloud config set project moz-fx-data-bq-<team-name>`
    - project name will be provided for you when your account is provisioned.

#### `bq` Examples
List tables in a BigQuery dataset
``` bash
bq ls moz-fx-data-derived-datasets:analysis
```
Query a table
 ``` bash
 bq query --nouse_legacy_sql 'select count(*) from `moz-fx-data-derived-datasets.telemetry.main_summary_v4` where submission_date_s3 = "2019-03-01"'
 ```

Additional examples and documentation can be found [here](https://cloud.google.com/bigquery/docs/bq-command-line-tool).

## From Spark / Databricks
There are two Spark connectors you can use:

### Standard SQL connector
This [connector](https://github.com/akkomar/spark-bigquery) is based on [`spotify/spark-bigquery`](https://github.com/spotify/spark-bigquery). It allows to submit arbitrary SQL queries and get results in a DataFrame. It's worth noting that filtering on a DataFrame level won't be pushed down to BigQuery - this is quite a big difference to what you might be used to if you were using Parquet as your data source. Therefore offloading as much filtering as possible to the query is a great way to speed up and lower cost of your data loads.

Connector library is added to `shared_serverless_python3` cluster on Databricks - see example [Scala](https://dbc-caf9527b-e073.cloud.databricks.com/#notebook/130908) and [Python](https://dbc-caf9527b-e073.cloud.databricks.com/#notebook/130819) notebooks.   

### Storage API connector
[Storage API Connector](https://github.com/GoogleCloudPlatform/spark-bigquery-connector) uses [BigQuery Storage API](https://cloud.google.com/bigquery/docs/reference/storage/). Although both API and connector are in Beta, this is the recommended way for accessing BigQuery from Spark as it offers better performance and is more cost-effective than the standard connector. This connector has some limited support for pushing down filtering predicates, it can also be used together with BigQuery client which allows to run arbitrary SQL queries and load results to Spark.

Connector library is added to `shared_serverless_python3` cluster on Databricks - see example [Python notebook](https://dbc-caf9527b-e073.cloud.databricks.com/#notebook/141939) for more details on the topics mentioned above.

## From Spark / Dataproc
Querying BigQuery from Dataproc will be faster than from Databricks because it will not involve cross-cloud data transfers.

You can spin up a Dataproc cluster with Jupyter using the following command. Insert your values for `cluster-name`, `bucket-name`, and `project-id` there. Your notebooks will be stored in Cloud Storage under `gs://bucket-name/notebooks/jupyter`:
```bash
gcloud beta dataproc clusters create cluster-name \
    --optional-components=ANACONDA,JUPYTER \
    --image-version=1.4 \
    --enable-component-gateway \
    --properties=^#^spark:spark.jars=gs://spark-lib/bigquery/spark-bigquery-latest.jar,gs://spark-bigquery-dev-test/spark-bigquery-spotify-connector/spark-bigquery-assembly-0.3.0-SNAPSHOT.jar \
    --num-workers=5 \
    --max-idle=3h \
    --bucket bucket-name \
    --project project-id
```

Jupyter URL can be retrieved with the following command:
```bash
gcloud beta dataproc clusters describe cluster-name --project project-id | grep Jupyter
```

After you've finished your work, it's a good practice to delete your cluster:
```bash
gcloud beta dataproc clusters delete cluster-name --project project-id
```

## From Colaboratory
[Colaboratory](https://colab.research.google.com) is Jupyter notebook environment, managed by Google and running in the cloud. Notebooks are stored in Google Drive and can be shared in a similar way to Google Docs.

Colaboratory can be used to easily access BigQuery and perform interactive analyses. See [example notebook](https://colab.research.google.com/drive/1NCkpZBx3cRc08-g_JKMBrf5cIxAvSNMv).

Note: this is very similar to [API Access](bigquery.md#gcp-bigquery-api-access), so you will need access to your team's GCP project - file a request as described [above](bigquery.md#access-request).

# Querying Tables

## Projects, Datasets and Tables in BigQuery
In GCP a [project](https://cloud.google.com/resource-manager/docs/creating-managing-projects) is a way to organize cloud resources. We use multiple
projects to maintain our BigQuery [datasets](https://cloud.google.com/bigquery/docs/datasets-intro). BigQuery datasets are a top-level container used to organize and
control access to tables and views.

### Caveats

- The date partition field (e.g. `submission_date_s3`, `submission_date`) is mostly used as a partitioning column,
but it has changed from `YYYYMMDD` form to the more standards-friendly `YYYY-MM-DD` form.
- Unqualified queries can become very costly very easily. We've placed restrictions on large tables from accidentally querying "all data for all time",
namely that you must make use of the date partition fields for large tables (like `main_summary` or `clients_daily`).
- Please read [_Query Optimizations_](bigquery.md#query-optimizations) section that contains advice on how to reduce cost and improve query performance.
- re:dash BigQuery data sources will have a 10 TB data scanned limit per query. Please let us know in `#fx-metrics` on Slack if you run into issues!
- There are no other partitioning fields in BigQuery versions of parquet datasets (e.g. `sample_id` is no longer a partitioning field and will not necessarily reduce data scanned).
- There is no native map support in BigQuery. Instead, we are using structs with fields [key, value]. We have provided convenience functions to access these like key-value maps (described [below](bigquery.md#accessing-map-like-fields).)

### Projects with BigQuery datasets

|Project|Dataset|Purpose|
|---|---|---|
|`moz-fx-data-derived-datasets`|    |Imported parquet data, [BigQuery ETL](https://github.com/mozilla/bigquery-etl), ad-hoc analysis|
|   |`analysis`|User generated tables for analysis|
|   |`backfill`|Temporary staging area for back-fills|
|   |`blpadi`|Blocklist ping derived data(_restricted_)|
|   |`search`|Search data imported form parquet (_restricted_)|
|   |`static`|Static data for use with analysis|
|   |`telemetry`|User-facing views on imported parquet data and tables generated from [BigQuery ETL](https://github.com/mozilla/bigquery-etl)     |
|   |`telemetry_raw`|Imported parquet data|
|   |`tmp`|Temporary staging area for parquet data loads|
|   |`validation`|Temporary staging area for validation|
|`moz-fx-data-shar-nonprod-efed`| |Data produced by stage structured ingestion infrastructure|

BigQuery table data in `moz-fx-data-derived-datasets` is loaded daily via [Airflow](https://workflow.telemetry.mozilla.org/home)

### Writing Queries

To query a BigQuery table you will need to specify the dataset and table name. It is good practice to specify the project however depending on which project the query
originates from this is optional.

``` sql
SELECT
    col1,
    col2
FROM
    `project.dataset.table`
WHERE
    -- data_partition_field will vary based on table
    date_partition_field >= DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH)
```
An example query from [Clients Last Seen Reference](../datasets/bigquery/clients_last_seen/reference.md)

``` sql
SELECT
    submission_date,
    os,
    COUNT(*) AS count
FROM
    telemetry.clients_last_seen
WHERE
    submission_date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 WEEK)
    AND days_since_seen = 0
GROUP BY
    submission_date,
    os
HAVING
    count > 10 -- remove outliers
    AND lower(os) NOT LIKE '%windows%'
ORDER BY
    os,
    submission_date DESC
```

Check out the [BigQuery Standard SQL Functions & Operators](https://cloud.google.com/bigquery/docs/reference/standard-sql/functions-and-operators) for detailed documentation.

### Writing query results to a permanent table

You can write query results to a BigQuery table you have access via [GCP BigQuery Console](bigquery.md#gcp-bigquery-console) or [GCP BigQuery API Access](bigquery.md#gcp-bigquery-api-access)

- Use `moz-fx-data-derived-datasets.analysis` dataset.
    - Prefix your table with your username. If your username is `username@mozilla.com` create a table with `username_my_table`.
- See [Writing query results](https://cloud.google.com/bigquery/docs/writing-results) documentation for detailed steps.

### Creating a View
You can create views in BigQuery if you have access via [GCP BigQuery Console](bigquery.md#gcp-bigquery-console) or [GCP BigQuery API Access](bigquery.md#gcp-bigquery-api-access).

- Use `moz-fx-data-derived-datasets.analysis` dataset.
    - Prefix your view with your username. If your username is `username@mozilla.com` create a table with `username_my_view`.
- See [Creating Views](https://cloud.google.com/bigquery/docs/views) documentation for detailed steps.

### Accessing map-like fields

BigQuery currently lacks native map support and our workaround is to use a STRUCT type with fields named [key, value]. We've created a user-defined function (UDFs) that provides key-based access with the signature: `udf.get_key(<struct>, <key>)`. The example below generates a count per `reason` key in the `event_map_values` field in the telemetry events table for Normandy unenrollment events from yesterday.
```sql
SELECT udf.get_key(event_map_values, 'reason') AS reason,
       COUNT(*) AS EVENTS
FROM telemetry.events
WHERE submission_date = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
  AND event_category='normandy'
  AND event_method='unenroll'
GROUP BY 1
ORDER BY 2 DESC
```

# Query Optimizations

To improve query performance and minimize the cost associated with using BigQuery please see the following query optimizations:

- Avoid `SELECT *` by selecting only the columns you need
    - Using `SELECT *` is the most expensive way to query data. When you use `SELECT *` _BigQuery does a full scan of every column in the table._
    - Applying a `LIMIT` clause to a `SELECT *` query might not affect the amount of data read, depending on the table structure.
      - Many of our tables are configured to use _clustering_ in which case a `LIMIT` clause does effectively limit the amount of data that needs to be scanned.
      - Tables that include a `sample_id` field will usually have that as one of the clustering fields and you can efficiently scan random samples of users by specifying `WHERE sample_id = 0` (1% sample), `WHERE sample_id < 10` (10% sample), etc. This can be especially helpful with `main_summary`, `clients_daily`, and `clients_last_seen` which are very large tables and are all clustered on `sample_id`.
      - To check whether your `LIMIT` and `WHERE` clauses are actually improving performance, you should see a lower value reported for actual "Data Scanned" by a query compared to the prediction ("This query will process X bytes") in STMO or the BigQuery UI.
    - If you are experimenting with data or exploring data, use one of the [data preview options](https://cloud.google.com/bigquery/docs/best-practices-costs#preview-data) instead of `SELECT *`.
        - Preview support is coming soon to BigQuery data sources in [re:dash](https://sql.telemetry.mozilla.org/)
- Limit the amount of data scanned by using a date partition filter
    - Tables that are larger than 1 TB will require that you provide a date partition filter as part of the query.
    - You will receive an error if you attempt to query a table that requires a partition filter.
        - `Cannot query over table 'moz-fx-data-derived-datasets.telemetry.main_summary_v4' without a filter over column(s) 'submission_date_s3' that can be used for partition elimination`
    - See [_Writing Queries_](bigquery.md#writing-queries) for examples.
- Reduce data before using a JOIN
    - Trim the data as early in the query as possible, before the query performs a JOIN. If you reduce data early in the processing cycle, shuffling and other complex operations only execute on the data that you need.
    - Use sub queries with filters or intermediate tables or views as a way of decreasing sides of a join, prior to the join itself.
- Do not treat WITH clauses as prepared statements
    - WITH clauses are used primarily for readability because they are not materialized. For example, placing all your queries in WITH clauses and then running UNION ALL is a misuse of the WITH clause. If a query appears in more than one WITH clause, it executes in each clause.
- Use approximate aggregation functions
    - If the SQL aggregation function you're using has an equivalent approximation function, the approximation function will yield faster query performance. For example, instead of using `COUNT(DISTINCT)`, use `APPROX_COUNT_DISTINCT()`.
    - See [approximate aggregation functions](https://cloud.google.com/bigquery/docs/reference/standard-sql/functions-and-operators#approximate-aggregate-functions) in the standard SQL reference.
- Reference the data size prediction ("This query will process X bytes") in STMO and the BigQuery UI to help gauge the efficiency of your queries. You should see this number go down as you limit the range of `submission_date`s or include fewer fields in your `SELECT` statement. For clustered tables, this estimate won't take into account benefits from `LIMIT`s and `WHERE` clauses on clustering fields, so you'll need to compare to the actual "Data Scanned" after the query is run. [Queries are charged by data scanned at $5/TB](https://cloud.google.com/bigquery/pricing#on_demand_pricing) so each 200 GB of data scanned will cost $1; it can be useful to keep the data estimate below 200 GB while developing and testing a query to limit cost and query time, then open up to the full range of data you need when you have confidence in the results.

A complete list of optimizations can be found [here](https://cloud.google.com/bigquery/docs/best-practices-performance-overview) and cost optimizations [here](https://cloud.google.com/bigquery/docs/best-practices-costs)
