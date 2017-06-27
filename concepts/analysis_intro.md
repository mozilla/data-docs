This article is under development.
The work is being tracked in
[this bug](https://bugzilla.mozilla.org/show_bug.cgi?id=1341706).

=======
= Work in Progress

This article is under development.
The work is being tracked in
link:https://bugzilla.mozilla.org/show_bug.cgi?id=1341706[this bug].

= Getting Started with Firefox Data
// Introduces:
//   * Pings

Firefox clients out in the wild send us data as *pings*. Most of our pings contain some combination of *environment* data (e.g. operating system, hardware, Firefox version) and *probe* data (e.g. max number of open tabs, time spent running in Javascript garbage collection). We have quite a few different pings, but most of our data for Firefox Desktop comes in from link:http://gecko.readthedocs.io/en/latest/toolkit/components/telemetry/telemetry/data/main-ping.html[Main pings].

== Probes
// Introduces:
//   * Histograms
//   * Scalars

When we need to measure specific things about clients, we use probes. A single ping will send in many different probes. There are two types of probes: *Histograms* and *Scalars*.

Histograms are bucketed counts. The link:https://github.com/mozilla/gecko-dev/blob/master/toolkit/components/telemetry/Histograms.json[Histograms.json] file has the definitions for all histograms, which includes the minimum, maximum, and number of buckets. Any recorded value instead just increments it's associated bucket. We have four main types of histograms:
1. Linear - Buckets are divided evenly between the minimum and maximum; e.g. [1-2] is a bucket, and so is [100-101].
2. Boolean - Only two buckets, associated with true and false.
3. Enumerated - Integer buckets, where usually each bucket has a label.
4. Exponential - Larger valued buckets cover a larger range; e.g. [1-2] is a bucket, and so is [100-200].

To see some of these in action, take a look at the link:https://telemetry.mozilla.org/histogram-simulator[Histogram Simulator].

Scalars are simply a single value. The link:https://dxr.mozilla.org/mozilla-central/rev/tip/toolkit/components/telemetry/Scalars.yaml[Scalars.yaml] file has the definitions for all scalars. These values can be integers, strings, or booleans.

== TMO
The simplest way to start looking at probe data is in link:https://telemetry.mozilla.org/new-pipeline/dist.html[the Measurement Dashboard] or link:https://telemetry.mozilla.org/new-pipeline/evo.html[the Distribution Dashboard]. Using these dashboards you can compare a probes value between populations, e.g. GC_MS for 64 bit vs. 32 bit, and even track it across builds.

The Measurement Dashboard is a snapshot, aggregating all the data from all chosen dimensions. The Y axis is % of samples, and the X axis is the bucket. You can compare between dimensions, but it does not give you the ability to see how data is changing over time. To investigate that you must use the Evolution Dashboard.

The Evolution Dashboard shows how the data changes over time. Choose which statistics you'd like to plot over time, e.g. Median or 95th percentile. The Y axis is time, and the X axis is the value for whichever statistic you've chosen. link:https://telemetry.mozilla.org/new-pipeline/evo.html#!aggregates=median!95th-percentile&cumulative=0&end_date=2017-06-13&keys=!__none__!__none__&max_channel_version=nightly%252F56&measure=GC_MS&min_channel_version=nightly%252F53&processType=*&product=Firefox&sanitize=1&sort_keys=submissions&start_date=2017-06-12&trim=1&use_submission_date=0[This dashboard], for example, shows how GC_MS is improving from nightly 53 to nightly 56! While the median is not changing much, the 95th percentile is trending down, indicating that long garbage collections are being shortened.

The X axis on the Evolution Dashboard shows either Build ID (a date), or Submission Date. The difference is that on any single date we might recieve submissions from lots of builds, but aggregating by Build ID means we can be sure a change was because of a new build.

The second plot on the Evolution View is the number of pings we saw containing that probe (Metric Count).

=== TMO Caveats
* Data is aggregated on a per-ping basis, meaning *these dashboards cannot be used to say something definitive about users*. Please repeat that to yourself. A trend in the evolution view may be caused not by a change affecting lots of users, but a change affecting one user who is now sending 50% of the pings we see. link:http://reports.telemetry.mozilla.org/post/projects%2Fproblematic_client.kp[And yes, that does happen.]
* Sometimes it looks like no data is there, but you think there should be. Check under advanced settings and check "Don't Sanitize" and "Don't Trim Buckets". If it's still not there, let us know in IRC on #telemetry.

== Where to go next
* Analysis using STMO
* Advanced analysis with ATMO
* Experimental data
* Adding probes, collecting more data
* Augmenting the derived datasets
