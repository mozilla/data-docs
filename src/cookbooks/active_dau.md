# Active DAU and Active MAU

An **Active User** is defined as a client who has `total_daily_uri` >= 5 URI for a given date.

- Dates are defined by `submission_date` (_not_ by [client activity date](https://bugzilla.mozilla.org/show_bug.cgi?id=1422892)).
- A client's `total_daily_uri` is defined as their sum of `scalar_parent_browser_engagement_total_uri_count` for a given date<sup>[1](#total_uri_count)</sup>.

**Active DAU** (aDAU) is the number of Active Users on a given day.

**Active MAU** (aMAU) is the number of unique clients who have been an Active User on any day in the last **28 days**. In other words, any client that contributes to aDAU in the last 28 days would also contribute to aMAU for that day. Note that this is not simply the sum of aDAU over 28 days, since any particular client could be active on many days.

**Active WAU** (aWAU) is the number of unique clients who have been an Active User on any day in the last **7 days**. Caveats above for aMAU also apply to aWAU.

To make the time boundaries more clear, let's consider a particular date 2019-01-28. The aDAU number assigned to 2019-01-28 should consider all main pings received during 2019-01-28 UTC. We cannot observe the full data until 2019-01-28 closes (and in practice we need to wait a bit longer since we are usually referencing derived datasets like `clients_daily` that are updated once per day over several hours following midnight UTC), so the earliest we can calculate this value is on 2019-01-29. If plotted as a time series, this value should always be plotted at the point labeled 2019-01-28. Likewise, aMAU for 2019-01-28 should consider a 28 day range that includes main pings received on 2019-01-28 and back to beginning of day UTC 2019-01-01. Again, the earliest we can calculate the value is on 2019-01-29.

For quick analysis, using [`firefox_desktop_exact_mau28_by_dimensions`](../datasets/bigquery/exact_mau/reference.md) is recommended. Below is an example query for getting MAU, WAU, and DAU for 2018 using `firefox_desktop_exact_mau28_by_dimensions`.

```sql
SELECT
  submission_date,
  SUM(visited_5_uri_mau) AS visited_5_uri_mau,
  SUM(visited_5_uri_wau) AS visited_5_uri_wau,
  SUM(visited_5_uri_dau) AS visited_5_uri_dau
FROM
  telemetry.firefox_desktop_exact_mau28_by_dimensions
WHERE
  submission_date_s3 >= '2018-01-01'
  AND submission_date_s3 < '2019-01-01'
GROUP BY
  submission_date
ORDER BY
  submission_date
```

For analysis of dimensions not available in `firefox_desktop_exact_mau28_by_dimensions`, using [`clients_last_seen`](../datasets/bigquery/clients_last_seen/reference.md) is recommended. Below is an example query for getting aMAU, aWAU, and aDAU by `app_version` for 2018 using `clients_last_seen`.

```sql
SELECT
  submission_date,
  app_version,
  -- days_since_* values are always < 28 or null, so aMAU could also be
  -- calculated with COUNT(days_since_visited_5_uri)
  COUNTIF(days_since_visited_5_uri < 28) AS visited_5_uri_mau,
  COUNTIF(days_since_visited_5_uri < 7) AS visited_5_uri_wau,
  -- days_since_* values are always >= 0 or null, so aDAU could also be
  -- calculated with COUNTIF(days_since_visited_5_uri = 0)
  COUNTIF(days_since_visited_5_uri < 1) AS visited_5_uri_dau
FROM
  telemetry.clients_last_seen
WHERE
  submission_date_s3 >= '2018-01-01'
  AND submission_date_s3 < '2019-01-01'
GROUP BY
  submission_date,
  app_version
ORDER BY
  submission_date,
  app_version
```

For analysis of only aDAU, using [`clients_daily`](../datasets/batch_view/clients_daily/reference.md) is more efficient than `clients_last_seen`. Getting aMAU and aWAU from `clients_daily` is not recommended. Below is an example query for getting aDAU for 2018 using `clients_daily`.

```sql
SELECT
  submission_date_s3,
  COUNT(*) AS visited_5_uri_dau
FROM
  telemetry.clients_daily
WHERE
  scalar_parent_browser_engagement_total_uri_count_sum >= 5
  -- In BigQuery use yyyy-MM-DD, e.g. '2018-01-01'
  AND submission_date_s3 >= '20180101'
  AND submission_date_s3 < '20190101'
GROUP BY
  submission_date_s3
ORDER BY
  submission_date_s3
```

[`main_summary`](../datasets/batch_view/main_summary/reference.md) can also be used for getting aDAU. Below is an example query using a 1% sample over March 2018 using `main_summary`:

```sql
SELECT
  submission_date_s3,
  COUNT(*) * 100 AS visited_5_uri_dau
FROM (
  SELECT
    submission_date_s3,
    client_id,
    SUM(scalar_parent_browser_engagement_total_uri_count) >= 5 AS visited_5_uri
  FROM
    telemetry.main_summary
  WHERE
    sample_id = '51'
    -- In BigQuery use yyyy-MM-DD, e.g. '2018-03-01'
    AND submission_date_s3 >= '20180301'
    AND submission_date_s3 < '20180401'
  GROUP BY
    submission_date_s3,
    client_id)
WHERE
  visited_5_uri
GROUP BY
  submission_date_s3
ORDER BY
  submission_date_s3
```

<span id="total_uri_count">**1**</span>: Note, the probe measuring `scalar_parent_browser_engagement_total_uri_count` only exists in clients with Firefox 50 and up. Clients on earlier versions of Firefox won't be counted as an Active User (regardless of their use). Similarly, `scalar_parent_browser_engagement_total_uri_count` doesn't increment when a client is in Private Browsing mode, so that won't be included as well.
