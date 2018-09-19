# Telemetry Channel Behavior

In every ping there are two channels:
- App Update Channel
- Normalized Channel 

## Expected Channels
The traditional channels we expect are:
- `release`
- `beta`
- `aurora` (this is `dev-edition`, and [is just a beta repack](https://developer.mozilla.org/en-US/Firefox/Developer_Edition))
- `nightly`
- `esr`

## App Update Channel
This is the channel reported by the application directly. This could really be anything, but is usually one of the
expected release channels listed above.

### Accessing App Update Channel

#### Main Summary
The field here is called `channel`, e.g.
```
SELECT channel
FROM main_summary
WHERE submission_date_s3 = '20180823'
LIMIT 10
```

#### Other SQL Tables
This will only be available if the `appUpdateChannel` is available in the schema, [See here for an example](https://github.com/mozilla-services/mozilla-pipeline-schemas/blob/master/schemas/telemetry/anonymous/anonymous.4.parquetmr.txt#L10)

The data will be available as follows:
```
SELECT metadata.app_update_channel
FROM telemetry_anonymous_parquet
WHERE submission_date_s3 = '20180823'
LIMIT 10
```

#### In Raw Pings (Using the Dataset API)
NOTE: The querying dimension of the dataset API called `appUpdateChannel` sets any channels not
in the traditional channels list above to `OTHER`. For example, the following would return
no pings:
```
Dataset.from_source("telemetry").where(appUpdateChannel = "non-normalized-channel-name")
```

This would return any non-traditional channels:
```
Dataset.from_source("telemetry").where(appUpdateChannel = "OTHER")
```

This field is available in the metadata in the raw pings. 
```
pings = Dataset.from_source("telemetry").where(docType = "main", submissionDate = "20180823").records()
pings.map(lambda x: x.get("meta", {}).get("appUpdateChannel"))
```

## Normalized Channel
This field is a normalization of `appUpdateChannel`. If the channel doesn't match one of those above,
it is set to `Other`. The only exception is variations on `nightly-cck-*`, which become `nightly`. [See the relevant code here](https://github.com/mozilla-services/lua_sandbox_extensions/blob/14ecde17b118d6734fd70e2dd920d8a91ecf5393/moz_telemetry/modules/moz_telemetry/normalize.lua#L175-L178).

### Accessing Normalized Channel

#### Main Summary
The field here is called `normalized_channel`, e.g.
```
SELECT normalized_channel
FROM main_summary
WHERE submission_date_s3 = '20180823'
LIMIT 10
```

#### Other SQL Tables
This will only be available if the `normalizedChannel` is available in the schema, [See here for an example](https://github.com/mozilla-services/mozilla-pipeline-schemas/blob/master/schemas/telemetry/anonymous/anonymous.4.parquetmr.txt#L11)

The data will be available as follows:
```
SELECT metadata.normalized_channel
FROM telemetry_anonymous_parquet
WHERE submission_date_s3 = '20180823'
LIMIT 10
```

#### In Raw Pings (Using the Dataset API)
This field is available in the metadata in the raw pings. 

```
pings = Dataset.from_source("telemetry").where(docType = "main", submissionDate = "20180823").records()
pings.map(lambda x: x.get("meta", {}).get("normalizedChannel"))
```

## Raw Ping Example
Given that you were looking for the channel `nightly-cck-test`, you would do the following:

1. Filter for channel `OTHER`: `pings = Dataset.from_source("telemetry").where(docType = "main", appUpdateChannel = "OTHER")`
2. Filter the RDD for the full channel: `pings = pings.filter(lambda x: x.get("meta", {}).get("appUpdateChannel") == "nightly-cck-test")`
3. See that the normalized channels is `nightly`: `pings.map(lambda x: x.get("meta", {}).get("normalizedChannel").distinct()`
