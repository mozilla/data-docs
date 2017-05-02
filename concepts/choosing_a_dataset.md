# Choosing a Dataset

This document will help you find the best data source for a given analysis.

This guide focuses on descriptive datasets and does not cover experimentation.
For example, this guide will help if you need to answer questions like:
how many users do we have in Germany, how many crashes we see per day,
or how many users have a given addon installed.
If you're interested in figuring out whether there's a causal link between two events
take a look at our [tools for experimentation](/tools/experiments.md).

## Table of Contents
<!-- toc -->

# Raw Pings

We receive data from our users via **pings**.
There are several types of pings,
each containing different measurements and sent for different purposes.
To review a complete list of ping types and their schemata, see 
[this section of the Mozilla Source Tree Docs](http://gecko.readthedocs.io/en/latest/toolkit/components/telemetry/telemetry/data/index.html).

#### Background and Caveats

The large majority of analyses can be completed using only the
[main ping](http://gecko.readthedocs.io/en/latest/toolkit/components/telemetry/telemetry/data/main-ping.html).
This ping includes histograms, scalars, and other performance and diagnostic data.

Few analyses actually rely directly on the raw ping data.
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

You can access raw ping data from an 
[ATMO cluster](https://analysis.telemetry.mozilla.org/) using the 
[Dataset API](http://python-moztelemetry.readthedocs.io/en/stable/userguide.html#module-moztelemetry.dataset).
Raw ping data are not available in [re:dash](https://sql.telemetry.mozilla.org/).

#### Further Reading

You can find [the complete ping documentation](http://gecko.readthedocs.io/en/latest/toolkit/components/telemetry/telemetry/data/index.html).
To augment our data collection, see
[Collecting New Data](https://developer.mozilla.org/en-US/docs/Mozilla/Performance/Adding_a_new_Telemetry_probe)

# Main Ping Derived Datasets

The [main ping](http://gecko.readthedocs.io/en/latest/toolkit/components/telemetry/telemetry/data/main-ping.html)
contains most of the measurements used to track performance and health of Firefox in the wild.
This ping includes histograms and scalars.

This section describes the derived datasets we provide to make analyzing this data easier.

## longitudinal

{% include "/datasets/batch_view/longitudinal/intro.md" %}

## main_summary

{% include "/datasets/batch_view/main_summary/intro.md" %}

## cross_sectional

{% include "/datasets/batch_view/cross_sectional/intro.md" %}

## client_count

{% include "/datasets/batch_view/client_count/intro.md" %}

# Crash Ping Derived Datasets

The [crash ping](http://gecko.readthedocs.io/en/latest/toolkit/components/telemetry/telemetry/data/crash-ping.html)
is captured after the main Firefox process crashes or after a content process crashes,
whether or not the crash report is submitted to crash-stats.mozilla.org.
It includes non-identifying metadata about the crash.

This section describes the derived datasets we provide to make analyzing this data easier.

## crash_aggregates

{% include "/datasets/batch_view/crash_aggregates/intro.md" %}

# Appendix

## Mobile Metrics

There are several tables owned by the mobile team documented
[here](https://wiki.mozilla.org/Mobile/Metrics/Redash): 

* android_events
* android_clients
* android_addons
* mobile_clients

