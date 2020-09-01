# Choosing a Desktop Product Dataset

This document will help you find the best data source for a given analysis. It focuses on _descriptive_ datasets and does not cover anything attempting to explain _why_ something is observed. This guide will help if you need to answer questions like:

- How many Firefox users are active in Germany?
- How many crashes occur each day?
- How many users have installed a specific add-on?

If you want to know whether a causal link occurs between two events, you can learn more at [tools for experimentation](../tools/experiments.md).

## Table of Contents

<!-- toc -->

## Raw Pings

{{#include ../datasets/ping_intro.md}}

## Main Ping Derived Datasets

The [main ping] includes most of the measurements that track the performance and health of Firefox in the wild. This ping includes histograms, scalars, and events.

In its raw form, the main ping can be a bit difficult to work with. To make analyzing data easier, some datasets have been provided that simplify and aggregate information provided by the main ping.

### Clients Daily

{{#include ../datasets/batch_view/clients_daily/intro.md}}

See the [`clients_daily` reference](../datasets/batch_view/clients_daily/reference.md) for more information.

### Clients Last Seen

{{#include ../datasets/bigquery/clients_last_seen/intro.md}}

See the [`clients_last_seen` reference](../datasets/bigquery/clients_last_seen/reference.md) for more information.

[main ping]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/main-ping.html
