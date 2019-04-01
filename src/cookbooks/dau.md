# DAU and MAU

For the purposes of DAU, a profile is considered active if it sends any main ping.
* Dates are defined by `submission_date_s3` or `submission_date`.

**DAU** is the number of clients sending a main ping on a given day.

**MAU** is the number of unique clients who have been a DAU on any day in the last **28 days**. In other words, any client that contributes to DAU in the last 28 days would also contribute to MAU for that day. Note that this is not simply the sum of DAU over 28 days, since any particular client could be active on many days.

**WAU** is the number of unique clients who have been a DAU on any day in the last **7 days**. Caveats above for MAU also apply to WAU.

For quick analysis, using [`clients_last_seen`](../datasets/bigquery/clients_last_seen/reference.md) is recommended, but it is only available in BigQuery. Below is an example query for getting MAU, WAU, and DAU using `clients_last_seen`.

```sql
  submission_date,
  -- days_since_seen is always between 0 and 28, so MAU could also be
  -- calculated with COUNT(days_since_seen) or COUNT(*)
  COUNTIF(days_since_seen < 28) AS mau,
  COUNTIF(days_since_seen < 7) AS wau,
  -- days_since_* values are always between 0 and 28 or null, so DAU could also
  -- be calculated with COUNTIF(days_since_seen = 0)
  COUNTIF(days_since_seen < 1) AS dau
FROM
  telemetry.clients_last_seen
GROUP BY
  submission_date
ORDER BY
  submission_date ASC
```

For analysis of only DAU, using [`clients_daily`](../datasets/batch_view/clients_daily/reference.md) is more efficient than `clients_last_seen`. Getting MAU and WAU from `clients_daily` is not recommended. Below is an example query for getting DAU using `clients_daily`.

```sql
SELECT
  submission_date_s3,
  COUNT(*) AS dau
FROM
  telemetry.clients_daily
GROUP BY
  submission_date_s3
ORDER BY
  submission_date_s3 ASC
```

[`main_summary`](../datasets/batch_view/main_summary/reference.md) can also be used for getting DAU. Below is an example query using a 1% sample over March 2018 using `main_summary`:

```sql
SELECT
  submission_date_s3,
  -- Note: this does not include NULL client_id in count where above methods do
  COUNT(DISTINCT client_id) * 100 AS DAU
FROM
  telemetry.main_summary
WHERE
  sample_id = '51'
  -- In BigQuery use yyyy-MM-DD, e.g. '2018-03-01'
  AND submission_date_s3 >= '20180301'
  AND submission_date_s3 < '20180401'
GROUP BY
  submission_date_s3
ORDER BY
  submission_date_s3 ASC
```

[`client_count_daily`](../datasets/batch_view/client_count_daily/reference.md) can be used to get **approximate** DAU, but it is only available in Presto. This dataset uses HyperLogLog to estimate unique counts. For example:

```sql
SELECT
  submission_date,
  cardinality(merge(cast(hll AS HLL))) AS dau
FROM
  telemetry.client_count_daily
WHERE
  -- Limit to 7 days of history
  submission_date >= date_format(CURRENT_DATE - INTERVAL '7' DAY, '%Y%m%d')
GROUP BY
  submission_date
ORDER BY
  submission_date
```

Note that the query above will not run in STMO, but will in Databricks.  [In the near future](https://bugzilla.mozilla.org/show_bug.cgi?id=1499645), we expect to offer a better option and will thoroughly update this documentation.
