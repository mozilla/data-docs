# Working with Parquet

This guide will give you a quick introduction to working with 
[Parquet](https://parquet.apache.org/) files at Mozilla.
You can also refer to Spark's documentation on the subject
[here](http://spark.apache.org/docs/latest/sql-programming-guide.html#parquet-files).

Most of our [derived datasets](/datasets/derived.md),
like the `longitudinal` or `main_summary` tables,
are stored in Parquet files.
You can access these datasets in [re:dash](https://sql.telemetry.mozilla.org/),
but you may want to access the data from an
[ATMO](https://analysis.telemetry.mozilla.org/) cluster
if SQL isn't powerful enough for your analysis
or if a sample of the data will not suffice.

## Table of Contents
<!-- toc -->

# Reading Parquet Tables

Spark provides native support for reading parquet files.
The result of loading a parquet file is a 
[DataFrame](http://spark.apache.org/docs/2.1.0/api/python/pyspark.sql.html#pyspark.sql.DataFrame).
For example, you can load `main_summary` with the following snippet:

```python
# Parquet files are self-describing so the schema is preserved.
main_summary = spark.read.parquet('s3://telemetry-parquet/main_summary/v1/')
```

You can find the S3 path for common datasets in
[Choosing a Dataset](/concepts/choosing_a_dataset.md)
or in the reference documentation.

# Writing Parquet Tables

Saving a table to parquet is a great way to share an intermediate dataset.

## Where to save data

You can save data to a subdirectory of the following bucket: 
`s3://net-mozaws-prod-us-west-2-pipeline-analysis/<username>/`
Use your username for the subdirectory name.
This bucket is available to all ATMO clusters and Airflow.

When your analysis is production ready,
open a PR against [python_mozetl](https://github.com/mozilla/python_mozetl).

## How to save data

You can save the dataframe `test_dataframe`
 to the `telemetry-test-bucket` with the following command:

```python
test_dataframe.write.mode('error') \
    .parquet('s3://telemetry-test-bucket/my_subdir/table_name')
```

# Accessing Parquet Tables from Re:dash

See [Creating a custom re:dash dataset](/cookbooks/create_a_dataset.md).
