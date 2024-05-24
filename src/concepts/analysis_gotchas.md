# Analysis Gotchas

When you perform an analysis on any data, there are some mistakes that are easy to make:

- Do you know what question that you hope to answer?
- Is your sample representative of your population?
- Is your result "real"? How precisely can you state your conclusion?

This section is not about those traps. Instead, it is about quirks and pitfalls that are specific to Mozilla's data systems.

## Table of Contents

<!-- toc -->

## Intermittent issues

Despite best efforts, problems may occur from time to time with the ingestion of data or the faithful creation of datasets.

Issues undergoing investigation are marked with the `[data-quality]` whiteboard tag in Bugzilla. See [currently open issues](https://bugzilla.mozilla.org/buglist.cgi?bug_status=UNCONFIRMED&bug_status=NEW&bug_status=ASSIGNED&bug_status=REOPENED&classification=Client%20Software&classification=Developer%20Infrastructure&classification=Components&classification=Server%20Software&classification=Other&priority=P1&priority=P2&priority=P3&priority=--&product=Data%20Platform%20and%20Tools&resolution=---&status_whiteboard=%5Bdata-quality%5D&status_whiteboard_type=allwordssubstr&list_id=15179084).

Especially severe problems with production data are announced on the `fx-data-dev` mailing list (see [getting help](getting_help.md)). Subscribing to this mailing list is recommended if you are a current or aspiring data practitioner.

## Notable historic events

See also [the spreadsheet of notable historic events](https://docs.google.com/spreadsheets/d/16Cyx_KBieRdQkSBKolivqpBaK2H-VceN9LEZcL0snHg/edit#gid=0). This spreadsheet is imported into BigQuery, and can be found at `moz-fx-data-shared-prod.static.data_incidents_v1`.

**If you add an entry here, please add it to that spreadsheet as well!**

When you start to evaluate trends, be aware of events from the past that may invite comparisons with history. Here are a few to keep in mind:

- **Feb 29 , 2024** - Spike in the [search engine changed probe](https://dictionary.telemetry.mozilla.org/apps/firefox_desktop/metrics/search_engine_default_changed) for users who had an engine update for versions >= 124 . This is due to search engine default changed probes being triggered during engine updates even when users don't actually change their default search engines post-update [bug](https://bugzilla.mozilla.org/show_bug.cgi?id=1876178). More details can be found [here](https://mozilla-hub.atlassian.net/browse/RS-1051).
- **Jan 15 - May 1, 2024** - Legacy Telemetry pings containing os information from Arch Linux clients without the `lsb-release` package were [dropped](https://bugzilla.mozilla.org/show_bug.cgi?id=1875874).
- **Dec 7, 2023** - Contextual Services data for Firefox Desktop versions 116 and up [now supplied by Glean](http://mozilla-hub.atlassian.net/browse/DSRE-1489).
- **Nov 20, 2023** - Changeover day for Onboarding data sent via Messaging System from PingCentre to Glean. Views and datasets downstream of `messaging_system.onboarding` [began being fueled by Glean-sent data instead of PingCentre-sent data](https://github.com/mozilla/bigquery-etl/pull/4457).
- **Jul 16, 2023 - Jul 24, 2023** - During the migration from release to ESR of Firefox users on obsolete versions of MacOS and Windows, Firefox sent deletion request pings for clients in the migration, which also reset the `client_id`. [See the summary of the incident here.](https://docs.google.com/document/d/1vdn9OFSoKPD5wt14dmTwyh0kGs-96fWx26ESui95jo0/edit). Approximately 2 million clients were affected by this bug; as a result of this, around 1.3 million clients were double counted due to both the old `client_id` and reset `client_id` being active on the same day.
- **Mar 17, 2023 - May 9, 2023** - Firefox for Android was collecting but not sending `perf.page_load` events during this period. The recorded events started being sent after May 9, 2023 resulting in a spike of events that eventually returned to normal levels. [See Bug 1833178 for more info.][bug1833178]
- **Mar 14, 2023** - Firefox for Android began reporting significantly fewer new installs, due to [a fix for Client ID regeneration](https://docs.google.com/document/d/1Tf8F2FndPsOAWc7peLxgUZd4t-LUJu8RMotiDhgKF7I/edit#heading=h.xyargldz6xg0). This also affected retention for both new and existing users.
- **Nov 15, 2022** - A major bug in the `search with ads` probes was fixed on Firefox Desktop. The [bug fix](https://bugzilla.mozilla.org/show_bug.cgi?id=1800506) impacts Firefox 109+ and resulted in significant increases in the number of searches with ads recorded.
- **Aug 31 2022** - [A small number of records were missing from stable tables until October 5, 2022 and not reprocessed into downstream ETL tables][jiradsre999].
- **July 19 - August 3, 2022** - [Fenix v103 seeing an increase in `null` values in `client_info` fields](https://bugzilla.mozilla.org/show_bug.cgi?id=1781085).
  Glean failed to properly collect data for the `client_info` fields `android_sdk_version`, `device_model`, `device_manufacturer` and `locale`.
  This has been fixed in subsequent releases and is fixed in Fenix 103.2 and all later releases.
  No backfill.
- **May 24 - Jun 10, 2022** - `search_with_ads` drops on Firefox Desktop globally. Upon [investigation](https://docs.google.com/document/d/1wdU1O6Anmqs87PdyYXympTXHznoskU6pVdSgTS6ilpA/edit), the issue is believed to be related to Google's core algorithm update in May 2022.
- **May 15, 2022** - [Fixed potential under report `search_with_ads`][bug1673868].
  Ad impressions were not tracked for SERP that took longer than 1 second to load. This was initially uncovered by QA for ad impressions on DuckDuckGo SERP. The fix addresses for all search partners and is not limited to DuckDuckGo.
- **Dec 1, 2021 - Jan 23, 2022** - [Search values in Android Focus from core telemetry fell][jirado673].
- **Nov 16, 2021** - [Submissions were rejected from 17:44 to 18:10 UTC][jirads1843].
- **Nov 4, 2021** - [CORS headers added to support receiving submissions from Glean.js websites][bug1676676].
- **Sep 30 2021 - Oct 06 2021** - [Submissions from some countries were rejected][bug1733953].
- **Sep 30 2021 - Oct 04 2021** - [Submissions from clients on some older platforms were dropped][bug1733953].
- **Aug 23 2021 - Aug 29 2021** - [Approximately 1/251 of pings were improperly labeled as coming from Kansas City, US][bug1729069].
- **Aug 05 2021 - Aug 31 2021** - Drop in search metrics (`tagged_sap`, `tagged_follow_on`, `search_with_ads`, `ad_click`) in Fenix due to probe expiry. [Incident report](https://docs.google.com/document/d/1C29HmYponPcqtX4yR4QA7uBkhhkAM76WqMW3PQBnL_g/edit) and [`STMO#203423`](https://sql.telemetry.mozilla.org/queries/82098/source#203423).
- **Feb 16 2021 - Feb 25 2021** - [A small number of stub installer pings may have been discarded due to URI deduplication][bug1694764].
- **Jan 28, 2021** - [Fenix DAU jumped rapidly, due to increased sending of the baseline ping](https://docs.google.com/document/d/1MEsAUqjaIZCUtWLFAhXHxq-m1hDEw1QAOKYEva4DDZk/edit)
- **August 6, 2020** - [Pings with "automation" tag in X-Source-Tags will no longer appear in stable tables][bq1215]
  This is particularly relevant for removing pings related to automated testing of Fenix.
- **August 1, 2020 - August 31, 2020** - [Fennec was migrated to Fenix](https://sql.telemetry.mozilla.org/queries/89203#220890), causing changes in both how data was reported (Glean rather than the core ping) and some reported metrics (e.g. DAU, as people dropped off).
- **July 20, 2020** - [Glean dropping application lifetime metrics from `metrics` pings][bug1653244].
  Glean Android bindings from version `v25.0.0` up to and including `v31.4.0` had a bug that would cause metrics with “lifetime: application” to be cleared before they could be collected for metrics pings sent during startup. This can result in application lifetime metrics like experiment information being randomly missing from the data.
- **April 14, 2020** - [Telemetry edge server rejects pings for an hour][bug1630096].
  Clients generally retry periodically until success is achieved. Therefore, most of these messages were eventually ingested; submission timestamps appear later than normal. A small number of pings are attributed to a later day or were never sent due to the client never being reopened.
- **February 11, 2020** - Firefox 73 was released and began the start of [4-week release cycles][four_week_cycles]. There was a gradual transition from 7/8 week ones to 4 week ones.
- **December 4 2019** - [AWS Ingestion Pipeline decommissioned][bug1598815].
  Specifically, the last ping relayed through the AWS machinery had a
  timestamp of `2019-12-04 22:04:45.912204 UTC`.
- **October 29 2019** - Glean SDK Timing Distribution(s) report buckets
  1 nanosecond apart. This occurred because of a potential rounding bug in Glean SDK
  versions less than `19.0.0`. See [Bug 1591938].
- **October 23 2019** - [Hot-fix shipped through add-ons][endpoint_hotfix] that
  reset the Telemetry endpoint preference back to the default for a large number of users.
- **September 1 - October 18 2019** - BigQuery Ping tables are
  [missing the `X-PingSender-Version` header information][pull1491].
  This data is available before and after this time period.
- **May 4 - May 11 2019** - [Telemetry source data deleted][armagaddon].
  No source data is available for this period and derived tables may have
  missing days or imputed values.
  Derived tables that depend on multiple days may have have affected dates
  beyond the deletion region.
- **January 31 2019** - [Profile-per-install][bug1474285] landed in `mozilla-central`
  and affected how new profiles were created.
  See [discussion in `bigquery-etl#212`][bq212].
- **October 25 2018** - many `client_id`s on Firefox Android were reset to the
  same `client_id`.
  For more information, see the [post-mortem][reset_cid_retro]
  or [Bug 1501329].
- **November 2017** - Quantum Launch. There was a surge in new profiles and usage.
- **June 1 and 5, 2016** - [Main Summary `v4` data is missing][bug1482509]
  for these two days.
- **March 2016** - Unified Telemetry launched.

[bug 1591938]: https://bugzilla.mozilla.org/show_bug.cgi?id=1591938
[endpoint_hotfix]: https://docs.google.com/document/d/1gQF-iU3E21SG985Cl2Ius4LoRXduUrNa5In9hafLIqs/edit
[pull1491]: https://github.com/mozilla-services/cloudops-infra/pull/1491
[armagaddon]: https://blog.mozilla.org/blog/2019/05/09/what-we-do-when-things-go-wrong/
[bug1474285]: https://bugzilla.mozilla.org/show_bug.cgi?id=1474285
[bq212]: https://github.com/mozilla/bigquery-etl/issues/212
[bq1215]: https://github.com/mozilla/bigquery-etl/pull/1215
[reset_cid_retro]: https://docs.google.com/document/d/1r1PDQnqhsrPkft0pB46v9uhXGxR_FzK4laKJLGttXdA
[bug 1501329]: https://bugzilla.mozilla.org/show_bug.cgi?id=1501329
[bug1482509]: https://bugzilla.mozilla.org/show_bug.cgi?id=1482509
[bug1598815]: https://bugzilla.mozilla.org/show_bug.cgi?id=1598815
[four_week_cycles]: https://docs.google.com/document/d/1oJhnvAOx2c8Mp-Xpk-3j-2d45yu_fghYS2yAbn1aeNY/edit#heading=h.iba82gckexg7
[bug1630096]: https://bugzilla.mozilla.org/show_bug.cgi?id=1630096
[bug1653244]: https://bugzilla.mozilla.org/show_bug.cgi?id=1653244
[bug1694764]: https://bugzilla.mozilla.org/show_bug.cgi?id=1694764
[bug1729069]: https://bugzilla.mozilla.org/show_bug.cgi?id=1729069
[bug1733953]: https://bugzilla.mozilla.org/show_bug.cgi?id=1733953
[bug1676676]: https://bugzilla.mozilla.org/show_bug.cgi?id=1676676
[jirads1843]: https://mozilla-hub.atlassian.net/browse/DS-1843
[jirado673]: https://mozilla-hub.atlassian.net/browse/DO-673
[bug1673868]: https://bugzilla.mozilla.org/show_bug.cgi?id=1673868
[jiradsre999]: https://mozilla-hub.atlassian.net/browse/DSRE-999
[bug1833178]: https://bugzilla.mozilla.org/show_bug.cgi?id=1833178

## Pseudo-replication

Telemetry data is a collection of pings.
A single main-ping represents a single subsession.
Some clients have more subsessions than others.

When you say ["63% of beta 53 has Firefox set as its default browser"](https://mzl.la/2q75dbF), you need to specify that it is 63% of _pings_ because it represents only around 46% of clients.
(Apparently users with Firefox Beta 53 set as their default browser submitted
more main-pings than users who did not).

## Profiles vs Users

You may have noticed that the term "clients" and not "users" was applied in the above-listed section because of all the things can be counted, users is not one of them:

Users can have multiple Firefox profiles that runs on the same system at
the same time (like developers).

Users can have the same Firefox profile that runs on several systems on
different days of the week (also developers).

The only things we can count are pings and clients.
Clients can be counted because a `client_id` is sent with each ping that uniquely
identifies the profile from which it originated.
This is generally close enough to the idea of a so-called "user" that can be considered for counting profiles and calling them users. However, you may run into some instances
where the distinction matters.

When in doubt, be precise. You count _clients_.

[This article](./profile/index.md) describes the concept of "profiles" in detail.

## Opt-in versus Opt-out

Mozilla does not collect the same information from everyone.

Every profile that does not have Telemetry disabled sends "opt-out" Telemetry, which
includes:

- Nearly all the data in the [Environment]
- Some specific [Histograms], [Scalars], and [Events] that are marked
  `"releaseChannelCollection": "opt-out"`

Most probes are "opt-in": No information is received from the probes unless a user
opts into sending this information by installing any pre-release version of Firefox:
Beta, Nightly or Developer Edition (the latter is similar to Beta).

If you want to encourage users to collect good information for Mozilla, ask them to install a Beta release.

[environment]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/environment.html
[histograms]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/collection/histograms.html
[scalars]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/collection/scalars.html
[events]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/collection/events.html

## Trusting Dates

Do not assume that the time reported by an instance of Firefox desktop is correct. The situation is somewhat better on mobile devices, but you should still be cautious.

Any timestamp recorded by the user is subject to "clock skew."
The user's clock can be set (purposefully or accidentally) to any time at all.
SSL certificates tend to keep timestamps in a certain relatively-accurate window
because a user whose clock has been set too far in the past or too far in the future
may confuse certain expiration-date-checking code.

Examples of client times from Firefox desktop pings:

- `crashDate`
- `crashTime`
- `meta/Date`
- `sessionStartDate`
- `subsessionStartDate`
- `profile/creationDate`

Examples of client times from Glean pings:

- [`ping_info.end_time`](https://mozilla.github.io/glean/book/user/pings/index.html#the-ping_info-section)

Examples of server times that you can trust:

- `submission_timestamp`
- `submission_date`

_Note_ `submission_date` does not appear in the [ping documentation]
because it is added in post-processing.

[ping documentation]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/common-ping.html

## Date Formats

Not all dates and times are created equal.
Most of the dates and times in Telemetry pings are [ISO 8601].
Most are full timestamps, though their resolution may differ from per-second to per-day.

Then there's `profile/creationDate` which is just a number of days since epoch (January 1, 1970).
Like `17177` for the date 2017-01-11.

**Tip:** If you want to convert `profile/creationDate` to a usable date in SQL:
`DATE_FROM_UNIX_DATE(SAFE_CAST(environment.profile.creation_date AS INT64))`

In derived datasets ISO dates are sometimes converted to strings using one of
the following formats: `%Y-%m-%d` or `%Y%m%d`.

The date formats for different rows in `main_summary` are described on the
[`main_summary` reference page][msref].

Although build IDs look like dates, they are not. If you take the first eight characters, you can use them as a proxy for the day when the build was released.

`metadata.header.date` represents an HTTP Date header in a [RFC 7231]-compatible format.

**Tip:** If you want to parse `metadata/Date` to become a usable date in SQL:
`SAFE.PARSE_TIMESTAMP('%a, %d %b %Y %T %Z', REPLACE(metadata.header.date, 'GMT+00:00', 'GMT'))`
Alternatively, you can use the already parsed version that is available in user-facing views (`metatdata.header.parsed_date`)

[iso 8601]: https://en.wikipedia.org/wiki/ISO_8601
[msref]: ../datasets/batch_view/main_summary/reference.md#time-formats
[rfc 7231]: https://datatracker.ietf.org/doc/html/rfc7231#section-7.1.1.1

## Delays

There is an inherent delay between Telemetry data being created on the client and it being received by Mozilla.
Most Telemetry data produced by desktop Firefox is represented in the main ping. It is sent at the beginning of a client's _next_ Firefox session.
If the user shuts down Firefox for the weekend, Firefox does not receive any data that has been generated on Friday data until Monday morning.

Generally speaking, data from two days ago is usually fairly representative.

If you'd like to read more about this subject, there is a series of blog posts [here][delays1], [here][delays2] and [here][delays3].

[bug 1336360]: https://bugzilla.mozilla.org/show_bug.cgi?id=1336360
[delays1]: https://chuttenblog.wordpress.com/2017/02/09/data-science-is-hard-client-delays-for-crash-pings/
[delays2]: https://chuttenblog.wordpress.com/2017/07/12/latency-improvements-or-yet-another-satisfying-graph/
[delays3]: https://chuttenblog.wordpress.com/2017/09/12/two-days-or-how-long-until-the-data-is-in/

### Pingsender

Pingsender greatly reduces any delay before sending pings to Mozilla.
However, only some types of pings are sent by Pingsender.
[Bug 1310703] introduced Pingsender for crash pings and was merged in Firefox 54,
which was included in release on June 13, 2017.
[Bug 1336360] moved shutdown pings to Pingsender and was merged in Firefox 55,
which was included in release on August 8, 2017.
[Bug 1374270] added sending health pings on shutdown using Pingsender and was
merged in Firefox 56, which was included in release on Sept 28, 2017.
Other types of pings are not sent with Pingsender.
This is usually okay because Firefox is expected to continue to run long
enough to send these pings.

Mobile clients do not have Pingsender. Therefore, a delay occurs as described in [`STMO#49867`][delay_q].

[bug 1310703]: https://bugzilla.mozilla.org/show_bug.cgi?id=1310703
[bug 1374270]: https://bugzilla.mozilla.org/show_bug.cgi?id=1374270
[delay_q]: https://sql.telemetry.mozilla.org/queries/49867#134105

### Submission Date

`submission_date` or `submission_timestamp` represents the server time at which a ping is received from a client. It is used as a partitioning column (useful for both query optimization and restricting the range of data under consideration) and should be considered reliable.

In [bug 1422892](https://bugzilla.mozilla.org/show_bug.cgi?id=1422892) it was decided
to standardize on using `submission_date` as opposed to client-generated dates.

Summary of reasons for this decision:

- not subject to client clock skew
- doesn't require normalization
- good for backfill
- good for daily processing
- and usually good enough

## Pings from Robots

In general, data coming from an application instance not run by a human is not wanted in analysis. As of this writing, [GeckoDriver](https://github.com/mozilla/geckodriver) (one of the official mechanisms to launch and control an automated version of Firefox for e.g. web compatibility testing) is [configured _not_ to send Telemetry by default](https://searchfox.org/mozilla-central/rev/baf1cd492406a9ac31d9ccb7a51c924c7fbb151f/testing/geckodriver/src/prefs.rs#154) but we can't control for other things people might do in the field.

On desktop, one field to watch out for is headless mode (`environment.system.gfx.headless` in the main ping): if that field is set, you are for certain not working with a version of Firefox being operated by a real human. You can see an example of some client pings with this field set skewing the nightly numbers in [bug 1643341](https://bugzilla.mozilla.org/show_bug.cgi?id=1643341). An easy solution is to just filter out these types of clients in your analysis. You can see an example of this pattern in [`STMO#71781`](https://sql.telemetry.mozilla.org/queries/71781/source).

## Build Ids

Generally speaking, application versions are monotonically increasing multipart alphanumeric strings like "89.0a1" or "68.0.3".
Build Ids are not this.
A Build Id is a sequence of characters that is unique to a specific build of a product.
Since the application version may not vary across shipped versions (for example, a Firefox nightly version stays the same across its entire cycle), a build id helps identify which code changes were included in a build as well as what features may have been enabled for it.
For example, in Firefox Desktop, the build id is the date and time the build was built in yyyymmddhhmmss format.
A build id might be formatted in any way and contain the time or version control system revision of the code included in the build.

Do not assume build id's are consistent across the products we ship. A build id format may vary between products, between channels of the same product, or over time within the same channel of the same product.
The build id format for Firefox Desktop has been very stable over time thus far, but even it can be different for different platforms in some respin circumstances (if e.g. only one platform's builder failed).
