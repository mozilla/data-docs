# Telemetry Channel Behavior

In every ping there are two channels:
- App Update Channel
- Normalized Channel 

## Expected Channels
The traditional channels we expect are:
- `release`
- `beta`
- `aurora` (this is `dev-edition`, and is just a beta repack)
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
```

#### Other SQL Tables
This will only be available if the `appUpdateChannel` is available in the schema, [See here for an example](https://github.com/mozilla-services/mozilla-pipeline-schemas/blob/master/schemas/telemetry/anonymous/anonymous.4.parquetmr.txt#L10)

The data will be available as follows:
```
SELECT metadata.app_update_channel
FROM telemetry_anonymous_parquet
WHERE submission_date_s3 = '20180823'
```

#### In Raw Pings (Using the Dataset API)
NOTE: The querying dimension of the dataset API called `appUpdateChannel` is actually the `normalizedChannel`.
For example, the following is actually filtering on `normalizedChannel`, and will return nothing:
```
Dataset.from_source("telemetry").where(appUpdateChannel = "non-normalized-channel-name")
```

This field is available in the metadata in the raw pings. 
```
pings = Dataset.from_source("telemetry").where(docType = "main", submissionDate = "20180823").records()
pings.map(lambda x: x.get("metadata", {}).get("appUpdateChannel"))
```

## Normalized Channel
This field is a normalization of `appUpdateChannel`. If the channel doesn't match one of those above,
it is set to `OTHER`.

### Accessing Normalized Channel

#### Main Summary
The field here is called `normalized_channel`, e.g.
```
SELECT normalized_channel
FROM main_summary
WHERE submission_date_s3 = '20180823'
```

#### Other SQL Tables
This will only be available if the `normalizedChannel` is available in the schema, [See here for an example](https://github.com/mozilla-services/mozilla-pipeline-schemas/blob/master/schemas/telemetry/anonymous/anonymous.4.parquetmr.txt#L11)

The data will be available as follows:
```
SELECT metadata.normalized_channel
FROM telemetry_anonymous_parquet
WHERE submission_date_s3 = '20180823'
```

#### In Raw Pings (Using the Dataset API)
This field can be filtered on by using `appUpdateChannel` in the where clause:
```
Dataset.from_source("telemetry").where(appUpdateChannel = "OTHER")
```

This field is available in the metadata in the raw pings. 
```
pings = Dataset.from_source("telemetry").where(docType = "main", submissionDate = "20180823").records()
pings.map(lambda x: x.get("metadata", {}).get("normalizedChannel"))
```
