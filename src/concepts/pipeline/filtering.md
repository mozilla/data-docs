# Filtering Data

## Table of Contents

<!-- toc -->

## Overview

Data is filtered out of production streams at almost every stage of the pipeline.
The following outlines each stage and both the data currently filtered and the
data that could be filtered. This should help answer two classes of questions:

1. Did my data get filtered out?
2. We've uncovered spurious data being ingested, how should we handle that?

*Note*: [JSON Schema filtering](#json-schema-filtering) is our primary method of filtering out bad data. That should be used before any other methods of dropping data from the pipeline.

## Stages

__Where__ - Which stage of the pipeline this filtering occurs in

__What__ - What happens to the data when filtered here

__When__ - Which situations this filtering should be, and is, used in

__How__ - What kind of data can be filtered at this stage

### Edge filtering

Where: Filtered by nginx, [currently we use it to filter out non-v4 pings](https://github.com/mozilla-services/cloudops-infra/blob/master/projects/data-ingestion/k8s/charts/data-ingestion/templates/filter-configmap.yaml#L14-L41)
([to be removed, but capability to remain](https://bugzilla.mozilla.org/show_bug.cgi?id=1678497)).

What: Drops data entirely from the pipeline; there will be no traces of it downstream from the edge server.

When: Only to be used in extreme situations (e.g. PII exposure). We also use it for dropping [too-large messages](https://github.com/mozilla/gcp-ingestion/blob/master/docs/architecture/overview.md#limits) and [headers](https://github.com/mozilla/gcp-ingestion/blob/master/ingestion-edge/ingestion_edge/util.py#L95).

How: Can be used to filter by URI, namespaces, apps, etc. (from the URL or from the HTTP headers); but not anything in the payload. 

### Beam Filtering

Where: Filtered in the [message scrubber](https://github.com/mozilla/gcp-ingestion/blob/master/ingestion-beam/src/main/java/com/mozilla/telemetry/decoder/MessageScrubber.java).

What: Causes data to be written to the [error stream](#querying-the-error-stream) or to be dropped entirely.

When: Filter out data we absolutely know we will never need to see (e.g. data from forked applications).

How: Can filter out namespaces, doctypes, or URIs currently; in the extreme can filter on any [message Attribute](https://github.com/mozilla/gcp-ingestion/blob/master/ingestion-core/src/main/java/com/mozilla/telemetry/ingestion/core/Constant.java#L8) or payload field.

### JSON Schema Filtering

Where: During ingestion, as defined in the [payload schema](https://github.com/mozilla-services/mozilla-pipeline-schemas/).

What: Causes data to be written to the [error stream](#querying-the-error-stream).

When: When trying to remove bad analysis data that we know we will never need (e.g. huge values, improper strings, etc.). Usually these indicate something went wrong with the payload.

How: Can filter on values in the payload, using the [JSON schema](https://json-schema.org/understanding-json-schema/).

### Filtering from the stable tables

Where: After ingestion to live tables, but [before copying to the stable tables](https://github.com/mozilla/bigquery-etl/blob/master/bigquery_etl/copy_deduplicate.py#L40).

What: Allows data to exist in the live tables, but removes it from the stable tables.

When: Use for data that may be needed for some analyses on recent data, but not for data that will need long-term historical analyses or for use in any downstream reporting. For example, we [filter out pings from automation](https://mozilla.github.io/glean/book/user/debugging/index.html?highlight=sourcetags#enabling-debugging-features-through-environment-variables) (e.g. CI) here, so that analysis is unaffected by them, but we can still analyze what the recent CI data looks like. We also drop duplicate pings (per the document-id).

How: Can filter on any field in the schema, or any metadata.

### Filtering from the exposed views

Where: After ingestion to stable tables ([example](https://github.com/mozilla/bigquery-etl/blob/master/sql/moz-fx-data-shared-prod/telemetry/lockwise_mobile_events_v1/view.sql#L17)).

What: Allows data to exist in stable tables, but not be exposed to users when accessing views.

When: Use for data that is a footgun for end-users (e.g. data that was collected before a product was launched), but will probably be needed by data science or eng.

How: Can filter on any field in the schema, or any metadata.

### Optional filtering in Looker Explores

Where: In the explore, Looker creates a [default filter for a field](https://docs.looker.com/reference/field-params/default_value).

What: Allows data to exist in views, and optionally allows users to query that data (but not by default).

When: Use this for data that most of the time should not be queried in Looker. Downside is too many of these will clutter the Looker explore.

How: Can filter on any field in the schema, or any metadata.

## Querying the Error Stream

The data engineering team has exposed some tables to make querying the error stream easier.

[The schema errors dashboard](https://sql.telemetry.mozilla.org/dashboard/schema-errors) will let you choose your namespace and doctype to see
errors over the past week.

If that data is not granular enough, the error stream can be queried directly:

```sql
SELECT
  udf.parse_desktop_telemetry_uri(uri) AS parsed_uri,
  * EXCEPT(payload),
  udf_js.gunzip(payload) AS payload
FROM
  `moz-fx-data-shared-prod.payload_bytes_error.telemetry`
WHERE
  DATE(submission_timestamp) = "2021-01-07"
LIMIT
  1000
```
