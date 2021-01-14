_Authored by the Data Science Team. Please direct questions/concerns to Jesse McCrosky (`jmccrosky@mozilla.com`)._

# Retention

Retention measures the proportion of users that are _continuing_ to use Firefox, making it one of the more important metrics we track - we generally expect that the more value our users receive from the product, the more likely they are to be retained. We commonly measure retention between releases, experiment cohorts, and various Firefox subpopulations to better understand how a change to the user experience or use of a specific feature affects retention behavior.

## State of Retention

There is currently active research into retention metrics and we expect our conceptual and data model around retention to evolve in the coming months. This page will be updated. However, in the meantime, we want to be clear about our standard retention metrics for use right now.

You can also see the [_Proposed Metric Definition: Retention_ Google Doc](https://docs.google.com/document/d/1VtqNFQFB9eJNr57h3Mz-lldMcpSYQKHVn2jzMMjPFYY/) for a summary of our conceptual thinking about retention metrics.

## Standard Retention metrics

Note that the definitions below refer to "usage criterion". See the [GUD Data Model documentation](https://docs.google.com/document/d/1sIHCCaJhtfxj-dnbInfuIjlMRhCFbEhFiBESaezIRwM/edit#heading=h.ysqpvceb7pgt) for more information. For normal Firefox Desktop retention, the usage criterion refers to simply sending any main ping.

### 1-Week Retention

Among profiles that were active in the specified usage criterion at least once in the week starting on the specified day (day 0), what proportion (out of 1) meet the usage criterion during the following week (days 7 through 13).

### 1-Week New Profile Retention

Among new profiles created on the day specified, what proportion (out of 1) meet the usage criterion during the week beginning one week after the day specified.

Note that we use a new profile definition that relies on the `profile_creation_date` and requires that a main ping be sent within one week of the `profile_creation_date`. This differs from analysis using new profile pings, but allows valid comparison over time. New profile pings do not allow comparison over time due to the increased adoption of versions of the browser recent enough to send new profile pings.

## Accessing Retention Metrics

There are three standard methods for accessing retention metrics. These methods trade off between simplicity and flexibility.

### Mozilla Growth & Usage Dashboard (GUD)

The [GUD](https://gud.telemetry.mozilla.org/) provides plots and exportable tables of both retention metrics over time. Metrics are available for most products and can be sliced by OS, language, country, and channel.

### Querying Smoot Usage Tables

For programmatic access, the tables underlying GUD can be queried directly. For example:

```sql
SELECT
  `date`,
  SAFE_DIVIDE(SUM(new_profile_active_in_week_1), SUM(new_profiles)) AS one_week_new_profile_retention,
  SAFE_DIVIDE(SUM(active_in_weeks_0_and_1), SUM(active_in_week_0)) AS one_week_retention
FROM `moz-fx-data-shared-prod.telemetry.smoot_usage_day_13`
WHERE
  usage = 'Any Firefox Desktop Activity'
  AND country IN ('US', 'GB', 'CA', 'FR', 'DE')
  AND `date` BETWEEN "2019-11-01" AND "2019-11-07"
GROUP BY `date` ORDER BY `date`
```

### Querying Clients Daily Tables

For more custom access, use the `clients_last_seen tables`. You can restrict to an arbitrary population of users by joining the `base` table below against a table containing the `client_id`s of interest.

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
USING
  (client_id)
WHERE
  date BETWEEN "2020-03-01" AND "2020-03-07"
GROUP BY
  date
```

## Confounding Factors

When performing retention analysis it is important to understand that there are many reasons for retention differences between groups. Unless you are comparing two arms of a controlled experiment, in which case you can probably attribute any difference to the experimental treatment, it is impossible to make causal arguments about retention differences. For example, if you observe the users that save a large number of bookmarks tend to have higher retention than those who do not, it is more likely that the retention difference is simply a property of _the types of people_ that save bookmarks, and an intervention to encourage saving more bookmarks is not necessarily likely to improve retention.

## Confidence Intervals

It is good practice to always compute confidence intervals for retention metrics, especially when looking at specific slices of users or when making comparisons between different groups.

The [Growth and Usage Dashboard](https://gud.telemetry.mozilla.org/) provides confidence intervals automatically using a jackknife resampling method over `client_id` buckets. This confidence intervals generated using this method should be considered the "standard". We show below how to compute them using the data sources described above. These methods use UDFs [defined in bigquery-etl](https://github.com/mozilla/bigquery-etl/blob/master/sql/moz-fx-data-shared-prod/udf_js/jackknife_ratio_ci/udf.sql).

We also note that it is fairly simple to calculate a confidence interval using any statistical method appropriate for proportions. The queries given above provide both numerators and denominators, so feel free to calculate confidence intervals in the manner you prefer. However, if you want to replicate the standard confidence intervals, please work from the example queries below.

### Querying Smoot Usage Tables

```sql
WITH bucketed AS (
  SELECT
    `date`,
    id_bucket,
    SUM(new_profile_active_in_week_1) AS new_profile_active_in_week_1,
    SUM(new_profiles) AS new_profiles
  FROM `moz-fx-data-shared-prod.telemetry.smoot_usage_day_13`
  WHERE
    usage = 'Any Firefox Desktop Activity'
    AND country IN ('US', 'GB', 'CA', 'FR', 'DE')
    AND `date` BETWEEN "2019-11-01" AND "2019-11-07"
  GROUP BY `date`, id_bucket
)

SELECT
  `date`,
  udf_js.jackknife_ratio_ci(20, ARRAY_AGG(STRUCT(CAST(new_profile_active_in_week_1 AS float64), CAST(new_profiles as FLOAT64)))) AS one_week_new_profile_retention
FROM bucketed
GROUP BY `date` ORDER BY `date`
```

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
