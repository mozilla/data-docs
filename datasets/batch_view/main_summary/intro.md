The `main_summary` table is the most direct representation of a main ping
but can be difficult to work with due to its size. 
Prefer the `longitudinal` dataset unless using the sampled data is prohibitive.

#### Contents

The `main_summary` table contains one row for each ping.
Each column represents one field from the main ping payload,
though only a subset of all main ping fields are included.
This dataset **does not include histograms**.

#### Background and Caveats
This table is massive, and due to its size, it can be difficult to work with.
You should **avoid querying `main_summary`** from [re:dash](https://sql.telemetry.mozilla.org).
Your queries will be **slow to complete** and can **impact performance for other users**,
since re:dash on a shared cluster.

Instead, we recommend using the `longitudinal` or `clients_daily` dataset where possible.
If these datasets do not suffice, consider using Spark on an
[ATMO](https://analysis.telemetry.mozilla.org) cluster.
In the odd case where these queries are necessary,
make use of the `sample_id` field and limit to a short submission date range.

#### Accessing the Data

The data is stored as a parquet table in S3 at the following address.
See [this cookbook](/cookbooks/parquet.md) to get started working with the data in Spark.
```
s3://telemetry-parquet/main_summary/v4/
```

Though **not recommended** `main_summary` is accessible through re:dash. 
Here's an [example query](https://sql.telemetry.mozilla.org/queries/4201/source).
Your queries will be slow to complete and can **impact performance for other users**,
since re:dash is on a shared cluster.

#### Further Reading

The technical documentation for `main_summary` is located in the
[telemetry-batch-view documentation](https://github.com/mozilla/telemetry-batch-view/blob/master/docs/MainSummary.md).

The code responsible for generating this dataset is 
[here](https://github.com/mozilla/telemetry-batch-view/blob/master/src/main/scala/com/mozilla/telemetry/views/MainSummaryView.scala)
