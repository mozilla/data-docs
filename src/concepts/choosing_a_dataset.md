# Choosing a Desktop Product Dataset

This document will help you find the best data source for a given analysis.

This guide focuses on descriptive datasets and does not cover experimentation.
For example, this guide will help if you need to answer questions like:

- How many users do we have in Germany, how many crashes we see per day?
- How many users have a given addon installed?

If you're interested in figuring out whether there's a causal link between two events
take a look at our [tools for experimentation](../tools/experiments.md).

## Table of Contents

<!-- toc -->

# Raw Pings

{{#include ../datasets/ping_intro.md}}

# Main Ping Derived Datasets

The [main ping](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/main-ping.html)
contains most of the measurements used to track performance and health of Firefox in the wild.
This ping includes histograms, scalars, and events.

This section describes the derived datasets we provide to make analyzing this data easier.

## `longitudinal`

{{#include ../datasets/batch_view/longitudinal/intro.md}}

## `main_summary`

{{#include ../datasets/batch_view/main_summary/intro.md}}

## `first_shutdown_summary`

{{#include ../datasets/batch_view/first_shutdown_summary/intro.md}}

## `client_count_daily`

{{#include ../datasets/obsolete/client_count_daily/intro.md}}

## `clients_last_seen`

{{#include ../datasets/bigquery/clients_last_seen/intro.md}}

## `clients_daily`

{{#include ../datasets/batch_view/clients_daily/intro.md}}

# Crash Ping Derived Datasets

The [crash ping](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/crash-ping.html)
is captured after the main Firefox process crashes or after a content process crashes,
whether or not the crash report is submitted to `crash-stats.mozilla.org`.
It includes non-identifying metadata about the crash.

This section describes the derived datasets we provide to make analyzing this data easier.

## `error_aggregates`

{{#include ../datasets/streaming/error_aggregates/intro.md}}

# New-Profile Derived Datasets

The [new-profile ping](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/new-profile-ping.html)
is sent from Firefox Desktop on the first session of a newly created profile and contains the initial
information about the user environment.

This data is available in the `telemetry_new_profile_parquet` dataset.

{{#include ../datasets/batch_view/new_profile/intro.md}}

# Update Derived Dataset

{{#include ../datasets/batch_view/update/intro.md}}

# Other Datasets

{{#include ../datasets/other/socorro_crash/intro.md}}

# Obsolete Datasets

## `heavy_users`

{{#include ../datasets/obsolete/heavy_users/intro.md}}

## `retention`

{{#include ../datasets/obsolete/retention/intro.md}}

## `churn`

{{#include ../datasets/obsolete/churn/intro.md}}

# Appendix

## Mobile Metrics

There are several tables owned by the mobile team documented
[here](https://wiki.mozilla.org/Mobile/Metrics/Redash):

* `android_addons`
* `mobile_clients`
