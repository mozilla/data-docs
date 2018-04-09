The `first_shutdown_summary` table is a summary of the [`first-shutdown`
ping](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/first-shutdown-ping.html). 

#### Contents

The first shutdown ping contains first session usage data. The
dataset has rows similar to the
[`telemetry_new_profile_parquet`](/datasets/batch_view/new_profile/reference.md),
but in the shape of
[`main_summary`](/datasets/batch_view/main_summary/reference.md). 

#### Background and Caveats

Ping latency was reduced through the
shutdown ping-sender mechanism in Firefox 55. To maintain consistent historical
behavior, the first main ping is not sent until the second start up. In Firefox 57, a
separate first-shutdown ping was created to evaluate first-shutdown behavior while maintaining backwards compatibility.

In many cases, the first-shutdown ping is a duplicate of the main ping. The first-shutdown summary can be used in conjunction with the main summary by taking the union and deduplicating on the `document_id`.

#### Accessing the Data

The data can be accessed as `first_shutdown_summary`. It is currently stored in the following path.

```
s3://telemetry-parquet/first_shutdown_summary/v4/
```

The data is backfilled to 2017-09-22, the date of its first nightly appearance. This data should be available to all releases on and after Firefox 57.
