# A brief history of Mozilla data collection

> This section was originally included in the [Project Smoot existing metrics report][smootv1]
> (Mozilla internal link); the DTMO version has been updated to reflect changes to the data platform.

[smootv1]: https://mozilla-private.report/smoot-existing-metrics/book/05_overview.html

## `blocklist.xml` and Active Daily Installs (ADI)

The [blocklist](https://wiki.mozilla.org/Blocklisting) was a mechanism
for informing Firefox clients about malicious add-ons, DLLs, and other
extension content that should be blocked. The blocklist also noted when
hardware acceleration features should be avoided on certain graphics
cards. To be effective, the blocklist needed to be updated on a faster
cadence than Firefox releases.

The blocklist was [first
implemented](https://bugzilla.mozilla.org/show_bug.cgi?id=271166) in
2006 for Firefox 2, and reported the app ID and version to the blocklist
server.

Several additional variables, including OS version, locale, and
distribution, were [added to the
URL](https://bugzilla.mozilla.org/show_bug.cgi?id=430120) for Firefox 3
in 2008. Being able to count users was already expressed as a priority
in the bug comments.

A count of blocklist fetches was used to produce a metric called Active
Daily Users, which was [renamed to Active Daily
Installs](https://bugzilla.mozilla.org/show_bug.cgi?id=812282) (ADI) by 2012.

As of August 2020, this mechanism has been superseded by a [Remote
Settings-based](https://bugzilla.mozilla.org/show_bug.cgi?id=1257565#c120)
replacement and the ADI measure is no longer in use. See the [historical
reference on ADI](./censuses.md#adi--active-daily-installs-blocklist-fetches)
for more information.

## Telemetry

The [earliest telemetry
infrastructure](https://bugzilla.mozilla.org/show_bug.cgi?id=585196)
landed in Firefox 6, and was driven [by engineering
needs](https://wiki.mozilla.org/Platform/Features/Telemetry).

Telemetry was originally opt-out on the nightly and aurora channels, and
opt-in otherwise. It originally lacked persistent client identifiers.

## Firefox Health Report

The Firefox Health Report (FHR) was specified to enable longitudinal and
retention analyses. FHR aimed to enable analyses that were not possible
based on the blocklist ping, update ping, telemetry, Test Pilot and
crash stats datasets that were already available.

FHR was [first
implemented](https://bugzilla.mozilla.org/show_bug.cgi?id=718066) in
Firefox 20. It was introduced in blog posts by [Mitchell
Baker](https://blog.lizardwrangler.com/2012/09/21/firefox-health-report/)
and [Gilbert
Fitzgerald](https://blog.mozilla.org/metrics/2012/09/21/firefox-health-report/).

To avoid introducing a persistent client identifier, FHR originally
relied on a “document ID” system. The client would generate a new UUID
(a random, unique ID) for each FHR document, and remember a list of its
most recent previous document IDs. While uploading a new FHR document,
the client would ask the server to remove its previous documents. The
intent was that the server would end up holding at most one document
from each user, and longitudinal metrics could be accumulated by the
client. This approach proved fragile and was abandoned. A [persistent
client identifier](https://bugzilla.mozilla.org/show_bug.cgi?id=968419)
was implemented for Firefox 30.

## Firefox Desktop Telemetry today

FHR was retired and merged with telemetry to produce the current
generation of telemetry data, distinguished as “v4 telemetry” or
“unified telemetry.”

Instead of mapping FHR probes directly to telemetry, the Unified
Telemetry project built upon the telemetry system to answer the
questions Mozilla had attempted to answer with FHR.

The [implementation of unified
telemetry](https://bugzilla.mozilla.org/show_bug.cgi?id=1122515) and
opt-out delivery to the release channel was completed for Firefox 42, in 2015.

Telemetry payloads are uploaded in documents called pings. Several kinds
of pings are defined, representing different kinds of measurement. These
include:

- `main`: activity, performance, technical, and other measurements;
  the workhorse of Firefox desktop telemetry
- `crash`: information about crashes, including stack traces
- `opt-out`: a farewell ping sent when a user disables telemetry
- `module`: on Windows, records DLLs injected into the Firefox process

and others.

Browser sessions and subsessions are important concepts in telemetry. A
**session** begins when the browser launches and ends—perhaps seconds or
days later— when the parent browser process terminates.

A **subsession** ends

- when its parent session ends, or
- at local midnight, or
- when the telemetry environment changes,

whichever comes first.

The [telemetry
environment](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/environment.html)
describes the hardware and operating system of the client computer. It
can change during a Firefox session when e.g. hardware is plugged into a
laptop.

The subsession is the reporting unit for activity telemetry; each `main`
ping describes a single subsession. Activity counters are reset once a
subsession ends. Data can be accumulated for analysis by summing over a
client’s pings.

Telemetry pings can contain several different types of measurements:

- scalars are integers describing either an event count or a
  measurement that occurs only once during a subsession;
  `simpleMeasurement`s are an older, less flexible scalar
  implementation in the process of being deprecated
- histograms represent measurements that can occur repeatedly during a
  subsession; histograms report the count of measurements that fell
  into each of a set of predefined buckets (e.g. between zero and one,
  between one and two, etc).
- events represent discrete events; the time and ordering of the
  events are preserved, which clarifies sequences of user actions

Data types are discussed in more depth in the [telemetry data
collection](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/collection/index.html)
documentation.

## Firefox Desktop Telemetry: The Next Generation

The next step for Firefox Desktop Telemetry is to prototype an implementation
using [Glean](glean/glean.md).

This effort is known as "Firefox on Glean" or FOG. This effort is expected to
begin in late 2019 / early 2020.
