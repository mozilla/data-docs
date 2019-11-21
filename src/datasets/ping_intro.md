We receive data from our users via **pings**.
There are several types of pings,
each containing different measurements and sent for different purposes.
To review a complete list of ping types and their schemata, see
[this section of the Mozilla Source Tree Docs][sourcedocs].

Many pings are also described by a JSONSchema specification which can be found in [this repository][jschemas].

There are a few pings that are central to delivering our core data collection
primitives (Histograms, Events, Scalars) and for keeping an eye on Firefox
behaviour (Environment, New Profiles, Updates, Crashes).

For instance, a user's first session in Firefox might have four pings like this:

![Flowchart of pings in the user's first session](/datasets/images/first_session_pings.png)

### "main" ping

The ["main" ping][main_ping] is the workhorse of the Firefox Telemetry system.
It delivers the Telemetry Environment as well as Histograms and Scalars for all
process types that collect data in Firefox. It has several variants each with
specific delivery characteristics:

| Reason             | Sent when                | Notes                         |
| ------------------ | ------------------------ | ------------------------------|
| shutdown           | Firefox session ends cleanly | Accounts for about [80%][main_reasons] of all "main" pings. Sent by Pingsender immediately after Firefox shuts down, subject to conditions: Firefox 55+, if the OS isn't also shutting down, and if this isn't the client's first session. If Pingsender fails or isn't used, the ping is sent by Firefox at the beginning of the next Firefox session.|
| daily              | It has been more than 24 hours since the last "main" ping, and it is around local midnight | In long-lived Firefox sessions we might go days without receiving a "shutdown" ping. Thus the "daily" ping is sent to ensure we occasionally hear from long-lived sessions.|
| environment-change | Telemetry Environment changes | Is sent immediately when triggered by Firefox (Installing or removing an addon or changing a monitored user preference are common ways for the Telemetry Environment to change)|
| aborted-session    | Firefox session doesn't end cleanly | Sent by Firefox at the beginning of the next Firefox session.|

It was introduced in Firefox 38.

### "first-shutdown" ping

The ["first-shutdown" ping][first_shutdown_ping] is identical to the "main"
ping with reason "shutdown" created at the end of the user's first session,
but sent with a different ping type. This was introduced when we started
using Pingsender to send shutdown pings as there would be a lot of
first-session "shutdown" pings that we'd start receiving all of a sudden.

It is sent using Pingsender.

It was introduced in Firefox 57.

### "event" ping

The ["event" ping][event_ping] provides low-latency eventing support to Firefox
Telemetry. It delivers the Telemetry Environment, Telemetry Events from all
Firefox processes, and some diagnostic information about Event Telemetry. It is
sent every hour if there have been events recorded, and up to once every 10
minutes (governed by a [preference][preferences]) if the maximum event limit
for the ping (default to 1000 per process, governed by a
[preference][preferences]) is reached before the hour is up.

It was introduced in Firefox 62.

### "update" ping

Firefox Update is the most important means we have of reaching our users with
the latest fixes and features. The ["update" ping][update_ping] notifies us
when an update is downloaded and ready to be applied (reason: "ready") and when
the update has been successfully applied (reason: "success"). It contains the
Telemetry Environment and information about the update.

It was introduced in Firefox 56.

### "new-profile" ping

When a user starts up Firefox for the first time, a profile is created.
Telemetry marks the occasion with the ["new-profile" ping][new_profile_ping]
which sends the Telemetry Environment. It is sent either 30 minutes after Firefox
starts running for the first time in this profile (reason: "startup") or at the
end of the profile's first session (reason: "shutdown"), whichever comes first.
"new-profile" pings are sent immediately when triggered. Those with reason
"startup" are sent by Firefox. Those with reason "shutdown" are sent by
Pingsender.

It was introduced in Firefox 55.

### "crash" ping

The ["crash" ping][crash_ping] provides diagnostic information whenever a
Firefox process exits abnormally. Unlike the "main" ping with reason
"aborted-session", this ping does not contain Histograms or Scalars. It
contains a Telemetry Environment, [Crash Annotations][crash_annotations], and
[Stack Traces][stack_traces].

It was introduced in Firefox 40.

### "deletion request" ping

In the event a user opts out of Telemetry, we send one final
["deletion-request" ping][deletion_request_ping] to let us know. We try
exactly once to send it, discarding the ping if sending fails. It contains
only the [common ping data][common_ping_data] and an empty payload.

It was introduced in Firefox 70, replacing the ["optout" ping][optout_ping]
(which was in turn introduced in Firefox 63).

### Pingsender

[Pingsender][pingsender] is a small application shipped with Firefox which
attempts to send pings even if Firefox is not running. If Firefox has crashed or has already shut
down we would otherwise have to wait for the next Firefox session to begin to
send pings.

Pingsender was introduced in Firefox 54 to send "crash" pings. It was expanded
to send "main" pings of reason "shutdown" in Firefox 55 (excepting the first
session). It sends the "first-shutdown" ping since its introduction in Firefox 57.

### Analysis

The large majority of analyses can be completed using only the
[main ping][main_ping].
This ping includes histograms, scalars, and other performance and diagnostic data.

Few analyses actually rely directly on any raw ping data.
Instead, we provide **derived datasets** which are processed versions of these data,
made to be:
* Easier and faster to query
* Organized to make the data easier to analyze
* Cleaned of erroneous or misleading data

Before analyzing raw ping data,
**check to make sure there isn't already a derived dataset** made for your purpose.
If you do need to work with raw ping data, be aware that loading the data can take a while.
Try to limit the size of your data by controlling the date range, etc.

#### Accessing the Data

Ping data lives in BigQuery and is accessible in [re:dash][stmo];
see our [BigQuery intro](../cookbooks/bigquery.md).
There is currently limited history for main pings available in BigQuery;
an import of historical data is [planned](https://bugzilla.mozilla.org/show_bug.cgi?id=1568042), but without a determined timeline,
so longer history requires an [ATMO cluster][atmo] using the [Dataset API][dataset].

#### Further Reading

You can find [the complete ping documentation][sourcedocs].
To augment our data collection, see [Collecting New Data][addprobe] and the
[Data Collection Policy][datacollection].

[sourcedocs]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/index.html
[jschemas]: https://github.com/mozilla-services/mozilla-pipeline-schemas/tree/master/schemas/telemetry
[main_ping]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/main-ping.html
[first_shutdown_ping]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/first-shutdown-ping.html
[event_ping]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/event-ping.html
[update_ping]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/update-ping.html
[new_profile_ping]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/new-profile-ping.html
[crash_ping]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/crash-ping.html
[deletion_request_ping]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/data/deletion-request-ping.html
[optout_ping]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/obsolete/optout-ping.html
[crash_annotations]: https://searchfox.org/mozilla-central/source/toolkit/crashreporter/CrashAnnotations.yaml
[common_ping_data]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/common-ping.html
[main_reasons]: https://sql.telemetry.mozilla.org/queries/3434
[stack_traces]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/crash-ping.html#stack-traces
[preferences]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/internals/preferences.html
[atmo]: BROKEN:https://analysis.telemetry.mozilla.org/
[stmo]: https://sql.telemetry.mozilla.org/
[dataset]: https://mozilla.github.io/python_moztelemetry/api.html#module-moztelemetry.dataset
[addprobe]: https://developer.mozilla.org/en-US/docs/Mozilla/Performance/Adding_a_new_Telemetry_probe
[datacollection]: https://wiki.mozilla.org/Firefox/Data_Collection
[pingsender]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/internals/pingsender.html
