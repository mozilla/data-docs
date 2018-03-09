# Projects

Below are a number of trailheads that lead into the projects and code that comprise the Firefox Data Platform.

## Telemetry APIs

| Name and repo                      | Description                       |
|------------------------------------|-----------------------------------|
| [`python_moztelemetry`][pymt]      | Python APIs for Mozilla Telemetry
| [`moztelemetry`][mt]               | Scala APIs for Mozilla Telemetry
| [`spark-hyperloglog`][spark_hll]   | Algebird's HyperLogLog support for Apache Spark

[pymt]: https://github.com/mozilla/python_moztelemetry
[mt]: https://github.com/mozilla/moztelemetry
[spark_hll]: https://github.com/mozilla/spark-hyperloglog

## ETL code and Datasets

| Name and repo                   | Description                           |
|---------------------------------|---------------------------------------|
| [`telemetry-batch-view`][tbv]   | Scala ETL code for derived datasets
| [`python_mozetl`][pyetl]        | Python ETL code for derived datasets
| [`telemetry-airflow`][airflow]  | Airflow configuration and DAGs for scheduled jobs
| [`python_mozaggregator`][pyagg] | Aggregation job for `telemetry.mozilla.org` aggregates
| [`telemetry-streaming`][stream] | Spark Streaming ETL jobs for Mozilla Telemetry

See also [`firefox-data-docs`][docs] for documentation on datasets.

[tbv]: https://github.com/mozilla/telemetry-batch-view
[pyetl]: https://github.com/mozilla/python_mozetl
[airflow]: https://github.com/mozilla/telemetry-airflow
[pyagg]: https://github.com/mozilla/python_mozaggregator
[stream]: https://github.com/mozilla/telemetry-streaming


## Infrastructure

| Name and repo                         | Description                             |
|---------------------------------------|-----------------------------------------|
| [`mozilla-pipeline-schemas`][schemas] | JSON Schemas for Mozilla Telemetry data
| [`hindsight`][hs]                     | Real-time data processing
| [`lua_sandbox`][lsb]                  | Generic sandbox for safe data analysis
| [`lua_sandbox_extensions`][lsbx]      | Modules and packages that extend the Lua sandbox
| [`nginx_moz_ingest`][nmi]             | Nginx module for Telemetry data ingestion
| [`Generic Ingestion`][gi]             | Proposal for streamlined data ingestion of structured data
| [`puppet-config`][puppet]             | Cloud services puppet config for deploying infrastructure
| [`parquet2hive`][p2h]                 | Hive import statement generator for Parquet datasets

[schemas]: https://github.com/mozilla-services/mozilla-pipeline-schemas
[hs]: https://github.com/mozilla-services/hindsight
[lsb]: https://github.com/mozilla-services/lua_sandbox
[lsbx]: https://github.com/mozilla-services/lua_sandbox_extensions
[nmi]: https://github.com/mozilla-services/nginx_moz_ingest
[gi]: https://docs.google.com/document/d/1PqiF1rF2fCk_kQuGSwGwildDf4Crg9MJTY44E6N5DSk/edit?ts=5910c4cf#heading=h.74qlucdvwdg0
[puppet]: https://github.com/mozilla-services/puppet-config/tree/master/pipeline
[p2h]: https://github.com/mozilla/parquet2hive

### EMR Bootstrap scripts

| Name and repo                       | Description                             |
|-------------------------------------|-----------------------------------------|
| [`emr-bootstrap-spark`][eb_spark]   | AWS bootstrap scripts for Spark.
| [`emr-bootstrap-presto`][eb_presto] | AWS bootstrap scripts for Presto.

[eb_spark]: https://github.com/mozilla/emr-bootstrap-spark
[eb_presto]: https://github.com/mozilla/emr-bootstrap-presto

## Data applications

| Name and repo                     | Description                             |
|-----------------------------------|-----------------------------------------|
| [`telemetry.mozilla.org`][tmo_gh] | Main entry point for viewing [aggregate Telemetry data][tmo]
| [Cerberus][cer] & [Medusa][med]   | Automatic alert system for telemetry aggregates
| [`analysis.t.m.o`][atmo_gh]       | [Self serve data analysis platform][atmo]
| [Mission Control][mc]             | Low latency dashboard for stability and health metrics
| [Experiments Viewer][ev]          | Visualization for [Shield][shield] experiment results
| [Re:dash][redash]                 | Mozilla's fork of the [data query / visualization system][stmo]
| [TAAR][taar]                      | Telemetry-aware addon recommender
| [Ensemble][ensemble]              | A minimalist platform for publishing data
| [Hardware Report][hwreport_gh]    | Firefox Hardware Report, [available here][hwreport]
| [`python-zeppelin`][pyzep]        | Convert Zeppelin notebooks to Markdown

[tmo_gh]: https://github.com/mozilla/telemetry-dashboard
[cer]: https://github.com/mozilla/cerberus
[med]: https://github.com/mozilla/medusa
[atmo_gh]: https://github.com/mozilla/telemetry-analysis-service
[mc]: https://github.com/mozilla/missioncontrol
[ev]: https://github.com/mozilla/experiments-viewer
[redash]: https://github.com/mozilla/redash
[taar]: https://github.com/mozilla/taar
[ensemble]: https://github.com/mozilla/ensemble
[shield]: https://wiki.mozilla.org/index.php?title=Firefox/Shield
[tmo]: https://telemetry.mozilla.org
[atmo]: https://analysis.telemetry.mozilla.org
[stmo]: https://sql.telemetry.mozilla.org
[hwreport_gh]: https://github.com/mozilla/firefox-hardware-report
[hwreport]: https://hardware.metrics.mozilla.com/
[pyzep]: https://github.com/mozilla/python-zeppelin

## Reference materials

### Public

| Name and repo                  | Description                             |
|--------------------------------|-----------------------------------------|
| [`firefox-data-docs`][docs_gh] | All the info you need to [answer questions about Firefox users with data][docs]
| Firefox source docs            | [Mozilla Source Tree Docs - Telemetry section][fxsrcdocs]
| [`reports.t.m.o`][rtmo_gh]     | Knowledge repository for [public reports][rtmo]

[docs_gh]: https://github.com/mozilla/firefox-data-docs
[docs]: https://docs.telemetry.mozilla.org
[fxsrcdocs]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/
[rtmo_gh]: https://github.com/mozilla/mozilla-reports
[rtmo]: https://reports.telemetry.mozilla.org

### Non-public

| Name and repo                  | Description                             |
|--------------------------------|-----------------------------------------|
| [`Fx-Data-Planning`][planning] | Quarterly goals and internal documentation

[planning]: https://github.com/mozilla/Fx-Data-Planning