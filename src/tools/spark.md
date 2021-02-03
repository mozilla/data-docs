# Custom Analysis with Spark

<!-- toc -->

## Introduction

[Apache Spark](https://spark.apache.org/) is a general-purpose cluster computing system - it allows users to
run general execution graphs. APIs are available in Python, Scala, R, and Java. It is designed to be fast and easy to use.

Here are some useful introductory materials:

- [Spark Programming Guide](https://spark.apache.org/docs/latest/programming-guide.html)
- [Spark SQL Programming Guide](https://spark.apache.org/docs/latest/sql-programming-guide.html)

Spark can be used from [Google's Dataproc](https://cloud.google.com/dataproc/), and works with data stored in BigQuery.

There are a number of methods of both reading from and writing to BigQuery using Spark.

## Accessing BigQuery data from Spark

### Using the Storage API Connector

> **⚠** This method requires [BigQuery Access](../cookbooks/bigquery/access.md#bigquery-access-request) to be provisioned.

If you want to use Spark locally (or via an arbitrary GCP instance in the cloud), we recommend the [Storage API Connector](https://github.com/GoogleCloudPlatform/spark-bigquery-connector) for accessing BigQuery tables in Spark as it is the most modern and actively developed connector. It works well with the BigQuery client library which is useful if you need to run arbitrary SQL queries and load their results into Spark.

### Using Dataproc

> **⚠** This method requires [BigQuery Access](../cookbooks/bigquery/access.md#bigquery-access-request) to be provisioned.

Dataproc is Google's managed Spark cluster service.

You can spin up a Dataproc cluster with Jupyter using the following command. Insert your values for `cluster-name`, `bucket-name`, and `project-id` there. Your notebooks are stored in Cloud Storage under `gs://bucket-name/notebooks/jupyter`:

```bash
gcloud beta dataproc clusters create cluster-name \
    --optional-components=ANACONDA,JUPYTER \
    --image-version=1.4 \
    --enable-component-gateway \
    --properties=^#^spark:spark.jars=gs://spark-lib/bigquery/spark-bigquery-latest.jar \
    --num-workers=3 \
    --max-idle=3h \
    --bucket bucket-name \
    --region=us-west1 \
    --project project-id
```

You can retrieve the Jupyter URL with the following command:

```bash
gcloud beta dataproc clusters describe cluster-name --region=us-west1 --project project-id | grep Jupyter
```

After you've finished your work, it's a good practice to delete your cluster:

```bash
gcloud beta dataproc clusters delete cluster-name --region=us-west1 --project project-id --quiet
```

## Reading data from BigQuery into Spark

There are two main ways to read data from BigQuery into Spark: using either the storage API and the
query API.

### Storage API

First, using the Storage API - this bypasses BigQuery's execution engine and
directly reads from the underlying storage.

This is the preferred method of loading data from BigQuery into Spark.

It is more efficient for reading large amounts of data into Spark, and
supports basic column and partitioning filters.

Example of using the Storage API from Databricks:

```python
dbutils.library.installPyPI("google-cloud-bigquery", "1.16.0")
dbutils.library.restartPython()

from google.cloud import bigquery


def get_table(view):
    """Helper for determining what table underlies a user-facing view, since the Storage API can't read views."""
    bq = bigquery.Client()
    view = view.replace(":", ".")
    # partition filter is required, so try a couple options
    for partition_column in ["DATE(submission_timestamp)", "submission_date"]:
        try:
            job = bq.query(
                f"SELECT * FROM `{view}` WHERE {partition_column} = CURRENT_DATE",
                bigquery.QueryJobConfig(dry_run=True),
            )
            break
        except Exception:
            continue
    else:
        raise ValueError("could not determine partition column")
    assert len(job.referenced_tables) == 1, "View combines multiple tables"
    table = job.referenced_tables[0]
    return f"{table.project}:{table.dataset_id}.{table.table_id}"


# Read one day of main pings and select a subset of columns.
core_pings_single_day = spark.read.format("bigquery") \
    .option("table", get_table("moz-fx-data-shared-prod.telemetry.main")) \
    .load() \
    .where("submission_timestamp >= to_date('2019-08-25') submission_timestamp < to_date('2019-08-26')") \
    .select("client_id", "experiments", "normalized_channel")
```

A couple of things are worth noting in the above example.

- `get_table` is necessary because an actual _table_ name is required to read
  from BigQuery here, fully qualified with project name and dataset name.
  The Storage API does not support accessing `VIEW`s, so the convenience names
  such as `telemetry.core` are not available via this API.
- You must supply a filter on the table's date partitioning column, in this
  case `submission_timestamp`.
  Additionally, you must use the `to_date` function to make sure that predicate
  push-down works properly for these filters.

### Query API

If you want to read the results of a query (rather than directly reading
tables), you may also use the Query API.

This pushes the execution of the query into BigQuery's computation engine,
and is typically suitable for reading smaller amounts of data. If you need
to read large amounts of data, prefer the Storage API as described above.

Example:

```python
from google.cloud import bigquery

bq = bigquery.Client()

query = """
SELECT
  event_string_value,
  count(distinct client_id) AS client_count
FROM
  mozdata.telemetry.events
WHERE
  event_category = 'normandy'
  AND event_method = 'enroll'
  AND submission_date = '2019-06-01'
GROUP BY
  event_string_value
ORDER BY
  client_count DESC
LIMIT 20
"""

query_job = bq.query(query)

# Wait for query execution, then fetch results as a pandas dataframe.
rows = query_job.result().to_dataframe()
```

## Persisting data

You can save data resulting from your Spark analysis as a [BigQuery table][persist_bq]
or to [Google Cloud Storage][persist_gcs].

You can also save data to the [Databricks Filesystem][dbfs].

[dbfs]: https://docs.databricks.com/user-guide/databricks-file-system.html#dbfs
[persist_bq]: ../cookbooks/bigquery/querying.md#writing-query-results-to-a-permanent-table
[persist_gcs]: ../cookbooks/bigquery/querying.md#writing-results-to-gcs-object-store
