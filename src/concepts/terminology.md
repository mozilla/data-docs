# Terminology

## Table of Contents

This glossary provides definitions for some common terms used in the Mozilla data universe.
If you're new to Mozilla, you may also find the [general glossary](https://wiki.mozilla.org/Glossary) on `wiki.mozilla.org` helpful.

<!-- toc -->

## AET

Account Ecosystem Telemetry (never fully launched); see the [PRD](https://docs.google.com/document/d/1yRLiD8JuaZIIaKhs6DhXEa7aH8jwOau5yW0kHaldFQU/edit#)

## Analyst

See [Data Analyst](#data-analyst).

## Amplitude

A third-party product formerly used by several teams within Mozilla for analysis of user events.

## BigQuery

[BigQuery](https://cloud.google.com/bigquery) is Google Cloud's managed data warehouse. Most of the data described on this site is stored and queried using BigQuery. See [Accessing and working with BigQuery](../cookbooks/bigquery.md) for more details.

## Build ID

A unique identifier for a build like `20210317095331`.
Often used to identify and aggregate telemetry submitted by specific versions of our software.
Note that [the format may differ across product lines](./analysis_gotchas.md#build-ids).

## Client ID

A unique id identifying the client who sent a [ping](#ping).

## Data Analyst

This is a common job title for someone who spends a large amount of their time analyzing data. At Mozilla, we tend not to use this term or title, favoring [Data Practitioner](#data-practitioner) or [Data Scientist](#data-scientist) instead.

## Data Engineer

A "Data Engineer" at Mozilla generally refers to someone on the Data Engineering team. They implement and maintain the data platform and tools described in this document. They may also assist data scientists or other data practitioners, as needed.

## Data Practitioner

A data practitioner is someone who looks at data, identifies trends and other qualitative measurements in them, and creates charts and dashboards. It could be anyone: engineer, product manager, data engineer or data scientist.

## Data Scientist

A "Data Scientist" at Mozilla generally refers to someone on the Data Science team. They have a broad array of technical backgrounds and a core set of common professional skills:

- applying statistical methods to noisy data to answer questions about what, how, or why something is happening
- transform unstructured data into usable metrics and models
- augmenting strategic product and decision-making with empirical evidence created and curated by the team

## Dataset

A set of data, which includes ping data, derived datasets, etc.; sometimes it is used synonymously with “table”; sometimes it is used technically to refer to a [BigQuery](#bigquery) dataset, which represents a container for one or more tables.

## DAU

Daily Active Users - The number of unique [client ids](#client-id) that we receive a [ping](#ping) from each day.

DAU can be defined differently across different products. For example, [Firefox Desktop DAU](https://mozilla.github.io/metric-hub/metrics/firefox_desktop/#daily_active_users) only considers client ids to be "active" on days we receive a main ping if the client visits at least one [URI](#uri) and has a non-zero number of [active hours](https://mozilla.github.io/metric-hub/metrics/firefox_desktop/#active_hours). Mobile DAU, on the other hand, considers any client to be "active" on days that we receive a baseline ping from them.

DAU is used to calculate one of Mozilla's [KPIs](#kpi). The KPI version of DAU is defined as "the 28-day average DAU over the period ending on December 15th each year". The Firefox Desktop DAU KPI definition is maintained [here](https://mozilla.github.io/metric-hub/metrics/firefox_desktop/#desktop_dau_kpi).

## Derived Dataset

A processed dataset, such as [Clients Daily](../datasets/batch_view/clients_daily/reference.md). At Mozilla, this is in contrast to a raw ping table which represents (more or less) the raw data submitted by our users.

## Glean

Glean is Mozilla’s product analytics & telemetry solution that provides a consistent experience and behavior across all of our products. Most of Mozilla's mobile apps, including Fenix, have been adapted to use the Glean SDK. For more information, see the [Glean Overview](./glean/glean.md).

## GCP

Google Cloud Platform (GCP) is a suite of cloud-computing services that runs on the same infrastructure that Google uses internally for its end-user products.

## GeoIP

IP Geolocation involves attempting to discover the location of an IP address in the real world. IP addresses are assigned to an organization, and as these are ever-changing associations, it can be difficult to determine exactly where in the world an IP address is located. Mozilla’s ingestion infrastructure attempts to perform GeoIP lookup during the data decoding process and subsequently discards the IP address before the message arrives in long-term storage.

## Ingestion

Mozilla's core data platform has been built to support structured ingestion of arbitrary JSON payloads whether they come from browser products on client devices or from server-side applications that have nothing to do with Firefox; any team at Mozilla can hook into structured ingestion by defining a schema and registering it with pipeline. Once a schema is registered, everything else is automatically provisioned, from an HTTPS endpoint for accepting payloads to a set of tables in BigQuery for holding the processed data.

## Intensity

Intuitively, how many days per week do users use the product? Among profiles active at least once in the week ending on the date specified, the number of days on average they were active during that one-week window.

## KPI

Key Performance Indicator - a [metric](#metric) that is used to measure performance across an organization, product, or project.

## Metric

In general: a metric is anything that you want to (and can) measure. This differs from a dimension which is a qualitative attribute of data.

In the context of [Glean](#glean), a metric refers to an instrumented measure for a specific aspect of the product (similar to a [probe](#probe) in Firefox Telemetry).

## MAU

Monthly Active Users - the number of unique profiles active in the 28-day period ending on a given day. The number of unique profiles active at least once during the 28-day window
ending on the specified day.

## Ping

A ping represents a message that is sent from the Firefox browser to Mozilla’s Telemetry servers. It typically includes information about the browser’s state, user actions, etc.
For more information, see [Common ping format](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/common-ping.html).

## Ping Table

A set of pings that is stored in a BigQuery table. See article on [raw ping datasets](../datasets/pings.md).

## Pipeline

Mozilla’s data pipeline, which is used to collect Telemetry data from Mozilla’s products and logs from various services.
The bulk of the data that is handled by this pipeline is Firefox Telemetry data. The same tool-chain is used to collect, store, and analyze data that comes from many sources.

For more information, see [An overview of Mozilla’s Data Pipeline](./pipeline/gcp_data_pipeline.md).

## Probe

Measurements for a specific aspect of Firefox are called probes. A single telemetry ping sends many different probes. Probes are either Histograms (recording distributions of data points) or Scalars (recording a single value).

You can search for details about probes by using the [Probe Dictionary](https://probes.telemetry.mozilla.org/). For each probe, the probe dictionary provides:

- A description of the probe
- When a probe started being collected
- Whether data from this probe is collected in the release channel

Newer measurements implemented using [Glean](#glean) are referred to as [metrics](#metrics) instead of probes, but the basic outline is the same. Details about Glean Metrics are collected inside the [Glean Dictionary](https://dictionary.telemetry.mozilla.org).

## Profile

All of the changes a user makes in Firefox, like the home page, what toolbars you use, installed addons, saved passwords and your bookmarks, are all stored in a special folder, called a profile. Telemetry stores archived and pending pings in the profile directory as well as metadata like the [client id](#client-id). See also [Profile Creation](./profile/profile_creation.md).

## Query

Typically refers to a query written in the SQL syntax, run on (for example) [STMO](#stmo).

## Retention

- As in “Data retention” - how long data is stored before it is automatically deleted/archived?

- As in “User retention” - how likely is a user to continue using a product?

## Schema

A schema is the organization or structure for our data. We use schemas at many levels (in data ingestion and storage) to make sure the data we submit is valid and possible to be processed efficiently.

## Session

The period of time that it takes between Firefox being started until it is shut down. See also [subsession](#subsession).

## Subsession

In Firefox, [Sessions](#sessions) are split into subsessions after every 24-hour time period has passed or the environment has changed. See [here for more details](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/concepts/sessions.html?highlight=subsession).

## STMO (sql.telemetry.mozilla.org)

A service for creating queries and dashboards. See [STMO under analysis tools](../introduction/tools.md#sqltelemetrymozillaorg-stmo).

## Telemetry

As you use Firefox, Telemetry measures and collects non-personal information, such as performance, hardware, usage and customizations. It then sends this information to Mozilla on a daily basis and we use it to improve Firefox.

## URI

Uniform Resource Identifier - a string that refers to a resource. The most common are [URLs](#url), which identify the resource by giving its location on the Web ([source](https://developer.mozilla.org/en-US/docs/Glossary/URI)).

## URL

Uniform Resource Locator - a text string that specifies where a resource (such as a web page, image, or video) can be found on the Internet ([source](https://developer.mozilla.org/en-US/docs/Glossary/URL)). For example, `https://www.mozilla.org` is a URL.

## WAU

Weekly Active Users - The number of unique profiles active at least once during the 7-day window
ending on the specified day.
