Got some new data you want to send to us? How in the world do you send a new ping? Follow this guide
to find out.

Write Your Questions
--------------------
Do not try and implement new pings unless you know specifically what questions you're trying to
answer. General questions about "How do users use our product?" won't cut it - these need to be
specific, concrete asks that can be translated to data points. This will also make it easier down
the line as you start data review.

Create a Schema
---------------
Use JSON Schema to start with. See the examples schemas in the
[Mozilla Pipeline Schemas repo](https://github.com/mozilla-services/mozilla-pipeline-schemas/).
This schema is just used to validate the incoming data; any ping that doesn't match the schema
will be removed. Validate your JSON Schema using a
[validation tool](https://jsonschemalint.com/#/version/draft-04/markup/json).

We already have automatic deduping based on docId, which catches about 90% of duplicates and removes
them from the dataset.

Start a Data Review
-------------------
Data review for new pings is more complicated than when adding new probes. See
[Data Review for Focus-Event Ping](https://bugzilla.mozilla.org/show_bug.cgi?id=1347266)
as an example. Consider where the data falls in the
[Data Collection Categories](https://wiki.mozilla.org/Firefox/Data_Collection).

Submit Schema to mozilla-services/mozilla-pipeline-schemas
----------------------------------------------------------
The first schema added should be the JSON Schema made in step 2.
Make sure you add at least one example ping which the data can be validated against. Additionally,
a [Parquet output](https://github.com/mozilla-services/mozilla-pipeline-schemas/blob/master/schemas/telemetry/core/core.9.parquetmr.txt)
schema should be added. This would add a new dataset, available in [Re:dash](https://sql.telemetry.mozilla.org).


Parquet output also has a `metadata` section. These are fields added to the ping at ingestion time;
they might come from the URL submitted to the edge server, or the IP Address used to make the request.
For now, take a look at [the ingestion code](https://github.com/mozilla-services/lua_sandbox_extensions/blob/master/moz_telemetry/io_modules/decoders/moz_ingest/telemetry.lua)
to see which fields are added. Note: We deeply apologize for making you look there. Feel free to reach
out to us in the #datapipeline IRC channel with questions.

### Testing The Schema

Note that this only works if data is _already_ being sent, and you want to test the schema you're
writing on the data that is currently being ingested.

Test your Parquet output in [Hindsight](https://pipeline-cep.prod.mozaws.net/) by using
an output plugin. See [Core ping output plugin](https://bugzilla.mozilla.org/attachment.cgi?id=8829626)
for an example, where the parquet schema is specified as `parquet_schema`. If no errors
arise, that means it should be correct. The "Deploy" button should not be used to actually
deploy, that will be done by operations in the next step.

Deploy the Plugin
-----------------
File [a bug to deploy the new schema.](https://bugzilla.mozilla.org/show_bug.cgi?id=1333203)

Real-time analysis will be key to ensuring your data is being processed and parsed correctly.
It should follow the format specified in
[Moztelemetry doctype monitor](https://mozilla-services.github.io/lua_sandbox_extensions/moz_telemetry/sandboxes/heka/analysis/moz_telemetry_doctype_monitor.html).
This allows you to check validation errors, size changes, duplicates, and more. Once you have
the numbers set, file a
[bug to let ops deploy it](https://bugzilla.mozilla.org/show_bug.cgi?id=1356380)

(Telemetry-Specific) Register Doctype
-------------------------------------
Data Platform Operations takes care of this. It will then be available to query more easily using
the Dataset API. To do so, make a bug like
[Bug 1292493](https://bugzilla.mozilla.org/show_bug.cgi?id=1292493).

(Non-Telemetry) Add ping name to sources.json
-------------------------------------------
This will make it available with the [Dataset API](http://python-moztelemetry.readthedocs.io/en/stable/api.html#dataset) (used with pyspark on ATMO machines).
There also needs to be a schema for the layout of the heka files in
net-mozaws-prod-us-west-2-pipeline-metadata/<ping-name>/schema.json, where <ping-name> is located in source.json. If you want to do this, talk to
:whd or :mreid.

Start Sending Data
------------------
If you're using the Telemetry APIs, use those built-in. These can be with the
[Gecko Telemetry APIs](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/collection/custom-pings.html),
the [Android Telemetry APIs](https://github.com/mozilla-mobile/telemetry-android), or the
[iOS Telemetry APIs](https://github.com/mozilla-mobile/telemetry-ios). Otherwise, see
[here for the endpoint and expected format](https://wiki.mozilla.org/CloudServices/DataPipeline/HTTPEdgeServerSpecification).

Work is happening to make a 
[generic endpoint](https://bugzilla.mozilla.org/show_bug.cgi?id=1363160).
These pings can be easily registered and sent to our servers and will
be automatically available in Re:dash. Please check back later for those docs.

Write ETL Jobs
--------------
We have some basic generalized ETL jobs you can use to transform your data on a batch basis - for example,
a [Longitudinal](https://github.com/mozilla/telemetry-batch-view/blob/master/src/main/scala/com/mozilla/telemetry/views/GenericLongitudinal.scala)
or [client-count](https://github.com/mozilla/telemetry-batch-view/blob/master/src/main/scala/com/mozilla/telemetry/views/GenericCountView.scala)
like dataset. Otherwise, you'll have to write your own.

You can schedule it on [Airflow](http://workflow.telemetry.mozilla.org/), or you can
run it as a job in ATMO. If the output is parquet, you can add it to the Hive metastore to have it
available in re:dash. Check the docs on [creating your own datasets](cookbooks/create_a_dataset.md).

Build Dashboards Using ATMO or STMO
-----------------------------------
Last steps! What are you using this data for anyways?
