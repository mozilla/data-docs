Got some new data you want to send to us? How in the world do you send a new ping? Follow this guide to find out.

Write Your Questions
--------------------
Do not try and implement new pings unless you know specifically what questions you're trying to answer. General questions about "How do users use our product?" won't cut it - these need to be specific, concrete asks that can be translated to data points. This will also make it easier down the line as you start data review.

Create a Schema
---------------
Use JSON Schema to start with. See the examples schemas in the [Mozilla Pipeline Schemas repo](https://github.com/mozilla-services/mozilla-pipeline-schemas/).

Start a Data Review
-------------------
Data review for new pings is a more complicated than when adding new probes. See [Data Review for Focus-Event Ping](https://bugzilla.mozilla.org/show_bug.cgi?id=1347266) as an example. Consider where the data falls in the [Data Collection Categories](https://wiki.mozilla.org/Firefox/Data_Collection).

Submit Schema to mozilla-services/mozilla-pipeline-schemas
-----------------------------------------
Add parquet if you want. Make sure you add at least one example ping which the data can be validated against. Test your Parquet output in [Hindsight](https://pipeline-cep.prod.mozaws.net/) by testing it as an output plugin. See [Core ping output plugin](https://bugzilla.mozilla.org/attachment.cgi?id=8829626) for an example, where the parquet schema is specified as `parquet_schema`.

Setup a Monitor For Your Data
-----------------------------
Real-time analysis will be key to ensuring your data is coming being processed and parsed correctly. It should follow the format specified in [Moztelemetry doctype monitor](https://mozilla-services.github.io/lua_sandbox_extensions/moz_telemetry/sandboxes/heka/analysis/moz_telemetry_doctype_monitor.html). This allows you to check validation errors, size changes, duplicates, and more. Once you have the numbers set, file a [bug to let ops deploy it](https://bugzilla.mozilla.org/show_bug.cgi?id=1356380)

Start Sending Data
------------------
If you're using the Telemetry APIs, this should be easy (give an example). Otherwise, see [here for the endpoint and expected format](https://wiki.mozilla.org/CloudServices/DataPipeline/HTTPEdgeServerSpecification). Work coming to make this a [generic endpoint](https://bugzilla.mozilla.org/show_bug.cgi?id=1363160)

(Telemetry-Specific) Register Doctype
-------------------------------------
Data Platform Operations takes care of this. It will then be available to query more easily using the Dataset API. To do so, make a bug like [Bug 1292493](https://bugzilla.mozilla.org/show_bug.cgi?id=1292493)

(Non-Telemetry) Need to add to sources.json
-------------------------------------------
This will make it available with the Dataset API (used with pyspark on ATMO machines). There also needs to be a schema for the layout of the heka files in net-mozaws-prod-us-west-2-pipeline-metadata/<ping-name>/schema.json, where <ping-name> is located in source.json. If you want to do this, talk to whd or mreid.

Add to Hive Metastore to Query in STMO
--------------------------------------
To query this data in STMO (aka re:dash) it needs to be known by the database. File a bug like [Bug 1342194](https://bugzilla.mozilla.org/show_bug.cgi?id=1342194) to do this.

Write ETL Jobs
--------------
We have some basic generalized ETL jobs you can use to transform your data on a batch basis - for example, a Longitudinal-like or client-count like dataset. Otherwise, you'll have to write your own. You can schedule it on [Airflow](http://workflow.telemetry.mozilla.org/) if you'd like, or you can run it as a job in ATMO. If this output parquet, you can again add it the Hive metastore to have it available in re:dash.

Build Dashboards Using ATMO or STMO
-----------------------------------
Last steps! What are you using this data for anyways?
