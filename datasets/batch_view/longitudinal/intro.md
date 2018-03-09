The `longitudinal` dataset is a 1% sample of main ping data
organized so that each row corresponds to a `client_id`.
If you're not sure which dataset to use for your analysis,
this is probably what you want.

#### Contents
Each row in the `longitudinal` dataset represents one `client_id`,
which is approximately a user.
Each column represents a field from the main ping.
Most fields contain **arrays of values**, with one value for each ping associated with a `client_id`.
Using arrays give you access to the raw data from each ping,
but can be difficult to work with from SQL.
Here's a [query showing some sample data](https://sql.telemetry.mozilla.org/queries/4188#table)
to help illustrate.
Take a look at the [longitudinal examples](/cookbooks/longitudinal.md) if you get stuck.

#### Background and Caveats
Think of the longitudinal table as wide and short.
The dataset contains more columns than `main_summary`
and down-samples to 1% of all clients to reduce query computation time and save resources.

In summary, the longitudinal table differs from `main_summary` in two important ways:

* The longitudinal dataset groups all data so that one row represents a `client_id`
* The longitudinal dataset samples to 1% of all `client_id`s

Please note that this dataset only contains release (or opt-out) histograms and scalars.

#### Accessing the Data

The `longitudinal` is available in re:dash,
though it can be difficult to work with the array values in SQL.
Take a look at this [example query](https://sql.telemetry.mozilla.org/queries/4189/source).

The data is stored as a parquet table in S3 at the following address.
See [this cookbook](/cookbooks/parquet.md) to get started working with the data
in [Spark](http://spark.apache.org/docs/latest/quick-start.html).
```
s3://telemetry-parquet/longitudinal/
```
