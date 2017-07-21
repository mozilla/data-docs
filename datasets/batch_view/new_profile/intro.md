The `telemetry_new_profile_parquet` table is the most direct representation of a new-profile ping.

#### Contents

The table contains one row for each ping. Each column represents one field from the new-profile ping payload, though only a subset of all fields are included.

#### Accessing the Data

The data is stored as a parquet table in S3 at the following address.
See [this cookbook](/cookbooks/parquet.md) to get started working with the data in Spark.
```
s3://net-mozaws-prod-us-west-2-pipeline-data/telemetry-new-profile-parquet/v1/
```

The `telemetry_new_profile_parquet` is accessible through re:dash.
Here's an [example query](https://sql.telemetry.mozilla.org/queries/5888#table).

#### Further Reading

This dataset is generated automatically using direct to parquet. The configuration responsible for generating this dataset was introdueced in [bug 1360256](https://bugzilla.mozilla.org/show_bug.cgi?id=1360256).
