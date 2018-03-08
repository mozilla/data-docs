Telemetry Alerts
================

Many Telemetry probes were created to show performance trends over time.
Sudden changes happening in Nightly could be the sign of an
unintentional performance regression, so we introduced a system to
automatically detect and alert developers about such changes.

Thus we created Telemetry Alerts. It comes in two pieces:
[Cerberus](https://github.com/mozilla/cerberus/) the Detector and
[Medusa](https://github.com/mozilla/medusa/) the Front-end.

### Cerberus

Every day Cerberus grabs the latest aggregated information about all
non-keyed Telemetry probes from `aggregates.telemetry.mozilla.org` and
compares the distribution of values from the **Nightly** builds of the
past two days to the distribution of values from the Nightly builds of
the past seven days.

It does this by calculating the [Bhattacharyya
distance](https://en.wikipedia.org/wiki/Bhattacharyya_distance) between
the two distributions and guessing whether or not they are [significant
and
narrow](https://github.com/mozilla/cerberus/blob/master/alert/alert.py#L72).

It places all detected changes in a file for ingestion by Medusa.

### Medusa

Medusa is in charge of emailing people when distributions change and for
displaying the website <https://alerts.telemetry.mozilla.org> which
contains pertinent information about each detected regression.

Medusa also checks for expiring histograms and sends emails notifying of
their expiry.

What it can do
--------------

Telemetry Alerts is very good at identifying sudden changes in the
shapes of normalized distributions of Telemetry probes. If you can see
the distribution of [`GC_MS`](https://mzl.la/2vdMRax) shift from one day
to the next, then likely so can Cerberus.

What can't it do
----------------

Telemetry Alerts is not able to see sudden shifts in volume. It is also
very easily fooled if a change happens over a long period of time or
doesn't fundamentally alter the shape of the probe's histogram.

So if you have a probe like
[`SCALARS_BROWSER.ENGAGEMENT.MAX_CONCURRENT_TAB_COUNT`](https://mzl.la/2vdiuRx),
Cerberus won't notice if:

-   The number of pings reporting this value decreased in half, but
    otherwise reported the same spread of numbers
-   The value increases very slowly over time (which I'd expect it to do
    given how good Session Restore is these days)
-   We suddenly received twice as many pings from 200-tab subsessions
    (the dominance of 1-tab pings would likely ensure the overall shape
    of the distribution changed insufficiently much for Cerberus to pick
    up on it)

Telemetry Alert Emails
----------------------

One of the main ways humans interact with Telemetry Alerts is through
the emails sent by Medusa.

At present the email contains a link to the alert's page on
<https://alerts.telemetry.mozilla.org> and a link to a pushlog on
<https://hg.mozilla.org> detailing the changes newly-present in the
Nightly build that exhibited the change.

Triaging a Telemetry Alert Email
--------------------------------

Congratulations! You have just received a Telemetry Alert!

Now what?

**Assumption:** Alerts happen because of changes in probes. Changes in
probes happen because of changes in related code. If we can identify the
code change, we can find the bug that introduced the code change. If we
can find the bug, we can ni? the person who made the change.

**Goal:** Identify the human responsible for the Alert so they can
identify if it is
good/bad/intentional/exceptional/temporary/permanent/still
relevant/having its alerts properly looked after.

**Guide:**

1\. Is this alert just one of a group of similar changes by topic? By
build?

-   If there's a group by topic (`SPDY`, `URLCLASSIFIER`, ...) check to see
    if the changes are similar in direction/magnitude. They usually are.
-   If there's a group by build but not topic, maybe a large merge
    kicked things over. Unfortunate, as that'll make finding the source
    more difficult.

2\. Open the `hg.mozilla.org` and `alerts.telemetry.mozilla.org` links in
tabs

-   On `alerts.tmo`, does it look like an improvement or regression? (This
    is just a first idea and might change. There are often extenuating
    circumstances that make something that looks bad into an
    improvement, and vice versa.)
-   On `hg.mo`, does the topic of the changed probe exist in the pushlog?
    In other words, does any part of the probe's name show up in the
    summaries of any of the commits?

3\. From `alerts.tmo`, open the <https://telemetry.mozilla.org> link by
clicking on the plot's title. Open another tab to the Evolution View.

-   Is the change temporary? (might've been noticed elsewhere and
    backed out)
-   Is the change up or down?
-   Has it happened before?
-   Was it accompanied by a decrease in submission volume? (the second
    graph at the bottom of the Evolution View)
-   On the Distribution View, did the Sample Count increase? Decrease?
    (this signifies that the change could be because of the addition or
    subtraction of a population of values. For instance, we could
    suddenly stop sending 0 values which would shift the graph to
    the right. This could be a good thing (we're not handling useless
    things any longer) a bad thing (something broke and we're no longer
    measuring the same thing we used to measure) or indifferent)

4\. If you still don't have a cause

-   Use DXR or searchfox to find where the probe is accumulated.
-   Click "Log" in that view.
-   Are there any changesets in the resultant `hg.mo` list that ended up
    in the build we received the Alert for?

5\. If you _still_ don't know what's going on

-   find a domain expert on IRC and bother them to help you out. Domain
    knowledge is awesome.

From pursuing these steps or sub-steps you should now have two things: a
bug that likely caused the alert, and an idea of what the alert is
about.

Now comment on the bug. Feel free to use this script:
```text
This bug may have contributed to a sudden change in the Telemetry probe <PROBE_NAME>[1] which seems to have occurred in Nightly <builddate>[2][3].

There was a <describe the change: increase/decrease, population addition/subtraction, regression/improvement, change in submission/sample volume...>.
This might mean <wild speculation. It'll encourage the ni? to refute it :) >

Is this an improvement? A regression?

Is this intentional? Is this expected?

Is this probe still measuring something useful?

[1]: <the alerts.tmo link>
[2]: <the hg.mo link for the pushlog>
[3]: <the telemetry.mozilla.org link showing the Evolution View>
```

Then ni? the person who pushed the change. Reply-all to the
dev-telemetry-alerts mail with a link to the bug and some short notes on
what you found.

From here the user on ni? should get back to you in fairly short order
and either help you find the real bug that caused it, or help explain
what the Alert was all about. More often than not it is an expected
change from a probe that is still operating correctly and there is no
action to take...

...except making sure you never have to respond to an Alert for this
probe again, that is. File a bug in that bug's component to update the
Alerting probe to have a valid, monitored `alert_emails` field so that
the next time it misbehaves *they* can be the ones to explain themselves
without you having to spend all this time tracking them down.
