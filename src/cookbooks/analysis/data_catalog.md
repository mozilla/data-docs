# The Data Catalog

Reference material for data assets (tables, dashboards, pings, etc.) can primarily be found in the Data Catalog: https://mozilla.acryl.io.
It provides an automatically updated "map" of data assets, including lineage and descriptions, without the need for manual curation.

## What do I use it for?

The primary use case for the catalog is finding out (at a glance) which data assets exist and how they relate to one another. A few examples:

- Finding the source ping or table from a Looker dashboard.
- Finding out whether a source ping or table has any downstream dependencies.
- Getting a high-level overview of how tables are transformed before data shows up in a dashboard.
- Tracing a column through various BigQuery tables.
- Finding the source query or DAG that powers a particular BigQuery table.

## How do I use it?

Navigate to https://mozilla.acryl.io and log in via SSO. Once logged in, you should be able to explore assets via the
search bar or by clicking on a platform (e.g. BigQuery or Glean).

## When was this implemented?

We tested a number of tools in 2022 and finally settled on Acryl. Integration work proceeded from there and continues as
we add more tools and assets to our data platform.

## Does this replace tools like the Glean Dictionary or the Looker Data Dictionary?

No. While the features between the Data Catalog and tools such as the Glean Dictionary and Looker Data Dictionary overlap,
the Data Catalog is meant to be less focused on any single tool and more on assets from all the tools in our data platform,
providing lineage and reference material that links them together.

## What software does it use?

The catalog is a managed version of open source DataHub - https://datahubproject.io, a metadata platform built and
maintained by the company Acryl - https://www.acryldata.io.

## How is the metadata populated?

Metadata is pulled from each platform that is cataloged. Depending on the source, metadata ingestion is either managed
in the Acryl UI or via our custom ingestion code:

- Glean - Pings are ingested from the Glean Dictionary API nightly in CircleCI. The ingestion code is located here https://github.com/mozilla/mozilla-datahub-ingestion
- Legacy Telemetry - Pings are ingested from the Mozilla Pipeline Schemas repository (https://github.com/mozilla-services/mozilla-pipeline-schemas/) nightly in CircleCI. The ingestion code is located here https://github.com/mozilla/mozilla-datahub-ingestion
- BigQuery - Views, Tables, Datasets, and Projects are ingested from the BigQuery audit log and query jobs. This is scheduled nightly in the Acryl UI. The documentation can be found here https://datahubproject.io/docs/generated/ingestion/sources/bigquery
- Looker - Views, Explores, and Dashboards are ingested from both our LookML source repositories (e.g. https://github.com/mozilla/looker-spoke-default/) and the Looker API. This is scheduled nightly in the Acryl UI. The documentation can be found here https://datahubproject.io/docs/generated/ingestion/sources/looker/
- Metric-Hub - Metrics are ingested from the metric-hub repository (https://github.com/mozilla/metric-hub/) and loaded into the Business Glossary. This is scheduled nightly in CircleCI here https://github.com/mozilla/mozilla-datahub-ingestion and the documentation can be found here https://datahubproject.io/docs/generated/ingestion/sources/business-glossary/
