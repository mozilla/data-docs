# Guiding Principles for Data Infrastructure

So you want to build a data lake... Where do you start? What building blocks are
available? How can you integrate your data with the rest of the organization?

This document is intended for a few different audiences. Data consumers within
Mozilla will gain a better understanding of the data they interact with by
learning how the Firefox telemetry pipeline functions. Mozilla teams outside of
Firefox will get some concrete guidance about how to provision and lay out data
in a way that will let them integrate with the rest of Mozilla. Technical
audiences outside Mozilla will learn some general principles and come away with
links to concrete examples of code implementing those principles.

Considering that Mozilla has chosen GCP as its major cloud provider, BigQuery
stands out as the clear integration point for data at rest among GCP's portfolio
of products. BigQuery has proven to be a best-in-class data warehouse with
impressive performance and a familiar SQL interface. Beyond that, it provides
many conveniences that become important when scaling across an organization such
as automated retention policies and well-defined access controls that can be
provisioned across projects to allow different teams to have control over their
own data.

Data can be loaded into BigQuery or presented as external tables through a
growing list of Google-provided integrations (objects in GCS, logs in
Stackdriver, etc.). Users within Mozilla can also take advantage of
purpose-built infrastructure that other teams within the company have used for
loading data to BigQuery. The major example is our telemetry ingestion system
which accepts payloads from Firefox clients across the world but also provides a
generic interface for defining custom schemas and accepting payloads from any
system capable of making an HTTP request. We also have tooling available for
transforming data (ETL) once it's in BigQuery.

Once data is accessible through BigQuery, users within Mozilla also get the
benefit of leveraging common tools for data access. Beyond the Google-provided
BigQuery console, Mozilla provides access to instances of Redash,
Tableau, and other tools either with connections to BigQuery already available
or with concrete instructions for provisioning connections.

Some near real-time use cases can be handled via BigQuery as well, with BigQuery
supporting dozens of batch loads per table per hour and even streaming inserts.
For true latency-sensitive applications, however, we pass data via Cloud
Pub/Sub, GCP's hosted messaging backend. Pub/Sub integrates very closely with
Cloud Dataflow to provide auto-scaling pipelines with relatively little setup
needed. We can also easily provision topics for subsets of data flowing through
the telemetry pipeline as input for custom streaming applications.

To avoid getting too abstract, we'll next dive into a case study of what it
looked like for a team within Mozilla to migrate from a custom pipeline to the
main GCP-based pipeline that supports telemetry data. From there, we'll discuss
specific best practice recommendations for use of each of the major GCP services
in use at Mozilla.

## Integrating with the Data Pipeline: A Case Study

Mozilla's core data platform has been built to support _structured ingestion_ of
arbitrary JSON payloads whether they come from browser products on client
devices or from server-side applications that have nothing to do with Firefox;
any team at Mozilla can hook into structured ingestion by defining a schema and
registering it with pipeline. Once a schema is registered, everything else is
automatically provisioned, from an HTTPS endpoint for accepting payloads to a
set of tables in BigQuery for holding the processed data.

Over the course of 2019, the Activity Stream team migrated analytics for Firefox
Desktop's New Tab page from a custom service to the core data platform. The old
system already relied on sending JSON data over HTTP, so the team wanted to
minimize client-side development effort by maintaining the existing payload
structure. They registered the structure of these payloads by sending pull
requests to our schema repository with relevant [JSON
Schema](https://json-schema.org/) definitions. As an example,
[`mozilla-pipeline-schemas#228`](https://github.com/mozilla-services/mozilla-pipeline-schemas/pull/228)
adds a new document namespace `activity-stream` and under that a document type
`impression-stats` with version specified as `1`. These changes are picked up by
an automated job that translates them into relevant BigQuery schemas and
provisions tables for each unique schema (see
[Defining Tables](#defining-tables) below).

With the schema now registered with the pipeline, clients can send payloads to
an endpoint corresponding to the new namespace, document type, and version:

```
https://incoming.telemetry.mozilla.org/submit/activity-stream/impression-stats/1/<document_id>
```

where `<document_id>` should be a UUID that uniquely identifies the payload;
`document_id` is used within the pipeline for deduplication of repeated
documents. The payload is processed by a small edge service that returns a 200
response to the client and publishes the message to a _raw_ Pub/Sub topic. A
_decoder_ Dataflow job reads from this topic with low latency, validates that
the payload matches the schema registered for the endpoint, does some additional
metadata processing, and then emits the message back to Pub/Sub in a _decoded_
topic. A final job reads the _decoded_ topic, batches together records
destined for the same table, and loads the records into the relevant _live ping
table_ in BigQuery (`activity_stream_live.impression_stats_v1` in this case). A
nightly job reads all records for the previous day from the live ping table,
deduplicates the records based on `document_id` values, and loads the final
deduplicated day to the relevant _historical ping table_
(`activity_stream_stable.impression_stats_v1`). The results are automatically
presented to users through a view (`activity_stream.impression_stats`).

While most analysis use cases for this data are served via queries on the
user-facing BigQuery view, the Pocket team also needed to build an application
with access to `activity-stream` messages in real-time. To serve that need,
Pocket provisioned a Pub/Sub topic in a separate GCP project and worked with
Data Operations to provide write access to a relevant service account within the
telemetry pipeline. The pipeline is now configured to republish all messages
associated with the `activity-stream` namespace to Pocket's topic, and this has
been able to serve their real-time needs.

## Glean

While the Activity Stream case study above serves as an encouraging example of
the flexibility of the pipeline to accept custom payloads, we hope to insulate
most data producers in the future from having to interact directly with HTTP
requests and JSON Schema definitions at all. The state of the art for analytics
at Mozilla is
[Glean](../concepts/glean/glean.md), a set of
projects that reimagines the end-to-end experience of reporting and consuming
analytics data.

Glean sits on top of structured ingestion, but provides helpful
abstractions &mdash; instead of building JSON payloads and making HTTP requests, your
application declares logical metrics and makes calls to a generated SDK
idiomatic to your application's language. Support is emerging not only for a
wide range of language SDKs, but also for a variety of prebuilt reporting tools
that understand Glean schemas such that your application's metrics are
automatically processed and presented.

All new use cases for producing analytics payloads within Mozilla should
consider Glean first. If a mature Glean SDK is available for your project's
language, building on top of Glean promises maintainable reporting code for your
application and data that can be more richly understood by the full ecosystem of
analytics tools at Mozilla.

## Structured Ingestion

We discussed the overall shape of Mozilla's structured ingestion system and how
to integrate with it in the case study earlier in this article, so this section
will be brief.

When you choose to build on top of structured ingestion, whether
using the Glean SDK or by registering custom named schemas, consider the
following concerns which are automatically handled for you:

- Validation of payloads against a JSON schema; messages failing validation are
  routed to an errors table in BigQuery where they can be monitored and
  backfilled if necessary.
- Geo lookup using a GeoIP database; geo-city information is
  presented as metadata, allowing the pipeline to discard source IP addresses to
  protect user privacy.
- User agent parsing; major user agent features are extracted and presented as
  metadata, allowing the pipeline to discard the raw user agent string to
  protect user privacy.
- Extraction of client-level identifiers as metadata to use for generating a
  [`sample_id`](https://docs.telemetry.mozilla.org/concepts/sample_id.html) field
  and to support automated deletion of data upon user request.
- Deduplication of messages; we provide best-effort deduplication for output
  Pub/Sub topics and full deduplication within each UTC day in the historical
  ping tables in BigQuery.

If you have doubts about whether structured ingestion is appropriate for your
use case, [please reach out to the Data Platform
team](https://docs.telemetry.mozilla.org/concepts/getting_help.html) and we can
consult on current and planned features for the pipeline.

## BigQuery

[BigQuery](https://cloud.google.com/bigquery/docs/) is the standard choice within
Mozilla's environment for storing structured data for non-real time analysis. It
is especially well suited to large and diverse organizations because of its access
controls and full separation between storage and compute infrastructure. Different
teams within Mozilla can provision BigQuery tables in separate GCP projects,
retaining full control over how they ingest data and how they grant access to
other teams. Once access is granted, though, it becomes trivial to write queries
that join data across projects.

The per-GB pricing for storing data in BigQuery is identical to pricing for GCS,
so BigQuery can in some ways be treated as an advanced filesystem that has deep
knowledge of and control over data structure. Be aware that while BigQuery
compresses data under the hood, pricing reflects the uncompressed data size and
users have no view into how data is compressed. It is still possible, however,
to use BigQuery as an economical store for compressed data by saving compressed
blobs in a `BYTES` column. Additional fields can be used like metadata. For
examples, see the _raw_ schema from the pipeline
([JSON schema](https://github.com/mozilla-services/mozilla-pipeline-schemas/blob/80386c53b8e6910068964bd7c09904326b9480fd/schemas/metadata/raw/raw.1.schema.json)
and final
[BigQuery schema](https://github.com/mozilla-services/mozilla-pipeline-schemas/blob/43edf3ffff932eb89f3e2a1092696d0d0081c43b/schemas/metadata/raw/raw.1.bq)).

### Defining tables

BigQuery tables can express complex nested structures via compound `STRUCT`
types and `REPEATED` fields. It's possible to model arbitrary JSON payloads as
BigQuery tables, but there are
[limitations to JSON modeling](https://cloud.google.com/bigquery/docs/loading-data-cloud-storage-json#limitations)
that are well-described in BigQuery's documentation.

We have developed tooling for translating JSON schemas into BigQuery table
schemas along with some conversion code to transform payloads to match the final
structure needed in BigQuery. One major example is map types; when the number of
possible keys is finite, they can be baked into the schema to present the map as
a BigQuery `STRUCT` type, but free-form maps have to be modeled in BigQuery as a
repeated `STRUCT` of keys and values. This is one case where we have chosen to
follow the same conventions that BigQuery itself uses for [converting complex
Avro types to BigQuery
fields](https://cloud.google.com/bigquery/docs/loading-data-cloud-storage-avro#complex_types),
which requires modifying the JSON payload to convert

```json
{
  "key1": "value1",
  "key2": "value2"
}
```

into

```json
[
  {
    "key": "key1",
    "value": "value1"
  },
  {
    "key": "key2",
    "value": "value2"
  }
]
```

For more detail on how the data pipeline prepares schemas and translates
payloads, see the
[`jsonschema-transpiler`](https://github.com/mozilla/jsonschema-transpiler)
project which is used by
[`mozilla-schema-generator`](https://github.com/mozilla/mozilla-schema-generator/).

### How to get data into BigQuery

Google provides a variety of methods for loading data into BigQuery as discussed
in their [Introduction to Loading
Data](https://cloud.google.com/bigquery/docs/loading-data). The traditional path
for loading data is a custom application that uses a Google Cloud SDK to stage
objects in GCS and then issue BigQuery load jobs, but there is also a growing
list of more fully managed integrations for loading data. It is also possible to
present views into data stored in other Google services without loading via
external tables.

If you already have well-structured data being produced to Stackdriver or GCS,
it may be minimal effort to set up BigQuery Transfer Service to import that data
or even to modify your existing server application to additionally issue
BigQuery load jobs. Google does not yet provide an integration with Cloud SQL,
but there has been significant interest within Mozilla for that feature and we
may look into providing a standard solution for ingesting Cloud SQL databases to
BigQuery in 2020.

And don't forget about the possibility of hooking into the core telemetry
pipeline through _structured ingestion_ as discussed earlier.

If you have a more complex processing need that doesn't fit into an existing
server application, you may want to consider building your application as a
Dataflow pipeline (discussed further down in this document). Dataflow provides a
unified model for batch and streaming processing and includes a variety of
high-level I/O modules for reading from and writing to Google services such as
BigQuery.

### Time-based partitioning and data retention in BigQuery

BigQuery provides built-in support for [rolling time-based retention at the
dataset and table
level](https://cloud.google.com/bigquery/docs/best-practices-storage). For the
telemetry pipeline, we have chosen to partition nearly all of our tables based
on the date we receive the payloads at our edge servers. Most tables will
contain a field named `submission_timestamp` or `submission_date` that
BigQuery automatically uses to control the assignment of rows to partitions as
they are loaded.

Full day partitions are the fundamental unit we use for all backfill and ETL
activities and BigQuery provides convenient support for operating on discrete
partitions. In particular, BigQuery jobs can be configured to specify an
individual partition as the destination for output (using a partition decorator
looks like `telemetry_stable.main_v4$20191201`), allowing processing to be
idempotent.

Partitions can also be used as the unit for data retention. For the telemetry
pipeline, we have long retention periods only for the _historical ping tables_
(e.g. `telemetry_stable.main_v4`) and downstream derived tables (e.g.
`telemetry_derived.clients_daily_v6`). Storing intermediate data for long periods
can be expensive and expose risk, so all of the intermediate tables including the
_live ping tables_ (e.g. `telemetry_live.main_v4`) have partition-based expiration
such that partitions older than 30 days are automatically cleaned up. This
policy balances cost efficiency with the need for a window where we can recover
from errors in the pipeline.

The telemetry pipeline is building support for accepting `deletion-request` pings
from users and purging rows associated with those users via scheduled jobs. Such
a mechanism can be helpful in addressing policy and business requirements, so
the same considerations should be applied to custom applications storing
messages that contain user identifiers.

### Access controls in BigQuery

BigQuery provides 3 levels for organizing data: _tables_ live within _datasets_
inside _projects_. Fully qualified table references look like
`<project>.<dataset>.<table>`; a query that references
`moz-fx-data-shared-prod.telemetry_live.main_v4` is looking for a table named
`main_v4` in a dataset named `telemetry_live` defined in GCP project
`moz-fx-data-shared-prod`.

At the time of writing, BigQuery's access controls primarily function at the
dataset level, which has implications for how you choose to name tables and
group them into datasets. If all of your data can use the same access policy,
then a single dataset is sufficient and can hold all of your tables, but you may
still choose to use multiple datasets for logical organization of related
tables.

You can also publish SQL views which are essentially prebuilt queries that are
presented alongside tables in BigQuery. View logic is executed at query time, so
views take up no space and users are subject to the same access controls when
querying a view as they would be querying the underlying tables themselves; a
query will fail if the user does not have read access to all of the datasets
accessed in the view.

Views, however, can also be _authorized_ so that specific groups of users can
run queries who would not normally be allowed to read the underlying tables.
This allows view authors to provide finer-grained controls and to hide specific
columns or rows.

## Pub/Sub

[Google Cloud Pub/Sub](https://cloud.google.com/pubsub/docs/) is the standard
choice within Mozilla's environment for transferring data between systems in
real-time. It shares many of the same benefits as BigQuery in terms of being
fully hosted, scalable, and well-integrated with the rest of the GCP environment,
particularly when it comes to access controls.

We use Pub/Sub as the messaging backbone for the telemetry ingestion system and
we can easily provision new Pub/Sub topics containing republished subsets of the
telemetry data for other systems to hook into. We have support for either
producing messages into an external topic controlled by a different team or for
provisioning a new topic within the telemetry infrastructure and granting read
access to individual service accounts as needed.

Pub/Sub is the clear integration point with the telemetry system for any
application that is concerned with up-to-the-minute latency. For applications
that only need to see periodic recent views of telemetry data, be aware that
_live ping tables_ (i.e. `telemetry_live.main_v4`) in BigQuery are also an option.
New data is loaded into those tables throughout the day either on a 10 minute
cadence or as they arrive via streaming inserts to BigQuery. Please contact us
if there's a subset of data you'd like us to consider opting in for streaming
inserts.

## Dataflow

[Google Cloud Dataflow](https://cloud.google.com/dataflow/docs/) is a service
for running data processing applications using the Apache Beam SDKs in both
batch and streaming modes. Understanding the Beam programming model requires
a certain amount of developer investment, but Beam provides powerful abstractions
for data transformations like windowed joins that are difficult to implement
reliably by hand.

The Dataflow jobs in use by the data platform actually don't require complex
joins or windowing features, but we have found Beam's I/O abstractions useful
for being able to adapt a single code base to handle reading from and writing to
a variety of data stores. Dataflow also provides good built-in support for
auto-scaling streaming jobs based on latency and observed throughput, especially
when interacting with Pub/Sub. That said, the I/O abstractions allow only
limited control over performance and we have found the need to replace some of
our Dataflow jobs with custom applications running on GKE &mdash; particularly
the jobs focused on batching together messages from Pub/Sub and sinking to GCS
or BigQuery.

Beam's `BigQueryIO` module requires shuffling data several times when writing,
checkpointing the intermediate state to local disk. This incurs expense for
provisioning local solid state drives to handle the checkpointing throughput and
introduces the possibility of data loss on unclean shutdown since messages have
to be acknowledged back to Pub/Sub at the time data is first checkpointed rather
than when it is finally written to BigQuery. We were able to achieve lower cost
and more straight-forward delivery guarantees by writing a custom application
using the Google Cloud Java SDK. We still use a streaming Dataflow job for the
_decoder_ step of the pipeline since no checkpointing is needed for a simple job
that both reads from and writes to Pub/Sub. We also rely on Dataflow batch jobs
for all backfill activities.

If your team has streaming needs where Dataflow makes sense, be aware that the
Data Operations team can provide operational support to help you launch and
manage pipelines.

## Derived Data and Airflow

The structure in which data is ingested to BigQuery is often not the most
convenient or efficient structure for analysis queries, so it is often necessary
to provide logical views of the data to support users. Our interface for
defining such views is the
[`bigquery-etl`](https://github.com/mozilla/bigquery-etl) repository which
provides instructions for how to propose new tables and views by sending pull
requests containing SQL queries.

We use BigQuery _views_ heavily to improve the usability of raw data and we
recommend that you do too! As discussed in the
[BigQuery Access Controls](#access-controls-in-bigquery) section above,
views take up no storage resources and are essentially reusable snippets
that appear like tables, but the underlying logic is executed every time a user
queries a view. For simple cases like renaming fields or unnesting array
columns, a view is often the right choice as it can be defined once and requires
no ongoing scheduling or maintenance.

If, however, you want to provide users with a view that involves joins or
aggregations that hit a great deal of data, you may find that queries slow down
and become expensive. In those cases, it may be better to materialize the
results of the view into a derived table. See the [Scheduling BigQuery Queries
in Airflow](https://docs.telemetry.mozilla.org/cookbooks/bigquery-airflow.html)
cookbook for a walk-through of how to define a query in `bigquery-etl` and
get it scheduled to run nightly on the data platform's Airflow instance. We hope
to simplify that process in 2020 and provide better support for being able to
access and write data in arbitrary GCP projects rather than just in the data
pipeline's `shared-prod` project.

## Final Thoughts

While no single data architecture can meet all needs, the core pipeline at
Mozilla has been built with flexibility in mind. We have a growing list of
success cases and some major projects in the works to migrate legacy pipelines
to the system &mdash; these are good indicators that we are meeting a broad set of
needs for the majority data warehousing use case and that we provide a stable
ingestion system for streaming applications as well.

GCP's roster of services is fairly well-focused compared to other cloud
providers, but it can still be overwhelming to sort through the available
options, particularly where multiple services seem to occupy the same space.
Consult the unofficial [GCP
flowcharts](https://grumpygrace.dev/posts/gcp-flowcharts/) for a broad view of
how to sort through the features of services that apply to different problem
domains. We encourage the use of BigQuery, Pub/Sub, and Dataflow as core
building blocks for custom data applications across Mozilla for ease of access
control across projects and for leveraging shared knowledge about how to operate
and integrate with those services. Possibilities in the cloud can seem endless,
but the more we can standardize architectural approaches across the company, the
better prepared we will be to collaborate across product teams and ultimately
the better positioned we will be to realize our mission. Let's work together to
keep individuals empowered, safe, and independent on the Internet.
