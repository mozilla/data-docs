# Churn

<!-- toc -->

# Introduction

{% include "./intro.md" %}

# Data Reference
## Example Queries

This will walk through a typical query that can be used to generate data suitable for visualization. 

| field | type | description |
|-------|------|-------------|
| cohort_date | common, attribute |  The date that defines the start of the cohort. This is generally the date when the client was acquired. 
| elapsed_periods | common, attribute | The number of periods that have elapsed since the cohort date. In this dataset, the retention period is 7 days.
| channel | attribute | Part of the release train model. An attribute that distinguishes cohorts.
| geo | filter attribute | Country code. Used to filter out all countries other than the 'US'
| n_profiles | metric | Count of users in a cohort. Use sum to aggregate.

First the fields are extracted and aliased for consistency. `cohort_date` and `elapsed_periods` are common to most retention queries and are useful concepts if you are building a query on top of `main_summary` for example.  

```sql
WITH extracted AS (--
    SELECT date_format(date(acquisition_period), '%Y%m%d') AS cohort_date,
           current_week AS elapsed_periods,
           n_profiles,
           channel,
           geo
    FROM churn
),
```

The extracted table is filtered down on the properties we want to look at. We are only interested in cohorts that originate in the US and are in the release or beta channels. Note that `channel` here is the concatenation of the normalized channel and the funnelcake id. We are also only interested in cohorts from a particular time period.

```sql
 population AS (--
    SELECT channel,
           cohort_date,
           elapsed_periods,
           n_profiles
    FROM extracted
    WHERE geo = 'US'
      AND channel IN ('release', 'beta')
      AND elapsed_periods >= 0
      AND elapsed_periods < 12
      AND cohort_date > '20170806'
),
```

The next step is to aggregate the number of profiles by each of the chosen dimensions. This leads to a table that is broken down by each attribute and aggregated over each metric. The cohort date and elapsed periods are the primary attributes that play a role in tracking the retention rate of cohorts over time.

```sql
 cohorts AS (--
     SELECT channel,
            cohort_date,
            elapsed_periods,
            sum(n_profiles) AS n_profiles
     FROM population
     GROUP BY 1, 2, 3
),
```
The table will end up in the following shape (but unsorted). 
| channel | cohort_date | elapsed_periods | n_profiles |
|---------|-------------|-----------------|------------|
| release | 20170101 | 0 | 100 |
| release | 20170101 | 1 | 90 |
| release | 20170101 | 2 | 80 |
| ... | .... | ... | ... |
| beta | 20170128 | 10 | 25 |

Finally, the following query determines retention rate at the `elapsed_period` relative to the first period. This transforms the cohort table into something that can be exported to other tools for visualization.

```sql
results AS (--
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

| channel | cohort_date | elapsed_periods | n_profiles | total_n_profiles | percentage_n_profiles |
|---------|-------------|-----------------|------------|------------------|-----------------------|
| release | 20170101    | 0               | 100        | 100              | 1.0                   |
| release | 20170101    | 1               | 90         | 100              | 0.9                   |
| release | 20170101    | 2               | 80         | 100              | 0.8                   |
| ...     | ....        | ...             | ...        | ...              | ...                   |
| beta    | 20170128    | 10              | 25         | 50               | 0.5                   |

Finally, write the main query.

```SQL
SELECT *
FROM results
```

You may consider visualizing using cohort graphs, line charts, or a pivot table heatmap. See [Firefox Telemetry Retention: Dataset Example Usage](https://sql.telemetry.mozilla.org/dashboard/firefox-telemetry-retention-dataset-example-usage) for more examples.

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

The script for generating `churn` currently lives in [`mozilla/python_mozetl`](https://github.com/mozilla/python_mozetl). The job can be found in [`mozetl/engagement/churn`](https://github.com/mozilla/python_mozetl/blob/master/mozetl/engagement/churn/job.py). 
