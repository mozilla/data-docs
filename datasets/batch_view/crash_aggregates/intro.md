The `crash_aggregates` dataset compiles crash statistics over various dimensions for each day.

#### Rows and Columns

There's one column for each of the stratifying dimensions and the crash statistics.
Each row is a distinct set of dimensions, along with their associated crash stats.
Example stratifying dimensions include channel and country,
example statistics include usage hours and plugin crashes.
See the [complete documentation](https://github.com/mozilla/telemetry-batch-view/blob/master/docs/CrashAggregateView.md)
for all available dimensions
and statistics.

#### Accessing the Data

This dataset is accessible via re:dash.

The data is stored as a parquet table in S3 at the following address.
See [this cookbook](/cookbooks/parquet.md) to get started working with the data in Spark.
```
s3://telemetry-parquet/crash_aggregates/v1/
```

#### Further Reading

The technical documentation for this dataset can be found in the
[telemetry-batch-view documentation](https://github.com/mozilla/telemetry-batch-view/blob/master/docs/CrashAggregateView.md)
