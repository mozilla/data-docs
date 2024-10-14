# Mozilla Accounts Data

> ⚠️ Formerly Firefox Accounts, this service was renamed publicly in 2023, but is still often referred to by its previous abbreviation `FxA` internally, including in this documentation.

## Table of Contents

<!-- toc -->

## Introduction

This article provides an overview of Mozilla accounts metrics: what is measured and how. See the other articles in this chapter for more details about the specific measurements that are available for analysis.

The [Mozilla accounts documentation](https://mozilla.github.io/ecosystem-platform/relying-parties/reference/metrics-for-relying-parties) maintains additional detail, as well as the source code, for the metrics described here.

## What is Mozilla Accounts?

[Mozilla accounts](https://www.mozilla.org/en-US/firefox/accounts/) is Mozilla's authentication solution for account-based end-user services and features. At the time of writing, sync is by far the most popular account-relying service. Below is a partial list of current FxA-relying services:

- [Sync](https://support.mozilla.org/en-US/kb/how-do-i-set-sync-my-computer)
  - Requires FxA.
- [AMO](https://addons.mozilla.org/en-US/firefox/)
  - For developer accounts; not required by end-users to use or download addons.
- [Pocket](https://getpocket.com/login/?ep=1)
  - FxA is an optional authentication method among others.
- [Monitor](https://monitor.firefox.com)
  - Required to receive email alerts. Not required for email scans.
- [Relay](https://relay.firefox.com/)
  - Required to use the service
- [Mozilla IAM](https://wiki.mozilla.org/IAM/Frequently_asked_questions)
  - Optional authentication method among others.

A single account can be used to authenticate with all of the services listed above (though see the note below about Chinese users).

Note that in addition to being the most commonly used relier of FxA, sync is also unique in its integration with FxA - unlike the other reliers in the list above, sync is currently **not** an FxA oauth client. When someone signs into an oauth client using Firefox, nothing in the browser changes - more specifically, client-side telemetry probes such as [`FXA_CONFIGURED`](https://probes.telemetry.mozilla.org/?view=detail&probeId=histogram%2FFXA_CONFIGURED) do not change state. Thus at the present time the only way to measure usage of FxA oauth reliers is to use the FxA server-side measures described below.

> ⚠️ China runs its own stack for sync, but Chinese sign-ups for oauth reliers still go through the "one and only" oauth server. This means that Chinese users who want to use both sync and an oauth service (e.g. Monitor) will have to register for two accounts. It also means that only metrics for Chinese oauth users will show up in the datasets described below; any sync-related measures will not. At present, you must contact those responsible for maintaining the FxA stack in China for metrics on Chinese sync users.

## Metrics Background

FxA metrics are logged both server-side and client-side. There are many [FxA "servers"](https://github.com/mozilla/fxa/tree/main/packages) that handle different aspects of account authentication and management. The metrics of most interest to data analysts are logged by the FxA auth server, content server and oauth server. Each server writes their metrics into their log stream, and some post-processing scripts combine the metrics events from all three servers into datasets that are available in BigQuery. In 2023 a new logging implementation was integrated leveraging the [Glean](../concepts/glean/glean.md) libraries and pipelines which means both server- and client-side will use the Glean system. All new metrics are being implemented in Glean and the legacy metrics will likely be removed in 2024.

In general, metrics logged by the [FxA auth server](https://github.com/mozilla/fxa/tree/main/packages/fxa-auth-server) reflect authentication events such as account creation, logins to existing accounts, etc.
Metrics logged by the [FxA content server](https://github.com/mozilla/fxa/tree/main/packages/fxa-content-server) reflect user interaction and progression through the FxA web UI - form views, form engagement, form submission, etc.
The [FxA oauth server](https://github.com/mozilla/fxa/pull/3176) logs metrics events when oauth clients (Monitor, Lockwise, etc) create and check authentication tokens.

## Metrics Taxonomies

### Glean

In 2023, we integrated Glean with Mozilla Accounts and Event Metrics are now available for both the server-side and client-side.

To explore available metrics, visit [Glean Dictionary](https://dictionary.telemetry.mozilla.org/) and browse the [`accounts_backend`](https://dictionary.telemetry.mozilla.org/apps/accounts_backend) and [`accounts_frontend`](https://dictionary.telemetry.mozilla.org/apps/accounts_frontend) applications.

All events are sent in `events` ping. The most effective way to query them is to use the `events_stream` tables in BigQuery: [`accounts_frontend.events_stream`](<https://mozilla.acryl.io/dataset/urn:li:dataset:(urn:li:dataPlatform:bigquery,moz-fx-data-shared-prod.accounts_frontend.events_stream,PROD)>) and [`accounts_backend.events_stream`](<https://mozilla.acryl.io/dataset/urn:li:dataset:(urn:li:dataPlatform:bigquery,mozdata.accounts_backend.events_stream,PROD)>). They are accessible in Looker via `Events Stream Table` explores. Because they have extra properties packaged as a JSON structure, when these are needed it is best to use the `Event Counts` explores.

The Accounts frontend is instrumented with [automatic Glean website events](https://mozilla.github.io/glean.js/automatic_instrumentation/page_load_events/). Data collected this way can be explored on the [Website Sessions dashboard](https://mozilla.cloud.looker.com/dashboards/websites::website_sessions?App+ID=accounts%5E_frontend&Submission+Date=7+day&Country+Name=&External+Referrer=&App+Channel=&UA+-+Browser=&Traffic+Source=) in Looker. To dig deeper you can write a query to analyze properties of these events: [`element_click`](https://sql.telemetry.mozilla.org/queries/102469/source) and [`page_load`](https://sql.telemetry.mozilla.org/queries/102470/source).

#### `accounts_frontend` or `accounts_backend`?

As mentioned above, backend services and JavaScript frontend are instrumented as separate Glean applications. Backend events have generally higher delivery guarantees as we control the environment in which they are sent - we do not expect any data loss there. Frontend events are sent from the browser and are subject to all the usual reliability issues that entails.

If analysis requires a metric that is available in both frontend and backend, backend metrics are generally preferred. For complex queries involving multiple event metrics, for example funnels, it is preferable to use a single application to avoid issues with event order of arrival and partial delivery. If you need to mix data from frontend and backend in your query, you can use `session.flow_id` metric to correlate sessions and `submission_timestamp` for ordering.

### Legacy

There are two additional legacy event types described below:

[**Flow Metrics**](https://github.com/mozilla/fxa-auth-server/blob/master/docs/metrics-events.md): these are an older set of metrics events that can be queried through the `firefox_accounts` dataset in the `mozdata` project in BigQuery. See [this documentation](https://github.com/mozilla/fxa-auth-server/blob/master/docs/metrics-events.md) for detailed description of the types of flow events that are logged and the tables that contain them (note this documentation does not contain an exhaustive list of all flow metrics but is generally still accurate about the ones that are described). These will likely evolve significantly in 2024.

**Amplitude Events**: FxA started to send metrics events to Amplitude circa October 2017 and ended around June 2020. While we stopped using Amplitude, the term Amplitude Events lives on to reference this set of events. Amplitude events can be queried through the `moz-fx-data-shared-prod.firefox_accounts` dataset in BigQuery. [`moz-fx-data-shared-prod.firefox_accounts.fxa_content_auth_events`](https://github.com/mozilla/bigquery-etl/blob/main/sql/moz-fx-data-shared-prod/firefox_accounts/fxa_content_auth_events/view.sql) is probably the easiest BigQuery view to use, though it does not contain email bounce events. These are being completely replaced by the Glean Event Metrics and will be removed in 2024. FxA's Amplitude metrics were originally just re-configured and re-named versions of the flow metrics. However things have since diverged a bit and there are now metrics events that only have an Amplitude version but no corresponding flow event, and vice-versa. If you are wondering whether a certain event is logged its likely you will have to check both data sources.

Note that the BigQuery [ETL jobs](https://github.com/mozilla/bigquery-etl/tree/main/sql) run daily.

## Service databases

Transactional databases used by Mozilla Accounts services are replicated to BigQuery. You can find table schemas in [Ecosystem Platform documentation](https://github.com/mozilla/ecosystem-platform/blob/master/docs/reference/database-structure.md).

There are two datasets, containing data from the production and stage databases:

- `moz-fx-data-shared-prod.accounts_db_external`
- `moz-fx-data-shared-prod.accounts_db_nonprod_external`

These datasets are restricted to a specific workgroup. Some user-facing views are available in `mozdata.accounts_db`.
