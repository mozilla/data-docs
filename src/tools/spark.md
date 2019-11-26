Introduction
------------

[Apache Spark](https://spark.apache.org/)
is a data processing engine designed to be fast and easy to use.

Spark can be used either from [Databricks][db_example] or Dataproc, and works
with data stored in BigQuery.

The [BigQuery article](../cookbooks/bigquery.md) covers how to access
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
in to a github repository will be rendered in the Github web UI, which makes
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

FIXME: include info about where to save intermediate / self-generated data (gcs? bq?)
FIXME: include an inline example showing BQ access
FIXME: describe the lack of access to VIEWs via the Storage API

### Persisting data

You can save data to the [Databricks Filesystem][dbfs]
or FIXME: somewhere on GCS?.

[dbfs]: https://docs.databricks.com/user-guide/databricks-file-system.html#dbfs



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
