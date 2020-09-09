The `telemetry_aggregates` dataset is a daily aggregation of the pings,
aggregating the histograms across a set of dimensions.

#### Rows and Columns

There's one column for each of the dimensions and the histogram and each row
is a distinct set of dimensions, along with their associated histograms.

#### Accessing the Data

This dataset is accessible via STMO by selecting from `telemetry_aggregates`.

The data is stored as a parquet table in S3 at the following address.

```
s3://telemetry-parquet/aggregates_poc/v1/
```
