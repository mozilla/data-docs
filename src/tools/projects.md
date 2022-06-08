# Projects

Below are a number of trailheads that lead into the projects and code that comprise the Firefox Data Platform.

## Telemetry APIs

| Name and repo                    | Description                                                                                               |
| -------------------------------- | --------------------------------------------------------------------------------------------------------- |
| [`mozanalysis`][ma]              | A library for Mozilla experiments analysis                                                                |
| [`glean`][glean]                 | A client-side mobile Telemetry SDK for collecting metrics and sending them to Mozilla's Telemetry service |

[ma]: https://github.com/mozilla/mozanalysis
[glean]: https://github.com/mozilla-mobile/android-components/main/master/components/service/glean

## ETL code and Datasets

| Name and repo                   | Description                                            |
| ------------------------------- | ------------------------------------------------------ |
| [`bigquery-etl`][bqe]           | SQL ETL code for building derived datasets in BigQuery |
| [`python_mozetl`][pyetl]        | Python ETL code for derived datasets                   |
| [`telemetry-airflow`][airflow]  | Airflow configuration and DAGs for scheduled jobs      |
| [`python_mozaggregator`][pyagg] | Aggregation job for `telemetry.mozilla.org` aggregates |

See also [`data-docs`][docs] for documentation on datasets.

[bqe]: https://github.com/mozilla/bigquery-etl
[pyetl]: https://github.com/mozilla/python_mozetl
[airflow]: https://github.com/mozilla/telemetry-airflow
[pyagg]: https://github.com/mozilla/python_mozaggregator

## Infrastructure

| Name and repo                         | Description                                                                                         |
| ------------------------------------- | --------------------------------------------------------------------------------------------------- |
| [`mozilla-pipeline-schemas`][schemas] | JSON and Parquet Schemas for Mozilla Telemetry and other structured data                            |
| [`gcp-ingestion`][gcp-ingestion]      | Documentation and implementation of the Mozilla telemetry ingestion system on Google Cloud Platform |
| [`jsonschema-transpiler`][transpiler] | Convert JSON Schema into BigQuery table definitions                                                 |
| [`mozilla-schema-generator`][msg]     | Incorporate probe metadata to generate BigQuery table schemas                                       |
| [`edge-validator`][edge-validator]    | A service endpoint for validating incoming data                                                     |

[schemas]: https://github.com/mozilla-services/mozilla-pipeline-schemas
[gcp-ingestion]: https://github.com/mozilla/gcp-ingestion
[transpiler]: https://github.com/mozilla/jsonschema-transpiler
[msg]: https://github.com/mozilla/mozilla-schema-generator
[edge-validator]: https://github.com/mozilla-services/edge-validator

## Data applications

| Name and repo                      | Description                                                     |
| ---------------------------------- | --------------------------------------------------------------- |
| [`telemetry.mozilla.org`][tmo_gh]  | Main entry point for legacy [aggregate Telemetry data][tmo]     |
| [Growth & Usage dashboard][gud_gh] | Legacy dashboard about [product growth and usage][gud]          |
| [Glean Aggregate Metrics][glam]    | Aggregate info about probes and measures                        |
| [Glean Debug View][gdv]            | Tag and view Glean submissions with low latency                 |
| [Mission Control][mc]              | Low latency dashboard for stability and health metrics          |
| [Redash][redash]                   | Mozilla's fork of the [data query / visualization system][stmo] |
| [`redash-stmo`][redashstmo]        | Mozilla's extensions to Redash                                  |
| [TAAR][taar]                       | Telemetry-aware addon recommender                               |
| [Ensemble][ensemble]               | A minimalist platform for publishing data                       |
| [Hardware Report][hwreport_gh]     | Firefox Hardware Report, [available here][hwreport]             |
| [St. Mocli][stmocli]               | A command-line interface to [STMO][stmo]                        |
| [probe-scraper]                    | Scrape and publish Telemetry probe data from Firefox            |
| [experimenter]                     | A web application for managing experiments                      |
| [St. Moab][stmoab]                 | Automatically generate Redash dashboard for A/B experiments     |

[tmo_gh]: https://github.com/mozilla/telemetry-dashboard
[gud]: https://gud.telemetry.mozilla.org
[gud_gh]: https://github.com/mozilla/GUD
[glam]: https://github.com/mozilla/glam
[gdv]: https://debug-ping-preview.firebaseapp.com
[mc]: https://github.com/mozilla/missioncontrol
[redash]: https://github.com/mozilla/redash
[redashstmo]: https://github.com/mozilla/redash-stmo
[taar]: https://github.com/mozilla/taar
[ensemble]: https://github.com/mozilla/ensemble
[tmo]: https://telemetry.mozilla.org
[stmo]: https://sql.telemetry.mozilla.org
[hwreport_gh]: https://github.com/mozilla/firefox-hardware-report
[hwreport]: https://data.firefox.com/dashboard/hardware
[stmocli]: https://github.com/mozilla/stmocli
[probe-scraper]: https://github.com/mozilla/probe-scraper
[experimenter]: https://github.com/mozilla/experimenter
[stmoab]: https://github.com/mozilla/stmoab

## Legacy projects

Projects in this section are less active, but may not be officially
deprecated. Please check with the `fx-data-dev` mailing list before
starting a new project using anything in this section.

| Name and repo                       | Description                                                 |
| ----------------------------------- | ----------------------------------------------------------- |
| [`telemetry-next-node`][tnn]        | A `node.js` package for accessing Telemetry Aggregates data |
| [`emr-bootstrap-spark`][eb_spark]   | AWS bootstrap scripts for Spark.                            |
| [`emr-bootstrap-presto`][eb_presto] | AWS bootstrap scripts for Presto.                           |
| [Iodide] ([code][iodide_gh])        | Literate scientific computing and communication for the web |

[eb_spark]: https://github.com/mozilla/emr-bootstrap-spark
[eb_presto]: https://github.com/mozilla/emr-bootstrap-presto
[tnn]: https://github.com/mozilla/telemetry-next-node
[iodide]: http://iodide.telemetry.mozilla.org/
[iodide_gh]: https://github.com/iodide-project/iodide

## Reference materials

### Public

| Name and repo              | Description                                                                     |
| -------------------------- | ------------------------------------------------------------------------------- |
| [`data-docs`][docs_gh]     | All the info you need to [answer questions about Firefox users with data][docs] |
| Firefox source docs        | [Mozilla Source Tree Docs - Telemetry section][fxsrcdocs]                       |
| [`reports.t.m.o`][rtmo_gh] | Knowledge repository for [public reports][rtmo]                                 |

[docs_gh]: https://github.com/mozilla/data-docs
[docs]: https://docs.telemetry.mozilla.org
[fxsrcdocs]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/
[rtmo_gh]: https://github.com/mozilla/mozilla-reports
[rtmo]: https://mozilla.report

### Non-public

| Name and repo | Description |
| ------------- | ----------- |

