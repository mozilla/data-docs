# Client Count Daily Reference

> As of 2019-04-10, this dataset has been deprecated and is no longer maintained. Please use [`clients_last_seen`](/datasets/bigquery/clients_last_seen/reference.md) instead. See [Bug 1543518](https://bugzilla.mozilla.org/show_bug.cgi?id=1543518) for more information.

<!-- toc -->

# Replacement

We've moved to calculating exact user counts based on
[`clients_last_seen`](/datasets/bigquery/clients_last_seen/reference.md), see
[DAU](../../../cookbooks/dau.md) and
[Active DAU](../../../cookbooks/active_dau.md) for examples.

# Introduction

{{#include ./intro.md}}

# Data Reference

## Example Queries

#### Compute DAU for non-windows clients for the last week

```sql
WITH sample AS (
  SELECT
    os,
    submission_date,
    cardinality(merge(cast(hll AS HLL))) AS count
  FROM client_count_daily
  WHERE submission_date >= DATE_FORMAT(CURRENT_DATE - INTERVAL '7' DAY, '%Y%m%d')
  GROUP BY
    submission_date,
    os
)

SELECT
  os,
  -- formatting date as late as possible improves performance dramatically
  date_parse(submission_date, '%Y%m%d') AS submission_date,
  count
FROM sample
WHERE
  count > 10 -- remove outliers
  AND lower(os) NOT LIKE '%windows%'
ORDER BY
  os,
  submission_date DESC
```

#### Compute WAU by Channel for the last week

```sql
WITH dau AS (
  SELECT
    normalized_channel,
    submission_date,
    merge(cast(hll AS HLL)) AS hll
  FROM client_count_daily
  -- 2 days of lag, 7 days of results, and 6 days preceding for WAU
  WHERE submission_date > DATE_FORMAT(CURRENT_DATE - INTERVAL '15' DAY, '%Y%m%d')
  GROUP BY
    submission_date,
    normalized_channel
),
wau AS (
  SELECT
    normalized_channel,
    submission_date,
    cardinality(merge(hll) OVER (
      PARTITION BY normalized_channel
      ORDER BY submission_date
      ROWS BETWEEN 6 PRECEDING AND 0 FOLLOWING
    )) AS count
  FROM dau
)

SELECT
  normalized_channel,
  -- formatting date as late as possible improves performance dramatically
  date_parse(submission_date, '%Y%m%d') AS submission_date,
  count
FROM wau
WHERE
  count > 10 -- remove outliers
  AND submission_date > DATE_FORMAT(CURRENT_DATE - INTERVAL '9' DAY, '%Y%m%d') -- only days that have a full WAU
```

## Caveats

The `hll` column does not product an exact count. `hll` stands for
[HyperLogLog](https://en.wikipedia.org/wiki/HyperLogLog), a sophisticated
algorithm that allows for the counting of extremely high numbers of items,
sacrificing a small amount of accuracy in exchange for using much less memory
than a simple counting structure.

When count is calculated over a column that may change over time, such as
`total_uri_count_threshold`, then a client would be counted in every group
where they appear. Over longer windows, like MAU, this is more likely to occur.

## Schema

The data is partitioned by `submission_date` which is formatted as `%Y%m%d`,
like `20180130`.

As of 2018-03-15, the current version of the `client_count_daily` dataset
is `v2`, and has a schema as follows:

```
root
 |-- app_name: string (nullable = true)
 |-- app_version: string (nullable = true)
 |-- country: string (nullable = true)
 |-- devtools_toolbox_opened: boolean (nullable = true)
 |-- e10s_enabled: boolean (nullable = true)
 |-- hll: binary (nullable = true)
 |-- locale: string (nullable = true)
 |-- normalized_channel: string (nullable = true)
 |-- os: string (nullable = true)
 |-- os_version: string (nullable = true)
 |-- top_distribution_id: string (nullable = true)
 |-- total_uri_count_threshold: integer (nullable = true)
```
