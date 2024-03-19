_Authored by the Data Science Team. Please direct questions/concerns to Jesse McCrosky (`jmccrosky@mozilla.com`)._

# Retention

Retention measures the proportion of users that _continue_ to use any of the browsers after sending the first ping, making it one of the most important metrics that we track at Mozilla - the expectation is that the more value our users receive from a product, the more likely they are to be retained. We commonly measure retention between releases, experiment cohorts, and various Firefox subpopulations to better understand how a change to the user experience or use of a specific feature affects the retention behavior.

### References

- Initial [Proposed Metric Definition: Retention](https://docs.google.com/document/d/1VtqNFQFB9eJNr57h3Mz-lldMcpSYQKHVn2jzMMjPFYY/).

- Proposed [Revision of Funnel Metrics](https://docs.google.com/document/d/18QGa4JYbDP35IywH3zGftCgejrd8aGnbft_L2oxp1Ao/edit#heading=h.rl9rub54j6oj) implemented in H2-2023.

## Metric definitions

### Repeat First Month Users

New profiles who used the browser more than one day in their first 28-day window. The inclusion of this metric guarantees us monotonically decreasing flow (that week 4 retention is either smaller than or equal to multi-day users) and also has backward compatibility with week 4 retention (every member of the 4 week retention cohort is a member of the multi-day users cohort). It also covers more users than activation to make the opportunity size valuable than activation.

### Week 4 Retention

Used the browser at least once between days 22-28.

### Activated User

For Desktop, a new user becomes an activated user when they have used the browser at least 5 times in their first 7 days. For mobile, a new user becomes an activated user when they have used the browser for at least 3 days (including the first day of app open) in their first week and performed a search in the latter half of their first week.

## Accessing Retention Metrics

There are three standard methods for accessing retention metrics. These methods trade off between simplicity and flexibility.

### Funnel Dashboards with Retention analysis

- Mobile retention can be analyzed in the [Fenix Funnel](https://mozilla.cloud.looker.com/dashboards/1470) and [iOS Funnel](https://mozilla.cloud.looker.com/dashboards/1314?Country=&YoY+control+%28Do+not+change%29+=before+28+days+ago&Date=2023%2F01%2F01+to+2023%2F10%2F18) dashboards.

- Desktop retention is available in the [Desktop Moz.org Funnel (Windows)](https://mozilla.cloud.looker.com/dashboards/duet::desktop_moz_org_funnel_windows?Analysis%20Period=90%20day&Countries=US,GB,DE,FR,CA,BR,MX,CN,IN,AU,NL,ES,RU,ROW&Include%20Dates%20Where=data%20complete).

### Querying Aggregate Tables

For programmatic access, the views underlying the dashboards can be queried directly. For example:

```sql
SELECT
  first_seen_date AS submission_date,
  country_code,
  SUM(CASE WHEN qualified_week4 = TRUE THEN 1 ELSE 0 END) AS retained_week4
FROM `mozdata.telemetry.clients_first_seen_28_days_later`
WHERE first_seen_date >= '2024-01-01'
  AND DATE_DIFF(current_date(), first_seen_date, DAY) > 1
GROUP BY 1, 2;
```

### Querying Clients Daily Tables

Another option for more custom access, e.g. to see retention in the first week, is to use the `clients_last_seen tables`. You can restrict to an arbitrary population of users by joining the `base` table below against a table containing the `client_id`s of interest.

```sql
WITH base AS (
  SELECT
    client_id,
    DATE_SUB(submission_date, INTERVAL 13 DAY) AS date,
    COUNTIF(udf.bitpos(days_created_profile_bits) = 13) AS new_profiles,
          COUNTIF(udf.active_n_weeks_ago(days_seen_bits, 1)) AS active_in_week_0,
          COUNTIF(udf.active_n_weeks_ago(days_seen_bits, 1)
            AND udf.active_n_weeks_ago(days_seen_bits, 0))
            AS active_in_weeks_0_and_1,
          COUNTIF(udf.bitpos(days_created_profile_bits) = 13 AND udf.active_n_weeks_ago(days_seen_bits, 0)) AS new_profile_active_in_week_1
  FROM
    telemetry.clients_last_seen
GROUP BY client_id, submission_date
)

SELECT
  SAFE_DIVIDE(SUM(new_profile_active_in_week_1), SUM(new_profiles)) AS one_week_new_profile_retention,
  SAFE_DIVIDE(SUM(active_in_weeks_0_and_1), SUM(active_in_week_0)) AS one_week_retention
FROM
  base
WHERE date = "2019-12-01"
```

### Simplified View for 1-week Retention

You can also use the simplified `desktop_retention_1_week` view. This still supports restriction to an arbitrary population of users by joining against a table containing the `client_id`s of interest.

```sql
SELECT
  AVG(IF(retained, 1, 0)) AS retention
FROM
  `moz-fx-data-shared-prod.telemetry.desktop_retention_1_week`
RIGHT JOIN
  my_cohort_t
  USING (client_id)
WHERE
  date BETWEEN "2020-03-01" AND "2020-03-07"
GROUP BY
  date
```

## Confounding Factors

When performing retention analysis it is important to understand that there are many reasons for retention differences between groups. Unless you are comparing two arms of a controlled experiment, in which case you can probably attribute any difference to the experimental treatment, it is impossible to make causal arguments about retention differences. For example, if you observe the users that save a large number of bookmarks tend to have higher retention than those who do not, it is more likely that the retention difference is simply a property of _the types of people_ that save bookmarks, and an intervention to encourage saving more bookmarks is not necessarily likely to improve retention.

## Confidence Intervals

It is good practice to always compute confidence intervals for retention metrics, especially when looking at specific slices of users or when making comparisons between different groups.

### Querying Clients Daily Tables

```sql
WITH base AS (
  SELECT
    client_id,
    MOD(ABS(FARM_FINGERPRINT(MD5(client_id))), 20) AS id_bucket,
    DATE_SUB(submission_date, INTERVAL 13 DAY) AS date,
    COUNTIF(udf.bitpos(days_created_profile_bits) = 13) AS new_profiles,
          COUNTIF(udf.active_n_weeks_ago(days_seen_bits, 1)) AS active_in_week_0,
          COUNTIF(udf.active_n_weeks_ago(days_seen_bits, 1)
            AND udf.active_n_weeks_ago(days_seen_bits, 0))
            AS active_in_weeks_0_and_1,
          COUNTIF(udf.bitpos(days_created_profile_bits) = 13 AND udf.active_n_weeks_ago(days_seen_bits, 0)) AS new_profile_active_in_week_1
  FROM
    telemetry.clients_last_seen
  -- We need to "rewind" 13 days since retention is forward-looking;
  -- we calculate retention for "day 0" based on clients_last_seen data from "day 13".
  WHERE DATE_SUB(submission_date, INTERVAL 13 DAY) = "2019-10-01"
  GROUP BY client_id, submission_date
),

bucketed AS (
  SELECT
    date,
    -- There are many options for hashing client_ids into buckets;
    -- the below is an easy option using native BigQuery SQL functions;
    -- see discussion in https://github.com/mozilla/bigquery-etl/issues/36
    MOD(ABS(FARM_FINGERPRINT(client_id)), 20) AS id_bucket,
    SUM(active_in_weeks_0_and_1) AS active_in_weeks_0_and_1,
    SUM(active_in_week_0) AS active_in_week_0
  FROM
    base
  WHERE
    id_bucket IS NOT NULL
  GROUP BY
    date,
    id_bucket
)

SELECT
  `date`,
  udf_js.jackknife_ratio_ci(20, ARRAY_AGG(STRUCT(CAST(active_in_weeks_0_and_1 AS float64), CAST(active_in_week_0 as FLOAT64)))) AS one_week_retention
FROM bucketed
GROUP BY `date` ORDER BY `date`
```
