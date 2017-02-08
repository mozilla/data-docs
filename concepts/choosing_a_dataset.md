# Choosing a dataset

This document is a quick overview of the datasets provided by the data pipeline
team.  After reading this document, you should have a good idea of what dataset
is the most useful for your analysis.

Before making final decisions from your findings, consider getting your query
or analysis reviewed by a member of the data pipeline team.

## Accessing a dataset

Playing with the data is the best way to get comfortable.  All of these
datasets can be queried from [STMO](http://sql.telemetry.mozilla.org) (AKA:
re:dash).  STMO will give you an interactive SQL interface, which should be
sufficient for getting comfortable with the data.  If you need to complete more
complicated analyses or want to productionize your code, see [Analyzing
Telemetry Data](analyzing_telemetry_data.md).

## Overview

Unless noted otherwise, these datasets summarize the ["main" Telemetry ping
type](https://gecko.readthedocs.io/en/latest/toolkit/components/telemetry/telemetry/data/main-ping.html).
The main ping payload contains most of the measurements used to track
performance and health of Firefox in the wild.  It can be useful to refer back
to the source ping documentation to understand how the source data was
generated.

# Datasets
## Table of Contents
* [main_summary](#main-summary)
* [longitudinal](#longitudinal)
* [cross_sectional](#cross-sectional)
* [client_count](#client-count)
* [crash_aggregates](#crash-aggregates)

## Main Summary
The `main_summary` table is the most direct representation of a main ping but
can be difficult to work with due to its size. 

### Rows and Columns
The `main_summary` table contains one row for each ping.  Each column
represents one field from the main ping payload, though only a subset of all
main ping fields are included.

### Background and Caveats
This table is massive, and due to it's size, it can be difficult to work with.
You should **avoid querying `main_summary`** from
[re:dash](sql.telemetry.mozilla.com).  Your queries will be **slow to
complete** and can **impact performance for other users**, since re:dash on a
shared cluster.

Instead, we recommend using the `longitudinal` or `cross_sectional` dataset
where possible.  If these datasets do not suffice, consider using Spark on an
[ATMO](analysis.telemetry.mozilla.com) cluster.  In the odd case where these
queries are necessary, make use of the `sample_id` field and limit to a short
submission date range.

## Longitudinal

The `longitudinal` dataset is a 1% sample of main ping data organized to
roughly represent a user. If you're not sure which dataset to use for your
analysis, this is probably what you want.

### Rows and Columns
Each row in the `longitudinal` dataset represents one `client_id`, which is a
rough approximation of a user.  Each column represents a field from the main
ping.  Most fields contain arrays of values, with one value for each ping
associated with a client_id. Using arrays give you access to the raw data from
each ping, but can be difficult to work with from SQL.  Take a look at the
[longitudinal examples](longitudinal_examples.md) if you get stuck.

[//]: # (TODO(harter): why is client_id an approximation for a user?)

### Background and Caveats
Think of the longitudinal table as wide and short.  The dataset contains more
columns than `main_summary` and down-samples to 1% of all clients to reduce
query computation time and save resources.

In summary, the longitudinal table differs from `main_summary` in two important
ways:
* The longitudinal dataset groups all data so that one row represents a client_id
* The longitudinal dataset samples to 1% of all client_ids

## Cross Sectional

The `cross_sectional` dataset provides descriptive statistics for each
client_id in a 1% sample of main ping data. This dataset simplifies the
longitudinal table by replacing the longitudinal arrays with summary
statistics. This is the most useful dataset for describing our user base.

### Rows and Columns
Each row in the `cross_sectional` dataset represents one `client_id`, which is
a rough approximation to a user.  Each column is a summary statistic describing
the client_id.

For example, the longitudinal table has a row called `geo_country` which
contains an array of country codes. For the same client_id the
`cross_sectional` table has columns called `geo_country_mode` and
`geo_country_configs` containing single summary statistics for the modal country and the
number of distinct countries in the array.

| `client_id` | `geo_country`          | `geo_country_mode` | `geo_country_configs`|
| ----------- |:----------------------:|:------------------:|:--------------------:|
| 1           | array<"US">            | "US"               | 1                    |
| 2           | array<"DE", "DE" "US"> | "DE"               | 2                    |

### Background and Caveats


This table is much easier to work with than the longitudinal dataset because
you don't need to work with arrays.  Note that this dataset is a summary of the
longitudinal dataset, so it is also a 1% sample of all client_ids. 

[//]: # (TODO(harter): Add a note about the distribution viewer)

## Client Count
The `client_count` dataset is simply a count of clients in a time period,
stratified over a set of dimensions.

### Rows and Columns

This dataset includes columns for a dozen factors and an HLL variable.  The
`hll` column contains a
[HyperLogLog](https://en.wikipedia.org/wiki/HyperLogLog) variable, which is an
approximation to the exact count.  The factor columns include activity date and
the dimensions listed
[here](https://github.com/mozilla/telemetry-batch-view/blob/master/src/main/scala/com/mozilla/telemetry/views/ClientCountView.scala#L22).
Each row represents one combinations of the factor columns.

### Background and Caveats

It's important to understand that the `hll` column is **not a standard count**.
The `hll` variable avoids double-counting users when aggregating over
multiple days.  The HyperLogLog variable is a far more efficient way to count
distinct elements of a set, but comes with some complexity.  To find the
cardinality of an HLL use `cardinality(cast(hll AS HLL))`.  To find the union
of two HLL's over different dates, use `merge(cast(hll AS HLL))`.  The [Firefox
ER Reporting Query](https://sql.telemetry.mozilla.org/queries/81/source#129) is
a good example to review.  Finally, Roberto has a relevant writeup
[here](https://robertovitillo.com/2016/04/12/measuring-product-engagment-at-scale/).

## Crash Aggregates
The Crash Aggregates dataset compiles crash statistics over various dimensions for each day.

### Rows and Columns

There's one column for each of the stratifying dimensions and the crash
statistics.  Each row is a distinct set of dimensions, along with their
associated crash stats.  Example stratifying dimensions include channel and
country, example statistics include usage hours and plugin crashes. See the
[complete documentation](CrashAggregateView.md) for all available dimensions
and statistics.

# Appendix

## Mobile Metrics

There are several tables owned by the mobile team documented
[here](https://wiki.mozilla.org/Mobile/Metrics/Redash): 

* android_events
* android_clients
* android_addons
* mobile_clients

## Wiki For reference, a previous version of this document was stored
[here](https://wiki.mozilla.org/Telemetry/Available_Telemetry_Datasets_and_their_Applications).

## Who to Contact

Feel free to open an issue or contact Ryan Harter
([@harterrt](https://github.com/harterrt)) to identify errors or confusing
parts of this documentation.  I will be reviewing this documentation quarterly
for accuracy.
