*Authored by the Data Science Team. Please direct questions/concerns to Jesse McCrosky (`jmccrosky@mozilla.com`).*

# Retention

Retention measures the proportion of users that are *continuing* to use Firefox, making it one of the more important metrics we track - we generally expect that the more value our users receive from the product, the more likely they are to be retained. We commonly measure retention between releases, experiment cohorts, and various Firefox subpopulations to better understand how a change to the user experience or use of a specific feature affects retention behavior.

## State of Retention

There is currently active research into retention metrics and we expect our conceptual and data model around retention to evolve in the coming months.  This page will be updated.  However, in the meantime, we want to be clear about our standard retention metrics for use right now.

You can also see the [_Proposed Metric Definition: Retention_ Google Doc](https://docs.google.com/document/d/1VtqNFQFB9eJNr57h3Mz-lldMcpSYQKHVn2jzMMjPFYY/) for a summary of our conceptual thinking about retention metrics.

## Standard Retention metrics

Note that the definitions below refer to "usage criterion".  See the [GUD Data Model documentation](https://docs.google.com/document/d/1sIHCCaJhtfxj-dnbInfuIjlMRhCFbEhFiBESaezIRwM/edit#heading=h.ysqpvceb7pgt) for more information.  For normal Firefox Desktop retention, the usage criterion refers to simply sending any main ping.

### 1-Week Retention

Among profiles that were active in the specified usage criterion at least once in the week starting on the specified day (day 0), what proportion (out of 1) meet the usage criterion during the following week (days 7 through 13).

### 1-Week New Profile Retention

Among new profiles created on the day specified, what proportion (out of 1) meet the usage criterion during the week beginning one week after the day specified.

Note that we use a new profile definition that relies on the `profile_creation_date` and requires that a main ping be sent within one week of the `profile_creation_date`.  This differs from analysis using new profile pings, but allows valid comparison over time. New profile pings do not allow comparison over time due to the increased adoption of versions of the browser recent enough to send new profile pings.

## Accessing Retention Metrics

There are three standard methods for accessing retention metrics.  These methods trade off between simplicity and flexibility.

### Mozilla Growth & Usage Dashboard (GUD)

The [GUD](https://growth-stage.bespoke.nonprod.dataops.mozgcp.net/) provides plots and exportable tables of both retention metrics over time.  Metrics are available for most products and can be sliced by OS, language, country, and channel.

### Querying Smoot Usage Tables

For programatic access, the tables underlying GUD can be queried directly.  For example:

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

For more custom access, you use the clients_last_seen tables.  You can restrict to an arbitrary population of users by joining the `base` table below against a table containing the `client_id`s of interest.

```sql
CREATE TEMP FUNCTION
  udf_active_n_weeks_ago(x INT64, n INT64)
  RETURNS BOOLEAN
  AS (
    BIT_COUNT(x >> (7 * n) & (0x7F)) > 0
  );
CREATE TEMP FUNCTION
  udf_bitpos( bits INT64 ) AS ( CAST(SAFE.LOG(bits & -bits, 2) AS INT64));

WITH base AS (
  SELECT
    client_id,
    DATE_SUB(submission_date, INTERVAL 13 DAY) AS date,
    COUNTIF(udf_bitpos(days_created_profile_bits) = 13) AS new_profiles,
          COUNTIF(udf_active_n_weeks_ago(days_seen_bits, 1)) AS active_in_week_0,
          COUNTIF(udf_active_n_weeks_ago(days_seen_bits, 1)
            AND udf_active_n_weeks_ago(days_seen_bits, 0))
            AS active_in_weeks_0_and_1,
          COUNTIF(udf_bitpos(days_created_profile_bits) = 13 AND udf_active_n_weeks_ago(days_seen_bits, 0)) AS new_profile_active_in_week_1
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

## Confounding Factors

When performing retention analysis it is important to understand that there are many reasons for retention differences between groups.  Unless you are comparing two arms of a controlled experiment, in which case you can probably attribute any difference to the experimental treatment, it is impossible to make causal arguments about retention differences.  For example, if you observe the users that save a large number of bookmarks tend to have higher retention than those who do not,  it is more likely that the retention difference is simply a property of *the types of people* that save bookmarks, and an intervention to encourage saving more bookmarks is not necessarily likely to improve retention.
