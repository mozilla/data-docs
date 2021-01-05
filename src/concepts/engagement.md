# Engagement metrics

> This section was originally included in the [Project Smoot existing metrics report][smootv1]
> (Mozilla internal link).

[smootv1]: https://mozilla-private.report/smoot-existing-metrics/book/05_overview.html

A handful of metrics have been adopted as engagement metrics, either as
censuses of the population or to describe user activity within a
session. This chapter aims to describe what those metrics are and how
they’re defined.

## Engagement metrics

### `active_ticks`

The `active_ticks` probe [is
specified](https://bugzilla.mozilla.org/show_bug.cgi?id=1187069#c6) to
increment once in every 5-second window that a user performs an action
that could interact with content or chrome, including mousing over the
window while it lacks focus. One additional tick is recorded after the
activity stops.

Main pings provide two measurements of `active_ticks`: a
`simpleMeasurement` and a scalar.

The `simpleMeasurement` was [implemented in Firefox
37](https://bugzilla.mozilla.org/show_bug.cgi?id=1106122) before the
launch of unified telemetry, and had previously been
[implemented](https://bugzilla.mozilla.org/show_bug.cgi?id=826893) for
[FHR](https://bugzilla.mozilla.org/show_bug.cgi?id=827157).

The `simpleMeasurement` was discovered to be resetting incorrectly,
which was [fixed](https://bugzilla.mozilla.org/show_bug.cgi?id=1482466)
in Firefox 62.

The scalar (which was not affected by the same bug) was
[implemented](https://bugzilla.mozilla.org/show_bug.cgi?id=1376942) in
Firefox 56. The scalar is aggregated into `main_summary`, but should
always be identical to the `simpleMeasurement`.

### `subsession_length`

`subsession_length` is the wall-clock duration of a subsession.
`subsession_length` includes time that the computer was asleep for
Windows, but not for OS X or Linux; there is a [long-outstanding
bug](https://bugzilla.mozilla.org/show_bug.cgi?id=1205567) to include
sleep time on all platforms.

There is [another
bug](https://bugzilla.mozilla.org/show_bug.cgi?id=1205985) to count only
time that the computer is not in sleep.

`subsession_length` was first implemented with [the advent of
subsessions](https://mail.mozilla.org/pipermail/fhr-dev/2015-January/000384.html),
which came with unified telemetry.

### `total_uri_count`

`total_uri_count` was
[implemented](https://bugzilla.mozilla.org/show_bug.cgi?id=1271313) for
Firefox 50.

`total_uri_count` is intended to capture the number of distinct
navigation events a user performs. It includes changes to the URI
fragment (i.e. anchor navigation) on the page. It excludes
`XmlHttpRequest` fetches and `iframes`.

It works by attaching an instance of `URICountListener` as a
`TabsProgressListener` which responds to `onLocationChange` events.

Some filters are applied to `onLocationChange` events:

- Error pages are excluded.
- Only top-level pageloads (where `webProgress.isTopLevel`,
  [documented inline][total_uri_src], is true) are counted – i.e,
  not navigations within a frame.
- Tab restore events are excluded.
- URIs visited in private browsing mode are excluded unless
  `browser.engagement.total_uri_count.pbm` is true. (The pref has been
  flipped on for small populations in a couple of short studies, but,
  [for now][bug1535169] remains false by default.)

[total_uri_src]: https://searchfox.org/mozilla-central/rev/f1c7ba91fad60bfea184006f3728dd6ac48c8e56/uriloader/base/nsIWebProgress.idl#144
[bug1535169]: https://bugzilla.mozilla.org/show_bug.cgi?id=1535169

### `unfiltered_uri_count`

The unfiltered count,
[implemented](https://bugzilla.mozilla.org/show_bug.cgi?id=1304647) for
Firefox 51, differs only in that it includes URIs using protocol specs
other than HTTP and HTTPS. It excludes some (but not all) `about:` pages
– the set of “initial pages” defined in `browser.js` are excluded, but
e.g. `about:config` and `about:telemetry` are included.

No applications of `unfiltered_uri_count` have been identified.
