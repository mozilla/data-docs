# Firefox Accounts Data

## Table of Contents

<!-- toc -->

## Introduction

This article provides an overview of Firefox Accounts metrics: what is measured and how. See the other articles in this chapter for more details about the specific measurements that are available for analysis.

## What is Firefox Accounts?

[Firefox Accounts](https://www.mozilla.org/en-US/firefox/accounts/) is Mozilla's authentication solution for account-based end-user services and features. At the time of writing, sync is by far the most popular account-relying service. Below is a partial list of current FxA-relying services (by the time you are reading this others will likely have been added; we will endeavor to update the list periodically):

- [Sync](https://support.mozilla.org/en-US/kb/how-do-i-set-sync-my-computer)
  - Requires FxA.
- [Firefox Send](https://send.firefox.com/)
  - FxA Optional; Required to send large files.
- [Lockwise](https://lockwise.firefox.com/)
  - Requires FxA and sync.
- [AMO](https://addons.mozilla.org/en-US/firefox/)
  - For developer accounts; not required by end-users to use or download addons.
- [Pocket](https://getpocket.com/login/?ep=1)
  - FxA is an optional authentication method among others.
- [Monitor](https://monitor.firefox.com)
  - Required to receive email alerts. Not required for email scans.
- [Mozilla IAM](https://wiki.mozilla.org/IAM/Frequently_asked_questions)
  - Optional authentication method among others.

A single account can be used to authenticate with all of the services listed above (though see the note below about Chinese users).

Note that in addition to being the most commonly used relier of FxA, sync is also unique in its integration with FxA - unlike the other reliers in the list above, sync is currently **not** an FxA oauth client. When someone signs into an oauth client using Firefox, nothing in the browser changes - more specifically, client-side telemetry probes such as [`FXA_CONFIGURED`](https://telemetry.mozilla.org/probe-dictionary/?detailView=histogram%2FFXA_CONFIGURED) do not change state. Thus at the present time the only way to measure usage of FxA oauth reliers is to use the FxA server-side measures described below.

One more thing: China runs its own stack for sync, but Chinese sign-ups for oauth reliers still go through the "one and only" oauth server. This means that Chinese users who want to use both sync and an oauth service (e.g. Monitor) will have to register for two accounts. It also means that only metrics for Chinese oauth users will show up in the datasets described below; any sync-related measures will not. At present, you must contact those responsible for maintaining the FxA stack in China for metrics on Chinese sync users.

## Metrics Background

Unlike most telemetry described in these docs, FxA metrics are logged server-side. There are many [FxA "servers"](https://github.com/mozilla/fxa/tree/main/packages) that handle different aspects of account authentication and management. The metrics of most interest to data analysts are logged by the FxA auth server, content server and oauth server. Each server writes their metrics into their log stream, and some post-processing scripts combine the metrics events from all three servers into datasets that are available in Databricks, BigQuery, STMO and Amplitude.

In general, metrics logged by the [FxA auth server](https://github.com/mozilla/fxa/tree/main/packages/fxa-auth-server) reflect authentication events such as account creation, logins to existing accounts, etc.
Metrics logged by the [FxA content server](https://github.com/mozilla/fxa/tree/main/packages/fxa-content-server) reflect user interaction and progression through the FxA web UI - form views, form engagement, form submission, etc.
The [FxA oauth server](https://github.com/mozilla/fxa/pull/3176) logs metrics events when oauth clients (Monitor, Lockwise, etc) create and check authentication tokens.

## Metrics Taxonomies

There are two overlapping taxonomies or sets of FxA event metrics.

[**Flow Metrics**](https://github.com/mozilla/fxa-auth-server/blob/master/docs/metrics-events.md): these are an older set of metrics events that can be queried through redshift and via the `FxA Activity Metrics` data source in STMO. The [STMO import jobs](https://github.com/mozilla/fxa-activity-metrics/) are run once a day. See [this documentation](https://github.com/mozilla/fxa-auth-server/blob/master/docs/metrics-events.md) for detailed description of the types of flow events that are logged and the tables that contain them (note this documentation does not contain an exhaustive list of all flow metrics but is generally still accurate about the ones that are described). Note there are 50% and 10% sampled versions of the major tables, which contain more historical data than their complete counterparts. Complete tables go back 3 months, 50% tables go back 6 months, and 10% tables go back 24 months. Sampling is done at the level of the FxA user id `uid` (i.e. integer(`uid`) % 100).

[**Amplitude Events**](https://analytics.amplitude.com/mozilla-corp/manage/project/178231/advanced/events): FxA started to send metrics events to amplitude circa October 2017. The [code responsible for batching events to amplitude](https://github.com/mozilla/fxa-amplitude-send) over HTTP is run in more-or-less real-time. Amplitude events can be queried through the [amplitude UI](https://analytics.amplitude.com/mozilla-corp/space/vj9qof9) as well as various views in `moz-fx-data-shared-prod.firefox_accounts` dataset in BigQuery that maintain copies of the events that are sent to Amplitude. [`moz-fx-data-shared-prod.firefox_accounts.fxa_content_auth_events`](https://github.com/mozilla/bigquery-etl/blob/master/sql/moz-fx-data-shared-prod/firefox_accounts/fxa_content_auth_events/view.sql) is probably the easiest BigQuery view to use, though it does not contain email bounce events and (at the time of writing) only contains data starting at 2019-03-01.

Note that the BigQuery [ETL jobs](https://github.com/mozilla/bigquery-etl/tree/master/sql) run daily while real-time data is accessible through the amplitude UI.

FxA's amplitude metrics were originally just re-configured and re-named versions of the flow metrics. However things have since diverged a bit and there are now metrics events that only have an amplitude version but no corresponding flow event, and vice-versa. If you are wondering whether a certain event is logged its likely you will have to check both data sources.

**Generally speaking, one should first try to use the amplitude metrics rather than the flow events** for these reasons:

1. For quick answers to simple questions the amplitude UI is often more efficient than writing SQL.
   - The caveat here is that is can sometimes be _too_ easy to build a chart in amplitude - it doesn't exactly encourage the careful consideration that having to write a query out by hand implicitly encourages.
2. By-country data is currently not available in redshift.
3. There have been outages in the redshift data that have not affected the amplitude data.
4. Querying redshift is (generally) slower.

It is also possible to query the FxA server logs directly through BigQuery (ask an FxA team member for access), though virtually all analytics-related questions are more easily answered using the data sources described above.
