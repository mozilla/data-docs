# Analysis Gotchas

When performing analysis on any data there are some mistakes that are easy to make and details that are easy to overlook. Do you know exactly what question you hope to answer? Is your sample representative of your population? Is your result "real"? How precisely can you state your conclusion?

This document is not about those traps. Instead, it is about quirks and pitfalls specific to [Telemetry](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/index.html).

### Pseudo-replication

Telemetry data is a collection of pings. A single main-ping represents a single subsession. Some clients have more subsessions than others.

So when you say ["63% of beta 53 has Firefox set as its default browser"](https://mzl.la/2q75dbF), make sure you specify it is 63% of _pings_, since it is only around 46% of clients. (Apparently users with Firefox Beta 53 set as their default browser submit more main-pings than users who don't).

### Profiles vs Users

In the section above you'll notice I said "clients" not "users." That is because of all the things we're able to count, users isn't one of them.

Users can have multiple Firefox profiles running on the same computer at the same time (like developers).

Users can have the same Firefox profile running on several computers on different days of the week (also developers).

The only things we can count are pings and clients. Clients we can count because we send a `client_id` with each ping that uniquely identifies the profile from which it came. This is generally close enough to our idea of "user" that we can get away with counting profiles and calling them users, but you may run into some instances where the distinction matters.

When in doubt, be precise. You're counting _clients_.

### Opt-in vs Opt-out

We don't collect the same information from everyone.

Every profile that doesn't have Telemetry disabled sends us "opt-out" Telemetry. This includes:
* Nearly everything in the [Environment](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/environment.html)
* Some very specific [Histograms](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/collection/histograms.html), [Scalars](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/collection/scalars.html), and [Events](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/collection/events.html) that are marked `"releaseChannelCollection": "opt-out"`

Most probes are "opt-in": we do not get information from them unless the user opts into sending us this information. Users can opt-in in two ways:
1. Using Firefox's Options UI to tick the box that gives us permission
2. Installing any pre-release version of Firefox

The nature of selection bias is such that the population in #1 is useless for analysis. If you want to encourage users to collect good information for us, ask them to install Beta: it's only slightly harder than finding and checking the opt-in check-box in Firefox.

### Trusting Dates

Don't trust client times.

Any timestamp recorded by the user is subject to "clock skew." The user's clock can be set (purposefully or accidentally) to any time at all. The nature of SSL certificates tends to keep this within a certain relatively-accurate window, because a user who's clock is too far in the past or too far in the future might confuse certain expiration-date-checking code.

Examples of client times: `crashDate`, `crashTime`, `meta/Date`, `sessionStartDate`, `subsessionStartDate`, `profile/creationDate`

Examples of server times you can trust: `Timestamp`, `submission_date`

### Date Formats

Not all dates and times are created equal. Most of the dates and times in Telemetry pings are [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601). Most are full timestamps, though their resolution may differ from being per-second to being per-day.

Then there's `profile/creationDate` which is just a number of days since epoch. Like `17177` for the date 2017-01-11.

**Tip:** To convert `profile/creationDate` to a usable date in SQL: `DATE_ADD('day', profile_created, DATE '1970-01-01')`

In derived datasets ISO dates are sometimes converted to strings in one of two formats: `%Y-%m-%d` or `%Y%m%d`.

The date formats for different rows in `main_summary` are described on the [`main_summary` reference page](../datasets/batch_view/main_summary/reference.md#time-formats).

Build ids look like dates but aren't. If you take the first eight characters you can use that as a proxy for the day the build was released.

`metadata/Date` is an HTTP Date header in a [RFC 7231](http://tools.ietf.org/html/rfc7231#section-7.1.1.1)-compatible format.

**Tip:** To parse `metadata/Date` to a usable date in SQL: `DATE_PARSE(SUBSTR(client_submission_date, 1, 25), '%a, %d %b %Y %H:%i:%s')`

### Delays

Telemetry data takes a while to get into our hands. The largest data mule in Telemetry is the main-ping. It is (pending [bug 1336360](https://bugzilla.mozilla.org/show_bug.cgi?id=1336360)) sent at the beginning of a client's _next_ Firefox session. If the user shuts down their Firefox for the weekend, we won't get their Friday data until Monday morning.

A rule of thumb is data from two days ago is usually fairly representative.

If you'd like to read more about this subject and look at pretty graphs, there are a series of blog posts [here](https://chuttenblog.wordpress.com/2017/02/09/data-science-is-hard-client-delays-for-crash-pings/), [here](https://chuttenblog.wordpress.com/2017/07/12/latency-improvements-or-yet-another-satisfying-graph/) and [here](https://chuttenblog.wordpress.com/2017/09/12/two-days-or-how-long-until-the-data-is-in/).

#### Pingsender

Pingsender greatly reduces delay in sending pings to Mozilla, but only some types of pings are sent by Pingsender. [Bug 1310703](https://bugzilla.mozilla.org/show_bug.cgi?id=1310703) introduced Pingsender for crash pings and was merged in Firefox 54, which hit release on June 13, 2017. [Bug 1336360](https://bugzilla.mozilla.org/show_bug.cgi?id=1336360) moved shutdown pings to Pingsender and was merged in Firefox 55, which hit release on August 8, 2017. [Bug 1374270](https://bugzilla.mozilla.org/show_bug.cgi?id=1374270) added sending health pings on shutdown via Pingsender and was merged in Firefox 56, which hit release on Sept 28, 2017. Other types of pings are not sent with Pingsender. This is usually okay because Firefox is expected to continue running long enough to send those pings.

Mobile clients do not have Pingsender, so they suffer delay as given in [this query](https://sql.telemetry.mozilla.org/queries/49867#134105).

### Submission Date

`submission_date` is the server time at which a ping is received from the client. We use it to
partition many of our data sets.

In [bug 1422892](https://bugzilla.mozilla.org/show_bug.cgi?id=1422892) we decided to standardize
on `submission_date`.

TL;DR

* not subject to client clock skew
* doesn't require normalization
* good for backfill
* good for daily processing
* and usually good enough
