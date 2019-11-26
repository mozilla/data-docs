# Accessing Heartbeat data

[Heartbeat][heartbeat] survey studies return telemetry on user engagement with the survey prompt.
The heartbeat pings do not contain the survey responses themselves,
which are stored by SurveyGizmo.

The telemetry is received using the `heartbeat` document type,
which is [described in the Firefox source tree docs][hbping].

These pings are aggregated into the `telemetry_heartbeat_parquet` table,
and may also be accessed using the Dataset API.

## Linking Heartbeat responses to telemetry

Heartbeat responses may be linked to Firefox telemetry
if there is a `"includeTelemetryUUID": true` key in the `arguments` object
of the [`show-heartbeat` recipe][show-heartbeat].

Heartbeat never reports telemetry `client_id`s to SurveyGizmo, but,
when `includeTelemetryUUID` is true,
the Normandy `user_id` is reported to SurveyGizmo
as the `userid` URL variable.
Simultaneously, a `heartbeat` ping is sent to Mozilla,
containing both the telemetry `client_id` and the Normandy `userid` that was reported to SurveyGizmo.

The `userid` is reported by appending it to the `surveyId` field of the ping, like:

```
hb-example-slug::e87bcae5-bb63-4829-822a-85ba41ee5d53
```

These can be extracted from the Parquet table for analysis using expressions like:

```
SPLIT(payload.survey_id,'::')[1] AS surveygizmo_userid
```

## Data reference

FIXME The `telemetry_heartbeat_parquet` table
is partitioned by `submission_date_s3`
and has the schema:

```
telemetry_heartbeat_parquet
 |-- type: string (nullable = true)
 |-- id: string (nullable = true)
 |-- creation_date: string (nullable = true)
 |-- version: double (nullable = true)
 |-- client_id: string (nullable = true)
 |-- application: struct (nullable = true)
 |    |-- architecture: string (nullable = true)
 |    |-- build_id: string (nullable = true)
 |    |-- channel: string (nullable = true)
 |    |-- name: string (nullable = true)
 |    |-- platform_version: string (nullable = true)
 |    |-- version: string (nullable = true)
 |    |-- display_version: string (nullable = true)
 |    |-- vendor: string (nullable = true)
 |    |-- xpcom_abi: string (nullable = true)
 |-- payload: struct (nullable = true)
 |    |-- version: long (nullable = true)
 |    |-- flow_id: string (nullable = true)
 |    |-- offered_ts: long (nullable = true)
 |    |-- learn_more_ts: long (nullable = true)
 |    |-- voted_ts: long (nullable = true)
 |    |-- engaged_ts: long (nullable = true)
 |    |-- closed_ts: long (nullable = true)
 |    |-- expired_ts: long (nullable = true)
 |    |-- window_closed_ts: long (nullable = true)
 |    |-- score: long (nullable = true)
 |    |-- survey_id: string (nullable = true)
 |    |-- survey_version: string (nullable = true)
 |    |-- testing: boolean (nullable = true)
 |-- metadata: struct (nullable = true)
 |    |-- timestamp: long (nullable = true)
 |    |-- app_version: string (nullable = true)
 |    |-- date: string (nullable = true)
 |    |-- normalized_channel: string (nullable = true)
 |    |-- app_update_channel: string (nullable = true)
 |    |-- submission_date: string (nullable = true)
 |    |-- geo_city: string (nullable = true)
 |    |-- geo_country: string (nullable = true)
 |    |-- document_id: string (nullable = true)
 |    |-- app_build_id: string (nullable = true)
 |    |-- app_name: string (nullable = true)
 |-- submission_date_s3: string (nullable = true)
 ```

[heartbeat]: https://docs.telemetry.mozilla.org/tools/experiments.html#heartbeat
[hbping]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/heartbeat-ping.html
[show-heartbeat]: https://mozilla.github.io/normandy/user/actions/show-heartbeat.html
