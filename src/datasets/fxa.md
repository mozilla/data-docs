# Firefox Accounts Data

## Table of Contents
<!-- toc -->

## Introduction

This article provides an overview of Firefox Accounts metrics: what is measured and how. See the other articles in this chapter for more details about the specific measurements that are available for analysis.

## What is Firefox Accounts?

[Firefox Accounts](https://www.mozilla.org/en-US/firefox/accounts/) is Mozilla's authentication solution for account-based end-user services and features. At the time of writing, sync is by far the most popular account-relying service. Below is a partial list of current FxA-relying services (by the time you are reading this others will likely have been added; we will endeavor to update the list periodically):

* [Sync](https://support.mozilla.org/en-US/kb/how-do-i-set-sync-my-computer)
    * Requires FxA.
* [Firefox Send](https://send.firefox.com/)
    * FxA Optional; Required to send large files.
* [Lockwise](https://lockwise.firefox.com/)
    * Requires FxA and sync.
* [AMO](https://addons.mozilla.org/en-US/firefox/)
    * For developer accounts; not required by end-users to use or download addons.
* [Pocket](https://getpocket.com/login/?ep=1)
    * FxA is an optional authentication method among others.
* [Monitor](http://monitor.firefox.com/)
    * Required to receive email alerts. Not required for email scans.
* [Mozilla IAM](https://wiki.mozilla.org/IAM/Frequently_asked_questions)
    * Optional authentication method among others.

A single account can be used to authenticate with all of the services listed above (though see the note below about Chinese users).

Note that in addition to being the most commonly used relier of FxA, sync is also unique in its integration with FxA - unlike the other reliers in the list above, sync is currently **not** an FxA oauth client. When someone signs into an oauth client using Firefox, nothing in the browser changes - more specifically, client-side telemetry probes such as [`FXA_CONFIGURED`](https://telemetry.mozilla.org/probe-dictionary/?detailView=histogram%2FFXA_CONFIGURED) do not change state. Thus at the present time the only way to measure usage of FxA oauth reliers is to use the FxA server-side measures described below.

One more thing: China runs its own stack for sync, but Chinese sign-ups for oauth reliers still go through the "one and only" oauth server. This means that Chinese users who want to use both sync and an oauth service (e.g. Monitor) will have to register for two accounts. It also means that only metrics for Chinese oauth users will show up in the datasets described below; any sync-related measures will not. At present, you must contact those responsible for maintaining the FxA stack in China for metrics on Chinese sync users.

## Metrics Background

Unlike most telemetry described in these docs, FxA metrics are logged server-side. There are many [FxA "servers"](https://github.com/mozilla/fxa/tree/master/packages) that handle different aspects of account authentication and management. The metrics of most interest to data analysts are logged by the FxA auth server, content server and oauth server. Each server writes their metrics into their log stream, and some post-processing scripts combine the metrics events from all three servers into datasets that are available in Databricks, BigQuery, STMO and Amplitude.

In general, metrics logged by the [FxA auth server](https://github.com/mozilla/fxa/tree/master/packages/fxa-auth-server) reflect authentication events such as account creation, logins to existing accounts, etc. Metrics logged by the [FxA content server](https://github.com/mozilla/fxa/tree/master/packages/fxa-content-server) reflect user interaction and progression through the FxA web UI - form views, form engagement, form submission, etc. The [FxA oauth server](https://github.com/mozilla/fxa/tree/master/packages/fxa-auth-server/fxa-oauth-server) logs metrics events when oauth clients (Monitor, Lockwise, etc) create and check authentication tokens.

## Metrics Taxonomies

There are two overlapping taxonomies or sets of FxA event metrics.

[**Flow Metrics**](https://github.com/mozilla/fxa-auth-server/blob/master/docs/metrics-events.md): these are an older set of metrics events that can be queried through redshift and via the `FxA Activity Metrics` data source in re:dash. The [re:dash import jobs](https://github.com/mozilla/fxa-activity-metrics/) are run once a day. See [this documentation](https://github.com/mozilla/fxa-auth-server/blob/master/docs/metrics-events.md) for detailed description of the types of flow events that are logged and the tables that contain them (note this documentation does not contain an exhaustive list of all flow metrics but is generally still accurate about the ones that are described). Note there are 50% and 10% sampled versions of the major tables, which contain more historical data than their complete counterparts. Complete tables go back 3 months, 50% tables go back 6 months, and 10% tables go back 24 months. Sampling is done at the level of the FxA user id `uid` (i.e. integer(`uid`) % 100).

[**Amplitude Events**](https://analytics.amplitude.com/mozilla-corp/manage/project/178231/advanced/events): FxA started to send metrics events to amplitude circa October 2017. The [code responsible for batching events to amplitude](https://github.com/mozilla/fxa-amplitude-send) over HTTP is run in more-or-less real-time. Amplitude events can be queried through the [amplitude UI](https://analytics.amplitude.com/mozilla-corp/space/vj9qof9) as well as various tables in [BigQuery](https://console.cloud.google.com/bigquery?project=moz-fx-data-derived-datasets) that maintain copies of the events that are sent to Amplitude. [`moz-fx-data-derived-datasets.telemetry.fxa_content_auth_events_v1`](https://github.com/mozilla/bigquery-etl/blob/master/sql/fxa_content_auth_events_v1.sql) is probably the easiest BigQuery table to use, though it does not contain email bounce events and (at the time of writing) only contains data starting at 2019-03-01.

Note that the BigQuery [ETL jobs](https://github.com/mozilla/bigquery-etl/tree/master/sql) run daily while real-time data is accessible through the amplitude UI.

FxA's amplitude metrics were originally just re-configured and re-named versions of the flow metrics. However things have since diverged a bit and there are now metrics events that only have an amplitude version but no corresponding flow event, and vice-versa. If you are wondering whether a certain event is logged its likely you will have to check both data sources.

**Generally speaking, one should first try to use the amplitude metrics rather than the flow events** for these reasons:
1. For quick answers to simple questions the amplitude UI is often more efficient than writing SQL.
    * The caveat here is that is can sometimes be *too* easy to build a chart in amplitude - it doesn't exactly encourage the careful consideration that having to write a query out by hand implicitly encourages.
2. By-country data is currently not available in redshift.
3. There have been outages in the redshift data that have not affected the amplitude data.
4. Querying redshift is (generally) slower.

It is also possible to query the FxA server logs directly through BigQuery (ask an FxA team member for access), though virtually all analytics-related questions are more easily answered using the data sources described above.

## Counting Active Firefox Account Users
Analysts are commonly asked how many Firefox Account holders are active on a set of given days, weeks, or months (DAU/WAU/MAU). Because FxA is an authentication platform with many different relying services, one could imagine a variety of different ways that users could be counted (or not counted). In practice, we have maintained [a list of metrics events](https://analytics.amplitude.com/mozilla-corp/manage/project/178231/advanced/events) that we believe reflect "active" usage of an account (refer to the `Activity` column). **Counting the number of active users within a given time period is then a matter of counting the number of unique user ids (`uid`) that generate at least one event in the list of active events.** Amplitude's notion of `Any Active Event` makes this counting easy in practice. Note that users are not assigned a `uid` until after they sign up. This means that when counting MAU (for example) we do not count users who engaged with a sign-in or sign-up form but did not complete the process.

This "laundry list" approach may seem less than ideal (and it does have some real drawbacks - see below), but it has at least one important practical advantage. When a new (amplitude) event is added or instrumented, its `Activity` property must be set by hand, that is, by a human being. So, for every event in the list, someone has given consideration as to whether or not the process generating the event is user-dependent. Compare this to standard desktop telemetry - counting the unique number of `client_id`s that submit a ping within a given time period does not make any guarantees about the activity or engagement of the clients being counted.

How do we determine whether an event should be counted as "active"? This is not a deterministic process, and in general we leave it to the person instrumenting the event to use their best judgment. In practice, most cases are clear-cut. However, we can consider two heuristics to be generally important:

1. Does the user need to be (successfully) authenticated with their account in order for the event to be triggered?

Some examples help to illustrate. We generally don't count the sending of emails as an active event, although each email event is associated with the `uid` of the recipient. For instance, we send informational emails to users after they complete account registration, and we do not count these events as active. Why? The common-sense answer is that it seems disingenuous to count emails that the user didn't directly request towards an "active" metric. Put another way, these email events do not meet criteria 1 above - their occurrence is independent on whether the user happens to be authenticated.

Now consider the case of the `fxa_activity - cert_signed` event, which we DO count as active. This event is triggered by FxA clients retrieving a signed certificate from the FxA auth server. For sync clients, this certificate must be current in order for sync to work (is this too much of a simplification?). Although this event generated "automatically" as a result of the client's sync implementation, and syncing does not require explicit user action, it is nevertheless 100% dependent on a user's account being in a "green" authentication state. The user would not generate this event if they were not properly signed in; they event meets criteria 1 above. `fxa_activity - access_token_created` and `fxa_activity - access_token_checked` are similar events that are not directly generated by a user action but require an account to be in a good authentication state.

Counting things in this way also has implications for the way different services are measured. Some services **require** an account to be in a continuously green state to be usable (e.g. the Lockwise mobile apps and sync), and we tend to get a relatively steady stream of events from these services. Others offer FxA as one authentication option among many, or do not make FxA a hard requirement for use (e.g. Firefox Monitor). For these services, we tend to get a few events when the user signs in, then not much else after.

So although one could argue that **any** event that occurs within an application after a user authenticates should count towards FxA "activity", we have chosen to take a more conservative approach and only count events that (more or less) relate directly to the user's authentication state. We believe these measures are more closely tied to the services that FxA directly offers.

There are drawbacks to this method of counting users.
