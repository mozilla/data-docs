The `first_shutdown_summary` table is a summary of the [`first-shutdown`
ping](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/first-shutdown-ping.html). 

#### Contents

The first shutdown ping contains a client's first session usage data. This
table contains rows similar to the
[`telemetry_new_profile_parquet`](/datasets/batch_view/new_profile/reference.md),
but in the shape of
[`main_summary`](/datasets/batch_view/main_summary/reference.md). 

#### Background and Caveats

Data collection latency was vastly improved with the introduction of the
shutdown ping-sender mechanism in Firefox 55. To maintain consistent historical
behavior, the first main ping is not sent until the second start up. Instead, a
separate first-shutdown ping was created to maintain backwards compatibility.

In many cases, the first-shutdown ping is a duplicate of the main ping. To
avoid duplicate documents, take the `outer join` of the two datasets on
their `document_id`.

#### Accessing the Data

The data can be accessed as `first_shutdown_summary`. It is currently stored in the following path.

```
s3://telemetry-parquet/first_shutdown_summary/v4/
```

