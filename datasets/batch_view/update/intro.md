The [update ping](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/update-ping.html)
is sent from Firefox Desktop when a browser update is ready to be applied and after it was correctly applied.
It contains the build information and the update blob information, in addition to some information about the
user environment.
The `telemetry_update_parquet` table is the most direct representation of an update ping.

#### Contents

The table contains one row for each ping. Each column represents one field from the update ping payload, though only a subset of all fields are included.

#### Accessing the Data

The data is stored as a parquet table in S3 at the following address.
See [this cookbook](/cookbooks/parquet.md) to get started working with the data in Spark.
```
s3://net-mozaws-prod-us-west-2-pipeline-data/telemetry-update-parquet/v1/
```

The `telemetry_update_parquet` is accessible through re:dash.
Here's an [example query](https://sql.telemetry.mozilla.org/queries/31267#table).

#### Further Reading

This dataset is generated automatically using direct to parquet. The configuration responsible for generating this dataset was introduced in [bug 1384861](https://bugzilla.mozilla.org/show_bug.cgi?id=1384861).
