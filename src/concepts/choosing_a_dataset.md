# Choosing a Desktop Product Dataset

This document will help you find the best data source for a given analysis. It focuses on *descriptive* datasets and does not cover anything attempting to explain *why* something is observed. This guide will help if you need to answer questions like:

- How many Firefox users are active in Germany?
- How many crashes occur each day?
- How many users have installed a specific add-on?

If you want to know whether a causal link occurs between two events, you can learn more at [tools for experimentation](../tools/experiments.md).

## Table of Contents

<!-- toc -->

# Raw Pings

{{#include ../datasets/ping_intro.md}}

# Main Ping Derived Datasets

The [main ping] includes most of the measurements that track the performance and health of Firefox in the wild. This ping includes histograms, scalars, and events.

In its raw form, the main ping can be a bit difficult to work with. To make analyzing data easier, some datasets have been provided that simplify and aggregate information provided by the main ping.

## `clients_daily`

{{#include ../datasets/batch_view/clients_daily/intro.md}}

## `clients_last_seen`

{{#include ../datasets/bigquery/clients_last_seen/intro.md}}

## `main_summary`

{{#include ../datasets/batch_view/main_summary/intro.md}}

## `first_shutdown_summary`

{{#include ../datasets/batch_view/first_shutdown_summary/intro.md}}

## `client_count_daily`

{{#include ../datasets/obsolete/client_count_daily/intro.md}}

# Other Datasets

{{#include ../datasets/other/socorro_crash/intro.md}}

[main ping]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/main-ping.html
[crash ping]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/crash-ping.html
