  ***As of 2019-11-06, this dataset has been deprecated and is no longer maintained. Please use the `telemetry.crash` table instead, which is generated directly from live pings and is much more complete. See [Bug 1572069](https://bugzilla.mozilla.org/show_bug.cgi?id=1572069) for more information.***

The `crash_summary` table is the a direct representation of a crash ping.

#### Contents

The `crash_summary` table contains one row for each crash ping.
Each column represents one field from the crash ping payload,
though only a subset of all crash ping fields are included.

#### Accessing the Data

The data is stored as a parquet table in S3 at the following address.
```
s3://telemetry-parquet/crash_summary/v1/
```

`crash_summary` is accessible through re:dash.
Here's an [example query](https://sql.telemetry.mozilla.org/queries/4793/source).

#### Further Reading

The technical documentation for `crash_summary` is located in the
[telemetry-batch-view documentation](https://github.com/mozilla/telemetry-batch-view/blob/master/docs/CrashSummary.md).

The code responsible for generating this dataset is
[here](https://github.com/mozilla/telemetry-batch-view/blob/master/src/main/scala/com/mozilla/telemetry/views/CrashSummaryView.scala)
