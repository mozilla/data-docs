# Choosing a Desktop Product Dataset

This document will help you find the best data source for a given analysis. It focuses on _descriptive_ datasets and does not cover anything attempting to explain _why_ something is observed. This guide will help if you need to answer questions like:

- How many Firefox users are active in Germany?
- How many crashes occur each day?
- How many users have installed a specific add-on?

If you want to know whether a causal link occurs between two events, you can learn more at [tools for experimentation](../tools/experiments.md).

There are two types of datasets that you might want to use: those based on raw pings and those derived from them.

## Raw Ping Datasets

We receive data from Firefox users via **pings**: small JSON payloads sent by clients at specified intervals.
There are many types of pings, each containing different measurements and sent for different purposes.

These pings are then [aggregated into ping-level datasets](../cookbooks/bigquery/querying.md#structure-of-ping-tables-in-bigquery) that can be retrieved using BigQuery.
Pings can be difficult to work with and expensive to query: where possible, you should use a derived dataset to answer your question.

For more information on pings and how to use them, see [Raw Ping Data](../datasets/pings.md).

## Derived Datasets

Derived datasets are built using the raw ping data above with various transformations to make them easier to work with and help you avoid the pitfall of [pseudo-replication](https://docs.telemetry.mozilla.org/concepts/analysis_gotchas.html#pseudo-replication).
You can find a full list of them in the [derived datasets section](../datasets/derived.md), but two commonly used ones are "Clients Daily" and "Clients Last Seen".

### Clients Daily

{{#include ../datasets/batch_view/clients_daily/intro.md}}

See the [`clients_daily` reference](../datasets/batch_view/clients_daily/reference.md) for more information.

### Clients Last Seen

{{#include ../datasets/bigquery/clients_last_seen/intro.md}}

See the [`clients_last_seen` reference](../datasets/bigquery/clients_last_seen/reference.md) for more information.
