# Daily and Monthly Active Users (DAU and MAU)

For the purposes of DAU, a desktop profile is considered active if it sends any main ping.
See the next section for analogous definitions on top of mobile products.

- Dates are defined by `submission_date`.

**DAU** is the number of clients sending a main ping on a given day.

**MAU** is the number of unique clients who have been a DAU on any day in the last **28 days**. In other words, any client that contributes to DAU in the last 28 days would also contribute to MAU for that day. Note that this is not simply the sum of DAU over 28 days, since any particular client could be active on many days.

**WAU** is the number of unique clients who have been a DAU on any day in the last **7 days**. Caveats above for MAU also apply to WAU.

To make the time boundaries more clear, let's consider a particular date 2019-01-28. The DAU number assigned to 2019-01-28 should consider all main pings received during 2019-01-28 UTC. We cannot observe the full data until 2019-01-28 closes (and in practice we need to wait a bit longer since we are usually referencing derived datasets like `clients_daily` that are updated once per day over several hours following midnight UTC), so the earliest we can calculate this value is on 2019-01-29. If plotted as a time series, this value should always be plotted at the point labeled 2019-01-28. Likewise, MAU for 2019-01-28 should consider a 28 day range that includes main pings received on 2019-01-28 and back to beginning of day UTC 2019-01-01. Again, the earliest we can calculate the value is on 2019-01-29.

For quick analysis, using [`firefox_desktop_exact_mau28_by_dimensions`](../datasets/bigquery/exact_mau/reference.md) is recommended. Below is an example query for getting MAU, WAU, and DAU for 2018 using `firefox_desktop_exact_mau28_by_dimensions`.

```sql
SELECT
  submission_date,
  SUM(mau) AS mau,
  SUM(wau) AS wau,
  SUM(dau) AS dau
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

For analysis of dimensions not available in `firefox_desktop_exact_mau28_by_dimensions`, using [`clients_last_seen`](../datasets/bigquery/clients_last_seen/reference.md) is recommended. Below is an example query for getting MAU, WAU, and DAU by `app_version` for 2018 using `clients_last_seen`.

```sql
SELECT
  submission_date,
  app_version,
  -- days_since_seen is always between 0 and 28, so MAU could also be
  -- calculated with COUNT(days_since_seen) or COUNT(*)
  COUNTIF(days_since_seen < 28) AS mau,
  COUNTIF(days_since_seen < 7) AS wau,
  -- days_since_* values are always between 0 and 28 or null, so DAU could also
  -- be calculated with COUNTIF(days_since_seen = 0)
  COUNTIF(days_since_seen < 1) AS dau
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

For analysis of only DAU, using [`clients_daily`](../datasets/batch_view/clients_daily/reference.md) is more efficient than `clients_last_seen`. Getting MAU and WAU from `clients_daily` is not recommended. Below is an example query for getting DAU for 2018 using `clients_daily`.

```sql
SELECT
  submission_date_s3,
  COUNT(*) AS dau
FROM
  telemetry.clients_daily
WHERE
  -- In BigQuery use yyyy-MM-DD, e.g. '2018-01-01'
  submission_date_s3 >= '20180101'
  AND submission_date_s3 < '20190101'
GROUP BY
  submission_date_s3
ORDER BY
  submission_date_s3
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
  submission_date_s3
```

## Mobile Products

The concept of usage is slightly different for mobile products compared to desktop Firefox.
A single session of desktop Firefox is likely to span multiple days and we
rely on a process to send a `main` ping once per day.
A single session of a mobile application is likely to last only a few minutes and
we have generally instrumented mobile applications to send a separate ping for
each user session:

- `core` pings are the canonical measure for usage on legacy mobile products
- `baseline` pings are the canonical measure for usage on mobile products using the Glean SDK

A given client is considered "active" for a given mobile product on a given day if we receive at
least one of the above pings. Otherwise, the definitions of DAU and MAU for individual mobile products
are identical to those used for desktop Firefox. See
[Choosing a Mobile Product Dataset](../concepts/choosing_a_dataset_mobile.md) for an
overview of the various products and which telemetry approach they use.

_Note:_ As of March 2020, Fenix (the new Firefox for Android) is using a modified definition of usage
which considers a user active for a given day based on any `baseline` or `metrics` ping
being submitted on the given day. There is an open
[proposal for Fenix KPI reporting changes](https://docs.google.com/document/d/1Ym4eZyS0WngEP6WdwJjmCoxtoQbJSvORxlQwZpuSV2I/edit?ts=5e6f894f#) to move Fenix reporting to consider only `baseline` pings.

For quick analysis, use `firefox_nondesktop_exact_mau28_by_dimensions`.
This table has a `product` dimension used to differentiate different applications.
Not that exact naming for applications and channels is sometimes different
between analyses. You can retrieve the list of names used here via query:

```sql
SELECT
  product
FROM
  `moz-fx-data-shared-prod.telemetry.firefox_nondesktop_exact_mau28_by_dimensions`
WHERE
  submission_date = '2020-03-01'
GROUP BY
  product
ORDER BY
  COUNT(*) DESC

/*
Returns:
  Fennec Android
  Fennec iOS
  Focus Android
  Fenix
  FirefoxForFireTV
  Firefox Lite
  Focus iOS
  Lockwise Android
  FirefoxConnect
*/
```

### Combining metrics from multiple products

Telemetry is collected independently for each Mozilla product.
To protect user privacy, we intentionally do not include any identifiers
that can be used to link a given client or user across multiple products.
As a result, when we consider overall "mobile MAU", we are taking a simple sum of
MAU as measured independently for each product. Analyses should keep in mind
that any given user could be contributing multiple points to MAU by sending
telemetry from multiple applications. Forecasts should also generally only be
prepared per-product for this reason.

This causes some particularly interesting effects for the case of migrating users
from one application to another as is the case with Firefox for Android in 2020.
A highly active user who migrates will go from sending multiple Fennec `core` pings per
day to sending multiple Fenix `baseline` pings per day.
On the day of migration, they will have sent pings from both applications and thus
will count towards Fennec metrics _and_ Fenix metrics. It will take a full 28 days
for the client to finally fall out of the MAU window for Fennec, so we should
expect to see inflation in the overall "mobile MAU" sum during periods of heavy
migration.
