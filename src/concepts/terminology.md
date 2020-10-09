# Terminology

## Table of Contents

This glossary provides definitions for commonly-used terms at Mozilla.

<!-- TOC -->

- [Terminology](#terminology)
    - [Table of Contents](#table-of-contents)
    - [AET](#aet)
    - [Analyst](#analyst)
    - [Amplitude](#amplitude)
    - [BigQuery](#bigquery)
    - [Client ID](#client-id)
    - [Data Analyst](#data-analyst)
    - [Data Practioner](#data-practioner)
    - [Data Scientist](#data-scientist)
    - [dataset](#dataset)
        - [derived dataset](#derived-dataset)
    - [DAU](#dau)
    - [derived dataset](#derived-dataset)
    - [Fenix](#fenix)
    - [FxA](#fxa)
    - [Glean](#glean)
    - [GCP](#gcp)
    - [GeoIP](#geoip)
    - [ingestion](#ingestion)
    - [Intensity](#intensity)
    - [metric](#metric)
    - [MAU](#mau)
    - [Notebook Interface](#notebook-interface)
    - [ping](#ping)
    - [ping table](#ping-table)
    - [pipeline](#pipeline)
    - [probe](#probe)
    - [profile](#profile)
    - [query](#query)
    - [retention](#retention)
    - [Retention](#retention)
        - [-Week New Profile Retention](#-week-new-profile-retention)
        - [-Week Retention](#-week-retention)
    - [schema](#schema)
    - [session](#session)
    - [structured ingestion](#structured-ingestion)
    - [scheduled query](#scheduled-query)
    - [sql.telemetry.mozilla.org](#sqltelemetrymozillaorg)
    - [STMO](#stmo)
    - [Telemetry](#telemetry)
        - [WAU](#wau)

<!-- /TOC -->

## AET

Account Ecosystem Telemetry; see the [PRD](https://docs.google.com/document/d/1yRLiD8JuaZIIaKhs6DhXEa7aH8jwOau5yW0kHaldFQU/edit#)

## Analyst

A data analyst is someone who looks at Mozilla data, identifies trends and other qualitative measurements in them, and creates charts and dashboards.

## Amplitude

A third-party product used by several teams within Mozilla for analysis of user events.

## BigQuery

[BigQuery](https://cloud.google.com/bigquery) is Google Cloud's managed data warehouse. Most of the data described on this site is stored and queried using BigQuery. See the [Accessing and working with BigQuery](https://docs.telemetry.mozilla.org/cookbooks/bigquery.html0) article for more details.

## Client ID

The id property of the Firefox browser returns the universally unique identifier of the Client object.

## Data Analyst

See [Analyst](#Analyst)


## Data Practioner

See [Analyst](#Analyst)

## Data Scientist

Data scientists at Mozilla are a team with a broad array of technical backgrounds and a core set of common professional skills: 1) applying statistical methods to noisy data to answer questions about what, how, or why something is happening; 2) transform unstructured data into usable metrics and models; and 3) augmenting strategic product and decision-making with empirical evidence created and curated by the team.

## dataset

A set of data, which includes ping data, derived datasets, etc.; sometimes it is used synonymously with “table”; sometimes it is used technically to refer to a [BigQuery](https://cloud.google.com/bigquery/docs/datasets-intro) dataset, which represents a container for one or more tables.

### derived dataset

A processed dataset, such as `main_summary` or the `clients_daily` dataset


## DAU

The number of unique profiles active on each day.

## derived dataset

A processed dataset, such as the clients_daily dataset. This is in contrast to a raw dataset, which is typically a collection of pings. This data can be computed from some lower-level data, but is stored separately to save the cost and time of re-computing it.

## [Fenix](https://mana.mozilla.org/wiki/display/FIREFOX/Fenix+Home+Page)

[Firefox](https://play.google.com/store/apps/details?id=org.mozilla.firefox&hl=en_US) for Android browser.

## FxA

[Firefox Accounts](https://www.mozilla.org/en-CA/firefox/accounts/)

## Glean

Glean is Mozilla’s product analytics & telemetry solution that provides a consistent experience and behavior across all of our products. Most of Mozilla's mobile apps, including Fenix, have been adapted to use the Glean SDK. For more information, see the [Glean Overview](https://docs.telemetry.mozilla.org/concepts/glean/glean.html).

## GCP

Google Cloud Platform (GCP) is a suite of cloud-computing services that runs on the same infrastructure that Google uses internally for its end-user products.

## GeoIP

IP Geolocation involves attempting to discover the location of an IP address in the real world. IP addresses are assigned to an organization, and as these are ever-changing associations, it can be difficult to determine exactly where in the world an IP address is located. Mozilla’s ingestion infrastructure attempts to perform GeoIP lookup during the data decoding process and subsequently discards the IP address before the message arrives in long-term storage.

## ingestion

Mozilla's core data platform has been built to support structured ingestion of arbitrary JSON payloads whether they come from browser products on client devices or from server-side applications that have nothing to do with Firefox; any team at Mozilla can hook into structured ingestion by defining a schema and registering it with pipeline. Once a schema is registered, everything else is automatically provisioned, from an HTTPS endpoint for accepting payloads to a set of tables in BigQuery for holding the processed data.

## Intensity

Intuitively, how many days per week do users use the product? Among profilesactive at least once in the week ending on the date specified, the number of days on average they were active during that one-week window.

## metric

A metric is anything that you want to (and can) measure. This differs from a dimension which is a qualitative attribute of data.

## MAU

Monthly Active Users - the number of unique profiles active in the 28-day period ending on a given day. The number of unique profiles active at least once during the 28-day window
ending on the specified day.

## Notebook Interface

JupyterLab is a web-based interactive development environment for Jupyter notebooks, code, and data. It configures and arranges the user interface to support a wide range of workflows in data science, scientific computing, and machine learning. JupyterLab is extensible and modular and can write plugins that add new components and integrate with existing ones.

## ping

A ping represents a message that is sent from the Firefox browser to Mozilla’s Telemetry servers. It typically includes information about the browser’s state, user actions, etc.
[for more details](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/common-ping.html)


## ping table

A set of pings that is stored in BigQuery as a table.

## pipeline

Mozilla’s data pipeline, which is used to collect Telemetry data from Mozilla’s products and logs from various services.
The bulk of the data that is handled by this pipeline is Firefox Telemetry data. The same tool-chain is used to collect, store, and analyze data that comes from many sources.

The code for the ingestion pipeline is available in the [gcp-ingestion](https://github.com/mozilla/gcp-ingestion) repository.

## probe

Measurements for a specific aspect of Firefox are called probes. A single telemetry ping sends many different probes. Probes are either Histograms (recording distributions of data points) or Scalars (recording a single value).

You can search for details about probes by using the [Probe Dictionary](https://probes.telemetry.mozilla.org/). For each probe, the probe dictionary provides:

* A description of the probe
* When a probe started being collected
* Whether data from this probe is collected in the release channel

## profile

All of the changes a user makes in Firefox, like the home page, what toolbars you use, installed addons, saved passwords and your bookmarks, are all stored in a special folder, called a profile. Telemetry stores archived and pending pings in the profile directory as well as metadata like the client ID. See also [Profile Creation](https://docs.telemetry.mozilla.org/concepts/profile/profile_creation.html)

## query

TBD

## retention

* As in “Data retention” - how long data is stored before it is automatically deleted/archived

* As in “User retention” - how likely is a user to continue using a product

## Retention

### 1-Week New Profile Retention

Among new profiles created on the day specified, what proportion (out of 1) are
active during the week beginning one week after the day specified.

### 1-Week Retention

Among profiles that were active at least once in the week starting on the
specified day, what proportion (out of 1) are active during the following week.

## schema

A schema is the organization or structure for a database. The activity of data modeling leads to a schema. Mozilla’s source schema is available on the [mozilla-services/socorro GitHub repository](https://raw.githubusercontent.com/mozilla-services/socorro/main/socorro/schemas/crash_report.json).

## session

The period of time that it takes between Firefox being started until it is shut down.

* **Subsession**: `Sessions` are split into `subsessions` after every 24-hour time period has passed or the environment has changed.
([for more details](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/concepts/sessions.html?highlight=subsession))

## structured ingestion

Mozilla’s term for the URI scheme that is used for submitting data to the Telemetry pipeline; contrast this term with “telemetry ingestion” which represents an older URI scheme that is still supported for compatibility with desktop Firefox telemetry

## scheduled query

At Mozilla, queries are written in /sql. The directory structure is based on the destination table: /sql/{dataset_id}/{table_name}
You can schedule queries in [bigquery-etl](https://github.com/mozilla/bigquery-etl) in [Airflow](https://github.com/mozilla/telemetry-airflow) that run regularly with the results written to a table.

* [In bigquery-etl](https://docs.telemetry.mozilla.org/cookbooks/bigquery-airflow.html#in-bigquery-etl)
* [Other considerations](https://docs.telemetry.mozilla.org/cookbooks/bigquery-airflow.html#other-considerations)

## sql.telemetry.mozilla.org

A service for creating queries and dashboards. See [STMO under analysis tools](https://docs.telemetry.mozilla.org/tools/interfaces.html#sqltelemetrymozillaorg-stmo).

## STMO

As you use Firefox, Telemetry measures and collects non-personal information, such as performance, hardware, usage and customizations. It then sends this information to Mozilla on a daily basis and we use it to improve Firefox. 

## Telemetry

As you use Firefox, Telemetry measures and collects non-personal information, such as performance, hardware, usage and customizations. It then sends this information to Mozilla on a daily basis and we use it to improve Firefox. 

### WAU

The number of unique profiles active at least once during the 7-day window
ending on the specified day.
