# Get Started with Firefox Desktop Data

The following topics describe Firefox Desktop Telemetry data that has been captured for many years. The modern data collection is based on the [Glean platform](glean/glean.md).
Older mobile product data used different platforms, that are described
in [Choosing a Mobile Dataset](choosing_a_dataset_mobile.md).

Firefox clients send data as _pings_. [`Main` pings][main_ping] include some combination of _environment_ data (e.g., information about operating system, hardware, and Firefox versions), [_measurements_][probe_dict]
(e.g., information about the maximum number of open tabs and time spent running in JavaScript garbage collections),
and [_events_][events] (be aware that desktop events have largely been migrated
to a separate `event` ping).

Most of the data for Firefox Desktop data is received from `main` pings.

## Measurement Types

Measurements for a specific aspect of a product are called _probes_. A single telemetry ping sends many different probes. Probes are either _Histograms_ (recording distributions of data points) or _Scalars_ (recording a single value).

You can search for details about probes by using the [Probe Dictionary][probe_dict]. For each probe, the probe dictionary will give you:

- A description of the probe
- When a probe started being collected
- Whether data from this probe is collected in the release channel

Histograms are represented as bucketed counts. The [`Histograms.json`][histograms] file includes definitions for all histograms. The definitions include information about the minimum, maximum, and number of buckets. Any recorded value instead just increments its associated bucket.

The following main types of histograms are available:

- Boolean - Only two buckets, associated with true and false
- Enumerated - Integer buckets, where usually each bucket has a label
- Linear - Buckets are divided evenly between the minimum and maximum
  e.g., [1-2] is a bucket and so is [100-101]
- Exponential - Larger valued buckets cover a larger range
  e.g., [1-2] is a bucket, and so is [100-200]

You can visualize how some of these types of histograms work using [Histogram Simulator].

Scalars are represented as a single value.
The [`Scalars.yaml`][scalars] file includes definitions for all scalars.
These values can be integers, strings, or booleans.

## `telemetry.mozilla.org`

If you want to view probe data, go to [`telemetry.mozilla.org`][tmo] ([TMO][tmo]). You can then choose either the [Measurement Dashboard][measurement_dash]
or the [Evolution Dashboard][evo_dash]. You can then compare a probe's value between populations (e.g., `GC_MS` for 64 bit vs. 32 bit) and even track it across builds.

The [Measurement Dashboard][measurement_dash] represents a snapshot that shows how data is aggregated from all chosen dimensions. The Y axis represents the percentage (%) of samples while the X axis represents a bucket. Although you can use the Measurement Dashboard to compare between dimensions, you cannot view how data changes data over time. If you want to investigate this issue further, you must use the [Evolution Dashboard][evo_dash].

The [Evolution Dashboard][evo_dash] shows how data changes over time. You can choose the statistics that you want to plot over time, e.g., Median or 95th percentile.
The X axis represents time and the Y axis represents the value for the statistics that you have chosen. As an example, this [dashboard][evo_gc_ms] shows how `GC_MS` improves from
nightly 53 to nightly 56! While the median does not change much, the 95th percentile trends down to indicate that long garbage collections are being shortened.

The X axis on the Evolution Dashboard shows either a Build ID (a date) or a Submission Date. Although submissions may be received from many builds on any single date, aggregating data by Build ID indicates that a change occurred because a new build was created.

The second plot on the Evolution View represents the number of pings that are included in a
probe (Metric Count).

### Caveats

- Data is aggregated on a _per-ping_ basis, which indicates that you _cannot use these dashboards to say anything definitive about users_.
  Please repeat that to yourself.
  A trend in the evolution view may be caused not by a change affecting lots of
  users, but a change affecting _one_ single user who is now sending 50% of
  the pings we see.
  [And yes, it has occurred.][problem_client]
- Sometimes it looks like no data is present even though you think there it should appear.
  Check under advanced settings and "Don't Sanitize" and "Don't Trim Buckets".
  If you are still unable to locate the data, see [getting help](getting_help.md).
- TMO Measurement Dashboards do not currently show release-channel data.
  Release-channel data [ceased being aggregated][prefs] as of Firefox 58.
  This issue is being evaluated at this time and is under consideration for getting corrected in the near future.

## Where to go next

Read through [Analysis Interfaces](../tools/interfaces.md) for more information on tools available for analysis and then work through the rest of the material in this section.

[main_ping]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/main-ping.html
[probe_dict]: https://probes.telemetry.mozilla.org/
[events]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/collection/events.html
[histograms]: https://github.com/mozilla/gecko-dev/blob/master/toolkit/components/telemetry/Histograms.json
[scalars]: https://searchfox.org/mozilla-central/source/toolkit/components/telemetry/Scalars.yaml
[tmo]: https://telemetry.mozilla.org/
[measurement_dash]: https://telemetry.mozilla.org/new-pipeline/dist.html
[evo_dash]: https://telemetry.mozilla.org/new-pipeline/evo.html
[evo_gc_ms]: https://telemetry.mozilla.org/new-pipeline/evo.html#!aggregates=median!95th-percentile&cumulative=0&end_date=2017-06-13&keys=!__none__!__none__&max_channel_version=nightly%252F56&measure=GC_MS&min_channel_version=nightly%252F53&processType=*&product=Firefox&sanitize=1&sort_keys=submissions&start_date=2017-06-12&trim=1&use_submission_date=0
[problem_client]: https://mozilla.report/post/projects%2Fproblematic_client.kp
[histogram simulator]: https://telemetry.mozilla.org/histogram-simulator
[prefs]: https://medium.com/georg-fritzsche/data-preference-changes-in-firefox-58-2d5df9c428b5
[add_probes]: https://developer.mozilla.org/en-US/docs/Mozilla/Performance/Adding_a_new_Telemetry_probe
