# Raw Ping Data

<!-- toc -->

# Introduction

{{#include ./ping_intro.md}}

# Data Reference

You can find the reference documentation for all Firefox Telemetry ping types
[here](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/concepts/pings.html).

The [Glean](../concepts/glean/glean.md) article describes ping types sent by that SDK.

# Ping Metadata

The data pipeline appends metadata to arriving pings containing
information about the ingestion environment including timestamps,
Geo-IP data about the client,
and fields extracted from the ping or client headers that are useful for downstream processing.

These fields are available in BigQuery ping tables inside the `metadata` struct, described in detail
in [the "Ingestion Metadata" section of this article](../cookbooks/new_ping.md).

Since the metadata are not present in the ping as it is sent by the client,
these fields are documented here, instead of in the source tree docs.

As of September 28, 2018, members of the `meta` key on main pings include:

<!-- table generated via `scripts/new_ping_metadata_table.py > src/cookbooks/new_ping_metadata_table.md` -->

{{#include ../cookbooks/new_ping_metadata_table.md}}
