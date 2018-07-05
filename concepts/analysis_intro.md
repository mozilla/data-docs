Getting Started with Firefox Data
=================================

Firefox clients out in the wild send us data as *pings*. [Main pings](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/main-ping.html) contain some combination of *environment* data (e.g. operating system, hardware, Firefox version), *measurements* (e.g. max number of open tabs, time spent running in JavaScript garbage collection), and [*events*](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/collection/events.html). We have quite a few different pings, but most of our data for Firefox Desktop comes in from main pings.

Measurement Types
------

When we need to measure specific things about clients, we use probes. A single ping will send in many different probes. There are two types of probes that we are interested in here: *Histograms* and *Scalars*.

Histograms are bucketed counts. The [`Histograms.json`](https://github.com/mozilla/gecko-dev/blob/master/toolkit/components/telemetry/Histograms.json) file has the definitions for all histograms, which includes the minimum, maximum, and number of buckets. Any recorded value instead just increments its associated bucket. We have four main types of histograms:
1. Boolean - Only two buckets, associated with true and false.
2. Enumerated - Integer buckets, where usually each bucket has a label.
3. Linear - Buckets are divided evenly between the minimum and maximum; e.g. [1-2] is a bucket, and so is [100-101].
4. Exponential - Larger valued buckets cover a larger range; e.g. [1-2] is a bucket, and so is [100-200].

To see some of these in action, take a look at the [Histogram Simulator](https://telemetry.mozilla.org/histogram-simulator).

Scalars are simply a single value. The [`Scalars.yaml`](https://dxr.mozilla.org/mozilla-central/rev/tip/toolkit/components/telemetry/Scalars.yaml) file has the definitions for all scalars. These values can be integers, strings, or booleans.

TMO
---

The simplest way to start looking at probe data is to head over to [`telemetry.mozilla.org`][tmo] or [TMO][tmo] for short.

From there, you will likely want either [the Measurement Dashboard][measurement_dash] or [the Evolution Dashboard][evo_dash]. Using these dashboards you can compare a probe's value between populations, e.g. `GC_MS` for 64 bit vs. 32 bit, and even track it across builds.

The [Measurement Dashboard][measurement_dash] is a snapshot, aggregating all the data from all chosen dimensions. The Y axis is % of samples, and the X axis is the bucket. You can compare between dimensions, but it does not give you the ability to see how data is changing over time. To investigate that you must use the [Evolution Dashboard][evo_dash].

The [Evolution Dashboard][evo_dash] shows how the data changes over time. Choose which statistics you'd like to plot over time, e.g. Median or 95th percentile. The X axis is time, and the Y axis is the value for whichever statistic you've chosen. [This dashboard][evo_gc_ms], for example, shows how `GC_MS` is improving from nightly 53 to nightly 56! While the median is not changing much, the 95th percentile is trending down, indicating that long garbage collections are being shortened.

The X axis on the Evolution Dashboard shows either Build ID (a date), or Submission Date. The difference is that on any single date we might receive submissions from lots of builds, but aggregating by Build ID means we can be sure a change was because of a new build.

The second plot on the Evolution View is the number of pings we saw containing that probe (Metric Count).

### TMO Caveats
* Data is aggregated on a per-ping basis, meaning *these dashboards cannot be used to say something definitive about users*. Please repeat that to yourself. A trend in the evolution view may be caused not by a change affecting lots of users, but a change affecting _one_ single user who is now sending 50% of the pings we see. [And yes, that does happen.][problem_client]
* Sometimes it looks like no data is there, but you think there should be. Check under advanced settings and check "Don't Sanitize" and "Don't Trim Buckets". If it's still not there, let us know in IRC on #telemetry.
* TMO Measurement Dashboards do not currently show release-channel data. Release-channel data [ceased being aggregated](https://medium.com/georg-fritzsche/data-preference-changes-in-firefox-58-2d5df9c428b5) as of Firefox 58. We're looking into ways of doing this correctly in the near future.

Where to go next
----------------
* [Analysis using STMO](/tools/stmo.md)
* [Advanced analysis with ATMO](/tools/spark.md)
* [Experimental data](/tools/experiments.md)
* [Adding probes, collecting more data](https://developer.mozilla.org/en-US/docs/Mozilla/Performance/Adding_a_new_Telemetry_probe)
* [Augmenting the derived datasets](/datasets/derived.md)

[tmo]: https://telemetry.mozilla.org/
[measurement_dash]: https://telemetry.mozilla.org/new-pipeline/dist.html
[evo_dash]: https://telemetry.mozilla.org/new-pipeline/evo.html
[evo_gc_ms]: https://telemetry.mozilla.org/new-pipeline/evo.html#!aggregates=median!95th-percentile&cumulative=0&end_date=2017-06-13&keys=!__none__!__none__&max_channel_version=nightly%252F56&measure=GC_MS&min_channel_version=nightly%252F53&processType=*&product=Firefox&sanitize=1&sort_keys=submissions&start_date=2017-06-12&trim=1&use_submission_date=0
[problem_client]: http://reports.telemetry.mozilla.org/post/projects%2Fproblematic_client.kp
