# Sending a Custom Ping

Got some new data you want to send to us? How in the world do you send a new ping? Follow this guide
to find out.

## Write Your Questions

Do not try and implement new pings unless you know specifically what questions you're trying to
answer. General questions about "How do users use our product?" won't cut it - these need to be
specific, concrete asks that can be translated to data points. This will also make it easier down
the line as you start data review.

More detail on how to design and implement new pings for Firefox Desktop [can be found
here](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/collection/custom-pings.html).

## Choose a Namespace and DocType

For new telemetry pings, the namespace is simply `telemetry`. For non-Telemetry pings, choose a
namespace that uniquely identifies the product that will be generating the data.

The DocType is used to differentiate pings within a namespace. It can be as simple as `event`, but
should generally be descriptive of the data being collected.

Both namespace and DocType are limited to the pattern `[a-zA-Z-]`. In other words, hyphens and
letters from the [ISO basic Latin alphabet](https://en.wikipedia.org/wiki/ISO_basic_Latin_alphabet).

## Create a Schema

Use JSON Schema to start with. See the ["Adding a new schema"
documentation](https://github.com/mozilla-services/mozilla-pipeline-schemas#adding-a-new-schema) and
examples schemas in the [Mozilla Pipeline Schemas
repo](https://github.com/mozilla-services/mozilla-pipeline-schemas/). This schema is used to
validate the incoming data; any ping that doesn't match the schema will be removed. This schema will
also be transformed into a BigQuery table schema via the [Mozilla Schema
Generator](https://github.com/mozilla/mozilla-schema-generator). Validate your JSON Schema using a
[validation tool](https://jsonschemalint.com/#/version/draft-04/markup/json).

Ensuring the ping contains a top-level `id` will enable document-level deduplication, which catches
over 90% of duplicates and removes them from the dataset.

## Start a Data Review

Data review for new pings is often more complicated than adding new probes. See [Data Review for
Focus-Event Ping](https://bugzilla.mozilla.org/show_bug.cgi?id=1347266) as an example. Consider
where the data falls under the [Data Collection
Categories](https://wiki.mozilla.org/Firefox/Data_Collection).

## Submit Schema to `mozilla-services/mozilla-pipeline-schemas`

Create a PR including a template and rendered schema to `mozilla-pipeline-schemas`. Add at least one
validation ping that exercises the structure of schema as a test. These pings are validated during
the build and help catch mistakes during the writing process.

### Example: A rendered schema for response times

We may want to collect a set of response measurements in milliseconds on a per-client basis. The
pings take on the following shape:

```json
{"id": "08317b11-85f7-4688-9b35-48af10c3ccdf", "clientId": "1d5ce2fc-a554-42f0-ab21-2ad8ada9bb88", "payload": {"response_ms": 324}}
{"id": "a97108ac-483b-40be-9c64-3419326f5113", "clientId": "3f1b2e1c-c241-464f-aa46-576f5795e488", "payload": {"response_ms": 221}}
{"id": "b8a7e3f9-38c0-4a13-b42a-c969feb454f6", "clientId": "14f27409-5f6f-46e0-9f9d-da5cd716ee42", "payload": {"response_ms": 549}}
```

This document can be described in the following way:

```json
{
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "id": {
            "type": "string",
            "description": "The document identifier"
        },
        "clientId": {
            "type": "string",
            "description": "The client identifier"
        },
        "payload": {
            "type": "object",
            "properties": {
                "response_ms": {
                    "type": "integer",
                    "minimum": 0,
                    "description": "Response time of the client, in milliseconds"
                }
            }
        }
    }
}
```

Fields like `id` and `clientId` have template components as part of the build-system. These would be
included as `@TELEMETRY_ID_1_JSON@` and `@TELEMETRY_CLIENTID_1_JSON@` respectively. The best way to
become familiar with template schemas is to browse the repository; the
[`telemetry/main/main.4.schema.json`
document](https://github.com/mozilla-services/mozilla-pipeline-schemas/blob/master/templates/telemetry/main/main.4.schema.json)
a good starting place.

As part of the automated deployment process, the JSON schemas are translated into a table schema
used by BigQuery. These schemas closely reflect the schemas used for data validation.

```json
[
  {
    "mode": "NULLABLE",
    "name": "clientId",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "id",
    "type": "STRING"
  },
  {
    "fields": [
      {
        "mode": "NULLABLE",
        "name": "response_ms",
        "type": "INT64"
      }
    ],
    "mode": "NULLABLE",
    "name": "payload",
    "type": "RECORD"
  }
]
```

### Ingestion Metadata

The generated schemas contain metadata added to the schema before deployment to the ingestion
service. These are fields added to the ping at ingestion time; they might come from the URL
submitted to the edge server, or the IP Address used to make the request. [This
document](https://github.com/mozilla-services/mozilla-pipeline-schemas/blob/master/schemas/metadata/telemetry-ingestion/telemetry-ingestion.1.schema.json)
lists available metadata fields for the telemetry-ingestion pings, which are largely shared across
all namespaces.

A list of metadata fields are listed here for reference, but refer to the above document or the
schema explorer for an up-to-date list of metadata fields.

<!-- table generated via `scripts/new_ping_metadata_table.py > src/cookbooks/new_ping_metadata_table.md` -->

{{#include ./new_ping_metadata_table.md}}

### Testing The Schema

For new data, use the [edge validator](https://github.com/mozilla-services/edge-validator) to test
your schema.

## Deployment

Schemas are automatically deployed once a day around 00:00 UTC, scheduled after the probe scraper in
the following [Airflow
DAG](https://github.com/mozilla/telemetry-airflow/blob/master/dags/probe_scraper.py). The latest
schemas can be viewed at
[`mozilla-pipeline-schemas/generated-schemas`](https://github.com/mozilla-services/mozilla-pipeline-schemas/tree/generated-schemas).

## Start Sending Data

Use the built-in Telemetry APIs when possible. A few examples are the [Gecko Telemetry
APIs](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/collection/custom-pings.html),
the [Android Telemetry APIs](https://github.com/mozilla-mobile/telemetry-android), or the [iOS
Telemetry APIs](https://github.com/mozilla-mobile/telemetry-ios).

For all other use-cases, send documents to the ingestion endpoint:

```text
https://incoming.telemetry.mozilla.org
```

See [the HTTP edge server specification](../concepts/pipeline/http_edge_spec.md) and the
[non-Telemetry example](../concepts/pipeline/http_edge_spec.md#postput-request) for documentation
about the expected format.

## Access Your Data

First confirm with the reviewers of [your schema pull
request](#submit-schema-to-mozilla-servicesmozilla-pipeline-schemas) that your schemas have been
deployed. You may also check the diff of the latest commit to [`mozilla-pipeline-schemas/generated
schemas`](https://github.com/mozilla-services/mozilla-pipeline-schemas/tree/generated-schemas).

In the following links, replace `<namespace>`, `<doctype>` And `<docversion>` with appropriate
values. Also replace `-` with `_` in `<namespace>` if your namespace contains `-` characters.

### STMO / BigQuery

In the BigQuery (beta) data source, several new tables will be created for your data. 

The first table is the live table found under
`moz-fx-data-shared-prod.<namespace>_live.<doctype>_v<docversion>`. This table is updated on a 5
minute interval, partitioned on `submission_timestamp`, and may contain partial days of data.

```sql
SELECT
    count(*) as n_rows
FROM
  `moz-fx-data-shared-prod.telemetry_live.main_v4`
WHERE
  submission_timestamp > TIMESTAMP_SUB(current_timestamp, INTERVAL 30 minute)
```

The second table that is created is the clustered table under
`moz-fx-data-shared-prod.<namespace>_stable.<doctype>_v<docversion>`. This table will only contain
complete days of submissions. The data is clustered by `submission_timestamp` and `sample_id` to
improve the efficiency of queries.

```sql
SELECT
  COUNT(DISTINCT client_id)*100 AS dau
FROM
  `moz-fx-data-shared-prod.telemetry_stable.main_v4`
WHERE
  submission_timestamp > TIMESTAMP_SUB(current_timestamp, INTERVAL 1 day)
  AND sample_id = 1
```

For convenience, `moz-fx-data-shared-prod.<namespace>.<doctype>` is an alias to the latest, stable
table.

```sql
SELECT
  COUNT(DISTINCT client_id)*100 AS dau
FROM
  `moz-fx-data-shared-prod.telemetry.main`
WHERE
  submission_timestamp > TIMESTAMP_SUB(current_timestamp, INTERVAL 1 day)
  AND sample_id = 1
```

This table may take up to a day to appear in the BigQuery source; if you still don't see a table for
your new ping after 24 hours, [contact Data
Operations](https://mana.mozilla.org/wiki/display/SVCOPS/Contacting+Data+Operations) so that they
can investigate. Once the table is available, it should contain all the pings sent during that first
day, regardless of how long it takes for the table to appear.

### Spark

Refer to the [Spark FAQ](../cookbooks/bigquery.md#from-spark) for details on accessing this table
via Spark.

## Build Dashboards Using Spark or STMO

Last steps! What are you using this data for anyway?
