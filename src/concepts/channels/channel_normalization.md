# Channel Normalization

This document describes how the data pipeline normalizes channel information
sent by Firefox and makes it accessible to data consumers.

<!-- toc -->

## What are Firefox channels?

In addition to the the `release` channel, which is what we ship to most users,
we also ship development versions of Firefox and an "extended support" (`esr`).
The full list is:

- `release`
- `beta`
- `aurora` (this is `dev-edition`, and [is just a beta repack][deved])
- `nightly`
- `esr`

For more information on this topic, see the [Firefox Release Process page][fx_release_process].

[deved]: https://developer.mozilla.org/en-US/Firefox/Developer_Edition
[fx_release_process]: https://wiki.mozilla.org/Release_Management/Release_Process

## App Update Channel

This is the channel reported by Firefox.
This could really be anything, but is usually one of the expected release channels listed above.

For BigQuery tables corresponding to Telemetry Ping types, such as `main`, `crash` or `event`,
the field here is called `app_update_channel` and is found in `metadata.uri`. For example:

```sql
SELECT
  metadata.uri.app_update_channel
FROM
  telemetry.main
WHERE
  DATE(submission_timestamp) = '2019-09-01'
LIMIT
  10
```

## Normalized Channel

This field is a normalization of the directly reported channel, and replaces unusual
and unexpected values with the string `Other`.
There are a couple of exceptions, notably that variations on `nightly-cck-*` become `nightly`.
[See the relevant code here][normalization].

Normalized channel is available in the Telemetry Ping tables as a top-level field
called `normalized_channel`.
For example:

```sql
SELECT
  normalized_channel
FROM
  telemetry.crash
WHERE
  DATE(submission_timestamp) = '2019-09-01'
LIMIT
  10
```

[normalization]: https://github.com/mozilla/gcp-ingestion/blob/92ba503c4debc887e746d5f2ff5ee60becb8072f/ingestion-beam/src/main/java/com/mozilla/telemetry/transforms/NormalizeAttributes.java#L38
