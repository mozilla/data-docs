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

The `longitudinal` dataset is a 1% sample of main ping data
organized so that each row corresponds to a client_id.
If you're not sure which dataset to use for your analysis,
this is probably what you want.

#### Contents
Each row in the `longitudinal` dataset represents one `client_id`,
which is approximately a user.
Each column represents a field from the main ping.
Most fields contain **arrays of values**, with one value for each ping associated with a client_id.
Using arrays give you access to the raw data from each ping,
but can be difficult to work with from SQL.
Here's a [query showing some sample data](https://sql.telemetry.mozilla.org/queries/4188#table)
to help illustrate.
Take a look at the [longitudinal examples](/cookbooks/longitudinal.md) if you get stuck.

#### Background and Caveats
Think of the longitudinal table as wide and short.
The dataset contains more columns than `main_summary`
and down-samples to 1% of all clients to reduce query computation time and save resources.

In summary, the longitudinal table differs from `main_summary` in two important ways:

* The longitudinal dataset groups all data so that one row represents a client_id
* The longitudinal dataset samples to 1% of all client_ids

#### Accessing the Data

The `longitudinal` is available in re:dash,
though it can be difficult to work with the array values in SQL.
Take a look at this [example query](https://sql.telemetry.mozilla.org/queries/4189/source).

The data is stored as a parquet table in S3 at the following address.
See [this cookbook](/cookbooks/parquet.md) to get started working with the data
in [Spark](http://spark.apache.org/docs/latest/quick-start.html).
```
s3://telemetry-parquet/longitudinal/
```

#### Further Reading

The technical documentation for the `longitudinal` dataset is located in the
[telemetry-batch-view documentation](https://github.com/mozilla/telemetry-batch-view/blob/master/docs/Longitudinal.md).

We also have a set of examples in the [longitudinal cookbook](/cookbooks/longitudinal.md)

The code that generates this dataset is [here](https://github.com/mozilla/telemetry-batch-view/blob/master/src/main/scala/com/mozilla/telemetry/views/Longitudinal.scala)

## main_summary

The `main_summary` table is the most direct representation of a main ping
but can be difficult to work with due to its size. 
Prefer the `longitudinal` dataset unless using the sampled data is prohibitive.

#### Contents

The `main_summary` table contains one row for each ping.
Each column represents one field from the main ping payload,
though only a subset of all main ping fields are included.
This dataset **does not include histograms**.

#### Background and Caveats
This table is massive, and due to it's size, it can be difficult to work with.
You should **avoid querying `main_summary`** from [re:dash](https://sql.telemetry.mozilla.org).
Your queries will be **slow to complete** and can **impact performance for other users**,
since re:dash on a shared cluster.

Instead, we recommend using the `longitudinal` or `cross_sectional` dataset where possible.
If these datasets do not suffice, consider using Spark on an
[ATMO](https://analysis.telemetry.mozilla.org) cluster.
In the odd case where these queries are necessary,
make use of the `sample_id` field and limit to a short submission date range.

#### Accessing the Data

The data is stored as a parquet table in S3 at the following address.
See [this cookbook](/cookbooks/parquet.md) to get started working with the data in Spark.
```
s3://telemetry-parquet/main_summary/v3/
```

Though **not recommended** `main_summary` is accessible through re:dash. 
Here's an [example query](https://sql.telemetry.mozilla.org/queries/4201/source).
Your queries will be slow to complete and can **impact performance for other users**,
since re:dash is on a shared cluster.

#### Further Reading

The technical documentation for `main_summary` is located in the
[telemetry-batch-view documentation](https://github.com/mozilla/telemetry-batch-view/blob/master/docs/MainSummary.md).

The code responsible for generating this dataset is 
[here](https://github.com/mozilla/telemetry-batch-view/blob/master/src/main/scala/com/mozilla/telemetry/views/MainSummaryView.scala)


## cross_sectional

The `cross_sectional` dataset provides descriptive statistics
for each client_id in a 1% sample of main ping data.
This dataset simplifies the longitudinal table by replacing 
the longitudinal arrays with summary statistics. 
This is the most useful dataset for describing our user base.

#### Content
Each row in the `cross_sectional` dataset represents one `client_id`,
which is approximately a user.
Each column is a summary statistic describing the client_id.

For example, the longitudinal table has a row called `geo_country` 
which contains an array of country codes.
For the same `client_id` the `cross_sectional` table 
has columns called `geo_country_mode` and `geo_country_configs` 
containing single summary statistics for 
the modal country and the number of distinct countries in the array.

| `client_id` | `geo_country`          | `geo_country_mode` | `geo_country_configs`|
| ----------- |:----------------------:|:------------------:|:--------------------:|
| 1           | array<"US">            | "US"               | 1                    |
| 2           | array<"DE", "DE" "US"> | "DE"               | 2                    |

#### Background and Caveats

This table is much easier to work with than the longitudinal dataset because
you don't need to work with arrays.
This table has a limited number of pre-computed summary statistics
so you're metric may not be included.

Note that this dataset is a summary of the longitudinal dataset,
so it is also a 1% sample of all client_ids.

All summary statistics are computed over the last 180 days,
so this dataset can be insensitive to changes over time.

#### Accessing the Data

The cross_sectional dataset is available in re:dash.
Here's an [example query](https://sql.telemetry.mozilla.org/queries/4202/source).

The data is stored as a parquet table in S3 at the following address.
See [this cookbook](/cookbooks/parquet.md) to get started working with the data in Spark.
```
s3://telemetry-parquet/cross_sectional/v1/
```

#### Further Reading

The `cross_sectional` dataset is generated by 
[this code](https://github.com/mozilla/telemetry-batch-view/blob/master/src/main/scala/com/mozilla/telemetry/views/CrossSectionalView.scala).
Take a look at [this query](https://sql.telemetry.mozilla.org/queries/4203/source) for a schema.


## client_count

The `client_count` dataset is useful for estimating user counts over a few 
[pre-defined dimensions](https://github.com/mozilla/telemetry-batch-view/blob/master/src/main/scala/com/mozilla/telemetry/views/ClientCountView.scala#L22).

#### Content

This dataset includes columns for a dozen factors and an HLL variable.
The `hll` column contains a
[HyperLogLog](https://en.wikipedia.org/wiki/HyperLogLog)
variable, which is an approximation to the exact count.
The factor columns include activity date and the dimensions listed
[here](https://github.com/mozilla/telemetry-batch-view/blob/master/src/main/scala/com/mozilla/telemetry/views/ClientCountView.scala#L22).
Each row represents one combinations of the factor columns.

#### Background and Caveats

It's important to understand that the `hll` column is **not a standard count**.
The `hll` variable avoids double-counting users when aggregating over multiple days.
The HyperLogLog variable is a far more efficient way to count distinct elements of a set,
but comes with some complexity.
To find the cardinality of an HLL use `cardinality(cast(hll AS HLL))`.
To find the union of two HLL's over different dates, use `merge(cast(hll AS HLL))`.
The [Firefox ER Reporting Query](https://sql.telemetry.mozilla.org/queries/81/source#129)
is a good example to review.
Finally, Roberto has a relevant writeup
[here](https://robertovitillo.com/2016/04/12/measuring-product-engagment-at-scale/).

#### Accessing the Data

The data is available in re:dash.
Take a look at this 
[example query](https://sql.telemetry.mozilla.org/queries/81/source#129).

I don't recommend accessing this data from ATMO.

#### Further Reading


# Crash Ping Derived Datasets

The [crash ping](http://gecko.readthedocs.io/en/latest/toolkit/components/telemetry/telemetry/data/crash-ping.html)
is captured after the main Firefox process crashes or after a content process crashes,
whether or not the crash report is submitted to crash-stats.mozilla.org.
It includes non-identifying metadata about the crash.

This section describes the derived datasets we provide to make analyzing this data easier.

## crash_aggregates

The `crash_aggregates` dataset compiles crash statistics over various dimensions for each day.

#### Rows and Columns

There's one column for each of the stratifying dimensions and the crash statistics.
Each row is a distinct set of dimensions, along with their associated crash stats.
Example stratifying dimensions include channel and country,
example statistics include usage hours and plugin crashes.
See the [complete documentation](https://github.com/mozilla/telemetry-batch-view/blob/master/docs/CrashAggregateView.md)
for all available dimensions
and statistics.

#### Accessing the Data

This dataset is accessible via re:dash.

The data is stored as a parquet table in S3 at the following address.
See [this cookbook](/cookbooks/parquet.md) to get started working with the data in Spark.
```
s3://telemetry-parquet/crash_aggregates/v1/
```

#### Further Reading

The technical documentation for this dataset can be found in the
[telemetry-batch-view documentation](https://github.com/mozilla/telemetry-batch-view/blob/master/docs/CrashAggregateView.md)


# Appendix

## Mobile Metrics

There are several tables owned by the mobile team documented
[here](https://wiki.mozilla.org/Mobile/Metrics/Redash): 

* android_events
* android_clients
* android_addons
* mobile_clients

