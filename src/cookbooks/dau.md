# DAU and MAU

For the purposes of DAU, a profile is considered active if it sends any main ping.
* Dates are defined by `submission_date_s3`.

**DAU** is the number of clients sending a main ping on a given day.

**MAU** is the number of unique clients who have been a DAU on any day in the last **28 days**. In other words, any client that contributes to DAU in the last 28 days would also contribute to MAU for that day. Note that this is not simply the sum of DAU over 28 days, since any particular client could be active on many days.

For quick analysis, using `clients_daily_v6` is recommended. Below is an example query for getting DAU using `clients_daily_v6`.

```sql
SELECT
    submission_date_s3,
    count(*) AS total_clients_cdv6
FROM
    clients_daily_v6
GROUP BY
    1
ORDER BY
    1 ASC
```

`main_summary` can also be used for getting DAU. Below is an example query using a 1% sample over March 2018 using `main_summary`:

```sql
SELECT
    submission_date_s3,
    count(DISTINCT client_id) * 100 as DAU
FROM
    main_summary
WHERE
    sample_id = '51'
    AND submission_date_s3 >= '20180301'
    AND submission_date_s3 < '20180401'
GROUP BY
    1
ORDER BY
    1 ASC
```

[`client_count_daily`](../datasets/batch_view/client_count_daily/reference.md) can be used to get **approximate** DAU. This dataset uses HyperLogLog to estimate unique counts. For example:

```sql
SELECT
    submission_date AS day,
    cardinality(merge(cast(hll AS HLL))) AS dau
FROM
    client_count_daily
WHERE
    -- Limit to 7 days of history
    submission_date >= date_format(CURRENT_DATE - INTERVAL '7' DAY, '%Y%m%d')
GROUP BY 1
ORDER BY 1
```

Calculating MAU for a single date is simple.  For example, the following query calculates MAU for 2018-12-16:

```sql
SELECT
  COUNT(DISTINCT client_id)
FROM
  clients_daily_v6
WHERE
  submission_date_s3 <= '20181216'
  AND submission_date_s3 >= '20181119'
```
Generating a table of MAU over time is more complex.  Here's one possible way, which is conceptually simple, but not very computationally efficient:

```sql
SELECT
  dates_table.submission_date_s3,
  COUNT(DISTINCT clients_table.client_id) AS mau
FROM
  (
    SELECT
      TO_DATE(submission_date_s3, 'yyyyMMdd') AS submission_date_s3
    FROM
      clients_daily_v6
    WHERE
      submission_date_s3 >= '20181216'
    GROUP BY submission_date_s3
  ) AS dates_table
JOIN
  (
    SELECT
      client_id,
      TO_DATE(submission_date_s3, 'yyyyMMdd') AS submission_date_s3
    FROM
      clients_daily_v6
    WHERE
      submission_date_s3 >= '20181119'
  ) AS clients_table
ON
  clients_table.submission_date_s3 between dates_table.submission_date_s3 - interval 27 day and dates_table.submission_date_s3
GROUP BY dates_table.submission_date_s3
```

Note that the query above will not run in STMO, but will in Databricks.  In the near future, we expect to offer a better option and will thoroughly update this documentation.
