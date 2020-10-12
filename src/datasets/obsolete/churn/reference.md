# Churn

> As of 2019-08-21, this dataset has been deprecated and is no longer
> maintained. See [Bug
> 1561048](https://bugzilla.mozilla.org/show_bug.cgi?id=1561048) for historical
> sources. See the [retention cookbook](../../../cookbooks/retention.md) for
> current best practices.

<!-- toc -->

# Introduction

{{#include ./intro.md}}

# Data Reference

## Example Queries

This section walks through a typical query to generate data suitable for
visualization.

| field             | type              | description                                                                                                     |
| ----------------- | ----------------- | --------------------------------------------------------------------------------------------------------------- |
| `cohort_date`     | common, attribute | The start date bucket of the cohort. This is week the client was acquired.                                      |
| `elapsed_periods` | common, attribute | The number of periods that have elapsed since the cohort date. In this dataset, the retention period is 7 days. |
| `channel`         | attribute         | Part of the release train model. An attribute that distinguishes cohorts.                                       |
| `geo`             | filter attribute  | Country code. Used to filter out all countries other than the 'US'                                              |
| `n_profiles`      | metric            | Count of users in a cohort. Use sum to aggregate.                                                               |

First the fields are extracted and aliased for consistency. `cohort_date` and
`elapsed_periods` are common to most retention queries and are useful concepts
for building on other datasets.

```sql
WITH extracted AS (
    SELECT acquisition_period AS cohort_date,
           current_week AS elapsed_periods,
           n_profiles,
           channel,
           geo
    FROM churn
),
```

The extracted table is filtered down to the attributes of interest. The cohorts
of interest originate in the US and are in the release or beta channels. Note
that `channel` here is the concatenation of the normalized channel and the
funnelcake id. Only cohorts appearing after August 6, 2017 are chosen to be in
this population.

```sql
 population AS (
    SELECT channel,
           cohort_date,
           elapsed_periods,
           n_profiles
    FROM extracted
    WHERE geo = 'US'
      AND channel IN ('release', 'beta')
      AND cohort_date > '20170806'
      -- filter out noise from clients with incorrect dates
      AND elapsed_periods >= 0
      AND elapsed_periods < 12
),
```

The number of profiles is aggregated by the cohort dimensions. The cohort
acquisition date and elapsed periods since acquisition are fundamental to cohort
analysis.

```sql
 cohorts AS (
     SELECT channel,
            cohort_date,
            elapsed_periods,
            sum(n_profiles) AS n_profiles
     FROM population
     GROUP BY 1, 2, 3
),
```

The table will have the following structure. The table is sorted by the first three columns for demonstration.

| `channel` | `cohort_date` | `elapsed_periods` | `n_profiles` |
| --------- | ------------- | ----------------- | ------------ |
| release   | 20170101      | 0                 | 100          |
| release   | 20170101      | 1                 | 90           |
| release   | 20170101      | 2                 | 80           |
| ...       | ...           | ...               | ...          |
| beta      | 20170128      | 10                | 25           |

Finally, retention is calculated through the number of profiles at the time of
the `elapsed_period` relative to the initial period. This data can be imported
into a pivot table for further analysis.

```sql
results AS (
    SELECT c.*,
           iv.n_profiles AS total_n_profiles,
           (0.0+c.n_profiles)*100/iv.n_profiles AS percentage_n_profiles
    FROM cohorts c
    JOIN (
        SELECT *
        FROM cohorts
        WHERE elapsed_periods = 0
    ) iv ON (
        c.cohort_date = iv.cohort_date
        AND c.channel = iv.channel
    )
)
```

| `channel` | `cohort_date` | `elapsed_periods` | `n_profiles` | `total_n_profiles` | `percentage_n_profiles` |
| --------- | ------------- | ----------------- | ------------ | ------------------ | ----------------------- |
| release   | 20170101      | 0                 | 100          | 100                | 1.0                     |
| release   | 20170101      | 1                 | 90           | 100                | 0.9                     |
| release   | 20170101      | 2                 | 80           | 100                | 0.8                     |
| ...       | ....          | ...               | ...          | ...                | ...                     |
| beta      | 20170128      | 10                | 25           | 50                 | 0.5                     |

Obtain the results.

```sql
SELECT *
FROM results
```

You may consider visualizing using cohort graphs, line charts, or a pivot
tables. See [Firefox Telemetry Retention: Dataset Example Usage](https://sql.telemetry.mozilla.org/dashboard/firefox-telemetry-retention-dataset-example-usage)
for more examples.

## Scheduling

The aggregated churn data is updated weekly on Wednesday.

## Schema

As of 2017-10-15, the current version of `churn` is `v3` and has a schema as follows:

```
root
 |-- channel: string (nullable = true)
 |-- geo: string (nullable = true)
 |-- is_funnelcake: string (nullable = true)
 |-- acquisition_period: string (nullable = true)
 |-- start_version: string (nullable = true)
 |-- sync_usage: string (nullable = true)
 |-- current_version: string (nullable = true)
 |-- current_week: long (nullable = true)
 |-- source: string (nullable = true)
 |-- medium: string (nullable = true)
 |-- campaign: string (nullable = true)
 |-- content: string (nullable = true)
 |-- distribution_id: string (nullable = true)
 |-- default_search_engine: string (nullable = true)
 |-- locale: string (nullable = true)
 |-- is_active: string (nullable = true)
 |-- n_profiles: long (nullable = true)
 |-- usage_hours: double (nullable = true)
 |-- sum_squared_usage_hours: double (nullable = true)
 |-- total_uri_count: long (nullable = true)
 |-- unique_domains_count_per_profile: double (nullable = true)
```

## Code Reference

The script for generating `churn` currently lives in
[`mozilla/python_mozetl`](https://github.com/mozilla/python_mozetl/tree/9217335652cad46940a51c7c2784cc5c6d3a00f4). The job can
be found in
[`mozetl/engagement/churn`](https://github.com/mozilla/python_mozetl/blob/9217335652cad46940a51c7c2784cc5c6d3a00f4/mozetl/engagement/churn/job.py#L1-L27).
