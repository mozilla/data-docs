# Tools for Data Analysis

This is a starting point for making sense of the tools used for analyzing Mozilla data. There are different tools available, each with their own strengths, tailored to a variety of use cases and skill sets.

<!-- toc -->

## High-level tools

These web-based tools do not require specialized technical knowledge (e.g. how to write an SQL query, deep knowledge of BigQuery). This is where you should start.

### Mozilla Growth & Usage Dashboard (GUD)

The [Mozilla Growth & Usage Dashboard](https://gud.telemetry.mozilla.org/) (GUD) is a tool to visualize growth metrics in a standard way across Mozilla’s products. This is the first place you should look if you have a question like "how many people are using X?".

### Glean Aggregated Metrics Dashboard (GLAM)

The [Glean Aggregated Metrics Dashboard](https://glam.telemetry.mozilla.org/) (GLAM) is an interactive dashboard that is Mozilla’s primary self-service tool for examining the distributions of values of specific individual telemetry metrics, over time and across different user populations.

As of this writing, GLAM is in active development but is already usable.

### Telemetry Measurement Dashboard

The [Telemetry Measurement Dashboard](https://telemetry.mozilla.org/new-pipeline/dist.html) (TMO) site is the
'venerable standby' of Firefox telemetry analysis tools. It is the predecessor to GLAM (see above) and is still maintained until GLAM is considered production ready.

## Lower-level tools

These tools require more specialized knowledge to use.

### sql.telemetry.mozilla.org (STMO)

The [`sql.telemetry.mozilla.org`](https://sql.telemetry.mozilla.org) (STMO) site
is an instance of the very fine [Redash](https://redash.io/) software, allowing
for SQL-based exploratory analysis and visualization / dashboard
construction. Requires (surprise!) familiarity with SQL, and for your data to
be explicitly exposed as an STMO data source. You can learn more about how to use it in [Introduction to STMO](./stmo.md). Bugs or feature requests can be reported in Mozilla's [issue tracker](https://github.com/mozilla/redash/issues).
