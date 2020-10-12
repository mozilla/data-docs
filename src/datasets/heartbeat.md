# Accessing Heartbeat data

[Heartbeat][heartbeat] survey studies return telemetry on user engagement with the survey prompt.
The heartbeat pings do not contain the survey responses themselves,
which are stored by SurveyGizmo.

The telemetry is received using the `heartbeat` document type,
which is [described in the Firefox source tree docs][hbping].

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

These can be extracted from the ping table for analysis using expressions like:

```sql
SPLIT(payload.survey_id,'::')[OFFSET(1)] AS surveygizmo_userid
```

## Data reference

Heartbeat data is available in the `telemetry.heartbeat` table in BigQuery.

Its structure matches the [heartbeat ping schema].

[heartbeat]: https://docs.telemetry.mozilla.org/tools/experiments.html#heartbeat
[hbping]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/heartbeat-ping.html
[show-heartbeat]: https://mozilla.github.io/normandy/user/actions/show-heartbeat.html
[heartbeat ping schema]: https://github.com/mozilla-services/mozilla-pipeline-schemas/blob/8b0641ebb8aad570b79e811ae10fd81c718af48f/schemas/telemetry/heartbeat/heartbeat.4.schema.json
