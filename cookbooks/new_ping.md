# Sending a Custom Ping

Got some new data you want to send to us? How in the world do you send a new ping? Follow this guide
to find out.

Write Your Questions
--------------------
Do not try and implement new pings unless you know specifically what questions you're trying to
answer. General questions about "How do users use our product?" won't cut it - these need to be
specific, concrete asks that can be translated to data points. This will also make it easier down
the line as you start data review.

More detail on how to design and implement new pings for Firefox Desktop [can be found here](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/collection/custom-pings.html).

Choose a Namespace and DocType
------------------------------
For new telemetry pings, the namespace is simply `telemetry`. For non-Telemetry
pings, choose a namespace that uniquely identifies the product that will be
generating the data.

The DocType is used to differentiate pings within a namespace. It can be as
simple as `event`, but should generally be descriptive of the data being
collected.

Both namespace and DocType are limited to the pattern `[a-zA-Z-]`. In other words, hyphens and letters from the [ISO basic Latin alphabet](https://en.wikipedia.org/wiki/ISO_basic_Latin_alphabet).

Create a Schema
---------------
Use JSON Schema to start with. See the ["Adding a new schema" documentation](https://github.com/mozilla-services/mozilla-pipeline-schemas#adding-a-new-schema) and examples schemas in the
[Mozilla Pipeline Schemas repo](https://github.com/mozilla-services/mozilla-pipeline-schemas/).
This schema is just used to validate the incoming data; any ping that doesn't match the schema
will be removed. Validate your JSON Schema using a
[validation tool](https://jsonschemalint.com/#/version/draft-04/markup/json).

We already have automatic deduplicating based on `docId`, which catches about 90% of duplicates and
removes them from the dataset.

Start a Data Review
-------------------
Data review for new pings is more complicated than when adding new probes. See
[Data Review for Focus-Event Ping](https://bugzilla.mozilla.org/show_bug.cgi?id=1347266)
as an example. Consider where the data falls in the
[Data Collection Categories](https://wiki.mozilla.org/Firefox/Data_Collection).

Submit Schema to `mozilla-services/mozilla-pipeline-schemas`
------------------------------------------------------------
The first schema added should be the JSON Schema made in step 2.
Add at least one example ping which the data can be validated against.
These test pings will be validated automatically during the build.

Additionally,
a [Parquet output](https://github.com/mozilla-services/mozilla-pipeline-schemas/blob/master/schemas/telemetry/core/core.9.parquetmr.txt)
schema should be added. This would add a new dataset, available in [Re:dash](https://sql.telemetry.mozilla.org).
The best documentation we have for the Parquet schema is by looking at the examples in
[`mozilla-pipeline-schemas`](https://github.com/mozilla-services/mozilla-pipeline-schemas).

Parquet output also has a `metadata` section. These are fields added to the ping at ingestion time;
they might come from the URL submitted to the edge server, or the IP Address used to make the request.
[This document](https://pipeline-cep.prod.mozaws.net/dashboard_output/analysis.moz_telemetry_parquet_schema.parquet.txt)
lists available metadata fields for all pings.

The stream you're interested in is probably `telemetry`.
For example, look at `system-addon-deployment-diagnostics` immediately under the `telemetry` top-level
field. The `schema` element has top-level fields (e.g. `Timestamp`, `Type`), as well as more fields
under the `Fields` element. Any of these can be used in the `metadata` section of your parquet schema,
except for `submission`.

Some common ones for Telemetry data might be:
- `Date`
- `submissionDate`
- `geoCountry`
- `geoCity`
- `geoSubdivision1`
- `geoSubdivision2`
- `normalizedChannel`
- `appVersion`
- `appBuildId`

And for non-Telemetry data:
- `geoCountry`
- `geoCity`
- `geoSubdivision1`
- `geoSubdivision2`
- `documentId`

*Important Note*: Schema evolution of nested structs is currently broken, so you will not be able to add
any fields in the future to your `metadata` section. We recommend adding any that may seem useful.

### Testing The Schema
For new data, use the [edge validator](https://github.com/mozilla-services/edge-validator) to test
your schema.

If your data is _already_ being sent, and you want to test the schema you're writing on the data
that is currently being ingested, you can test your Parquet output in
[Hindsight](https://pipeline-cep.prod.mozaws.net/) by using an output plugin.
See [Core ping output plugin](https://bugzilla.mozilla.org/attachment.cgi?id=8829626)
for an example, where the parquet schema is specified as `parquet_schema`. If no errors arise, that
means it should be correct. The "Deploy" button should not be used to actually deploy, that will be
done by operations in the next step.

(Telemetry-specific) Deploy the Plugin
--------------------------------------
File [a bug to deploy the new schema.](https://bugzilla.mozilla.org/show_bug.cgi?id=1333203)

Real-time analysis will be key to ensuring your data is being processed and parsed correctly.
It should follow the format specified in
[MozTelemetry `docType` monitor](https://mozilla-services.github.io/lua_sandbox_extensions/moz_telemetry/sandboxes/heka/analysis/moz_telemetry_doctype_monitor.html).
This allows you to check validation errors, size changes, duplicates, and more. Once you have
the numbers set, file a
[bug to let ops deploy it](https://bugzilla.mozilla.org/show_bug.cgi?id=1356380).

Start Sending Data
------------------
If you're using the Telemetry APIs, use those built-in. These can be with the
[Gecko Telemetry APIs](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/collection/custom-pings.html),
the [Android Telemetry APIs](https://github.com/mozilla-mobile/telemetry-android), or the
[iOS Telemetry APIs](https://github.com/mozilla-mobile/telemetry-ios).

For non-Telemetry data, see [our HTTP edge server specification](../concepts/pipeline/http_edge_spec.md)
and specifically the [non-Telemetry example](../concepts/pipeline/http_edge_spec.md#postput-request) for the expected format. The edge
server endpoint is `https://incoming.telemetry.mozilla.org`.

(Non-Telemetry) Access Your Data
--------------------------------
First confirm with the reviewers of
[your schema pull request](#submit-schema-to-mozilla-servicesmozilla-pipeline-schemas)
that your schemas have been deployed.

In the following links, replace `<namespace>`, `<doctype>` And `<docversion>` with
appropriate values. Also replace `-` with `_` in `<namespace>` if your
namespace contains `-` characters.

### CEP
Once you've sent some pings, refer to the following real-time analysis plugins
to verify that your data is being processed:

- `https://pipeline-cep.prod.mozaws.net/dashboard_output/graphs/analysis.moz_generic_error_monitor.<namespace>.html`
- `https://pipeline-cep.prod.mozaws.net/dashboard_output/analysis.moz_generic_<namespace>_<doctype>_<docversion>.submissions.json`
- `https://pipeline-cep.prod.mozaws.net/dashboard_output/analysis.moz_generic_<namespace>_<doctype>_<docversion>.errors.txt`

If this first graph shows ingestion errors, you can view the corresponding
error messages in the third link. Otherwise, you should be able to view the
last ten processed submissions via the second link. You can also write your own
custom real-time analysis plugins using this same infrastructure if you desire;
use the above plugins as examples and see
[here](realtime_analysis_plugin.md) for a more detailed explanation.

If you encounter schema validation errors, you can fix your data or
[submit another pull request](#submit-schema-to-mozilla-servicesmozilla-pipeline-schemas)
to amend your schemas. Backwards-incompatible schema changes should generally
be accompanied by an increment to `docversion`.

Once you've established that your pings are flowing through the real-time
system, verify that you can access the data from the downstream systems.

### STMO
In the Athena data source, a new table
`<namespace>_<doctype>_parquet_<docversion>` will be created for your data. A
convenience pointer `<namespace>_<doctype>_parquet` will also refer to the latest
available `docversion` of the ping. The data is partitioned by
`submission_date_s3` which is formatted as `%Y%m%d`, like `20180130`, and is
generally updated hourly. Refer to the [STMO documentation](../tools/stmo.md)
for general information about using Re:dash.

This table may take up to a day to appear in the Athena source; if you still
don't see a table for your new ping after 24 hours,
[contact Data Operations](https://mana.mozilla.org/wiki/display/SVCOPS/Contacting+Data+Operations)
so that they can investigate. Once the table is available, it should contain
all the pings sent during that first day, regardless of how long it takes for
the table to appear.

### ATMO
The data should be available in S3 at:

`s3://net-mozaws-prod-us-west-2-pipeline-data/<namespace>-<doctype>-parquet/v<docversion>/`

Note: here `<namespace>` should not be escaped.

Refer to the [Spark FAQ](../tools/spark.md#faq) for details on accessing this table via ATMO.

Write ETL Jobs
--------------
We have some basic generalized ETL jobs you can use to transform your data on a batch basis - for example,
a [Longitudinal](https://github.com/mozilla/telemetry-batch-view/blob/master/src/main/scala/com/mozilla/telemetry/views/GenericLongitudinal.scala)
or [client-count-daily](https://github.com/mozilla/telemetry-batch-view/blob/master/src/main/scala/com/mozilla/telemetry/views/GenericCountView.scala)
like dataset. Otherwise, you'll have to write your own.

You can schedule it on [Airflow](http://workflow.telemetry.mozilla.org/), or you can
run it as a job in ATMO. If the output is parquet, you can add it to the Hive metastore to have it
available in re:dash. Check the docs on [creating your own datasets](create_a_dataset.md).

Build Dashboards Using ATMO or STMO
-----------------------------------
Last steps! What are you using this data for anyway?
