Introduction
------------

[Apache Spark](https://spark.apache.org/)
is a data processing engine designed to be fast and easy to use.

Spark can be used either from [Databricks][db_example] or Dataproc, and works
with data stored in BigQuery.

The [BigQuery cookbook](../cookbooks/bigquery.md#from-spark) covers how to access
BigQuery data from Spark.

[db_example]: https://dbc-caf9527b-e073.cloud.databricks.com/#notebook/30598/command/30599

## Notebooks

Notebooks can be easily shared and updated among colleagues
and, when combined with Spark, enable richer analysis than SQL alone.

Databricks has its own custom notebook environment, which has built-in
support for sharing, scheduling, collaboration, and commenting.

Dataproc uses standard [Jupyter notebooks](https://jupyter.org/).

### Sharing a Jupyter Notebook

Jupyter notebooks can be shared in a few different ways.

#### Sharing a Static Notebook

An easy way to share is using a gist on Github. Jupyter notebook files checked
in to a Github repository will be rendered in the Github web UI, which makes
sharing convenient.

You can also upload the `.ipynb` file as a gist to share with your colleagues.

Using Spark
-----------

Spark is a general-purpose cluster computing system - it allows users to
run general execution graphs. APIs are available in Python, Scala, R, and
Java. The Jupyter notebook utilizes the Python API. In a nutshell, it
provides a way to run functional code (e.g. map, reduce, etc.) on large,
distributed data.

Check out
[Spark Best Practices](https://robertovitillo.com/2015/06/30/spark-best-practices/)
for tips on using Spark to its full capabilities.

Other useful introductory materials:
* [Spark Programming Guide](https://spark.apache.org/docs/latest/programming-guide.html)
* [Spark SQL Programming Guide](https://spark.apache.org/docs/latest/sql-programming-guide.html)


### Reading data from BigQuery into Spark

There are two main ways to read data from BigQuery into Spark.

#### Storage API
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

* `get_table` is necessary because an actual _table_ name is required to read
  from BigQuery here, fully qualified with project name and dataset name.
  The Storage API does not support accessing `VIEW`s, so the convenience names
  such as `telemetry.core` are not available via this API.
* You must supply a filter on the table's date partitioning column, in this
  case `submission_timestamp`.
  Additionally, you must use the `to_date` function to make sure that predicate
  push-down works properly for these filters.

#### Query API

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
  `moz-fx-data-derived-datasets.telemetry.events`
WHERE
  event_category = 'normandy'
  AND event_method = 'enroll'
  AND submission_date_s3 = '2019-06-01'
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


### Persisting data

You can save data resulting from your Spark analysis as a [BigQuery table][persist_bq]
or to [Google Cloud Storage][persist_gcs].

You can also save data to the [Databricks Filesystem][dbfs].

[dbfs]: https://docs.databricks.com/user-guide/databricks-file-system.html#dbfs
[persist_bq]: ../cookbooks/bigquery.md#writing-query-results-to-a-permanent-table
[persist_gcs]: ../cookbooks/bigquery.md#writing-results-to-gcs-object-store


FAQ
---

Please add more FAQ as questions are answered by you or for you.

### I got a REMOTE HOST IDENTIFICATION HAS CHANGED! error

Cloud providers recycles hostnames, so this warning is expected.
Removing the offending key from `$HOME/.ssh/known_hosts` will remove the warning.
You can find the line to remove by finding the line in the output that says

`Offending key in /path/to/hosts/known_hosts:2`

Where 2 is the line number of the key that can be deleted.
Just remove that line, save the file, and try again.

### Why is my notebook hanging?

There are a few common causes for this:

1. Currently, our Spark notebooks can only run a single Python kernel at
   a time. If you open multiple notebooks on the same cluster and try to
   run both, the second notebook will hang. Be sure to close notebooks
   using "Close and Halt" under the "File" drop-down.
2. The connection from PySpark to the Spark driver might be lost.
   Unfortunately the best way to recover from this for the moment seems to
   be spinning up a new cluster.
3. Cancelling execution of a notebook cell doesn't cancel any spark jobs
   that might be running in the background. If your spark commands seem to
   be hanging, try running \`sc.cancelAllJobs()\`.

### How can I keep running after closing the notebook?

For long-running computation, it might be nice to close the notebook
(and the SSH session) and look at the results later.
Unfortunately, **all cell output will be lost when a notebook is closed**
(for the running cell).
To alleviate this, there are a few options:

1. Have everything output to a variable. These values should still be
   available when you reconnect.
2. Put %%capture at the beginning of the cell to store all output.
   [See the documentation](https://ipython.org/ipython-doc/3/interactive/magics.html#cellmagic-capture).

### How do I load an external library into the cluster?

Assuming you've got a URL for the repo, you can create an egg for it
this way:

```python
!git clone `<repo url>` && cd `<repo-name>` && python setup.py bdist_egg`\
sc.addPyFile('`<repo-name>`/dist/my-egg-file.egg')`
```

Alternately, you could just create that egg locally, upload it to a web
server, then download and install it:

```python
import requests`\
r = requests.get('`<url-to-my-egg-file>`')`\
with open('mylibrary.egg', 'wb') as f:`\
  f.write(r.content)`\
sc.addPyFile('mylibrary.egg')`
```

You will want to do this **before** you load the library. If the library
is already loaded, restart the kernel in the Jupyter notebook.
