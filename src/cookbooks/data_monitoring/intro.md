# Introduction to Bigeye (Data Observability Platform)

Mozilla uses Bigeye as its data observability platform to ensure high data quality and reliability across its pipelines. Bigeye offers powerful features like automated anomaly detection, detailed data lineage tracking, and customizable monitoring. These capabilities allow teams to swiftly identify, diagnose, and resolve data issues, enhancing overall data integrity and operational efficiency.

## Accessing Bigeye

You can access Mozilla's instance of Bigeye at [app.bigeye.com](https://app.bigeye.com/).
If you do not have the necessary access or permissions, please [submit a Jira ticket](https://mozilla-hub.atlassian.net/browse/DENG-4728).

## Getting Started

Watch the [Bigeye tutorial](https://www.youtube.com/watch?v=8DWyZuU-w1c&t=9s) to get an overview of the platform.
Please refer to additional helpful videos available on the Bigeye channel.

## Code-Based Monitoring Configuration

In addition to configuring monitors through the Bigeye UI, monitoring can be defined as code in [mozilla/bigquery-etl](https://github.com/mozilla/bigquery-etl). Tables can include a `bigconfig.yml` alongside their `metadata.yaml`, with monitoring enabled via a `monitoring.enabled` field. The `bqetl monitoring` CLI (`deploy`, `update`, `validate`, `deploy_custom_rules`) pushes these configs to Bigeye.

**Caution:** Avoid running `bigconfig apply` or `bqetl monitoring deploy` ad hoc on your local machine outside of the normal deployment automation. Doing so with an incomplete set of config files can delete metrics that aren't included in the plan.

## Stay Updated on What's Happening

[Jira Epic Link](https://mozilla-hub.atlassian.net/browse/DENG-4563)

## Have an issue or looking for a new feature in Bigeye

If you're experiencing any issues while using the issues tracker for [Bigeye](https://docs.google.com/spreadsheets/d/1L7JrbgTaVsKKFIK3ilKKttUfuzHh91xSeBFC0VZTp68)
