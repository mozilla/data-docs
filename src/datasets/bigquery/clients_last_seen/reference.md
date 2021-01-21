# Clients Last Seen Reference

<!-- toc -->

# Introduction

{{#include ./intro.md}}

#### Content

For each `submission_date` this dataset contains one row per `client_id`
that appeared in `clients_daily` in a 28 day window including
`submission_date` and preceding days.

The `days_since_seen` column indicates the difference between `submission_date`
and the most recent `submission_date` in `clients_daily` where the `client_id`
appeared. A client observed on the given `submission_date` will have `days_since_seen = 0`.

Other `days_since_` columns use the most recent date in `clients_daily` where
a certain condition was met. If the condition was not met for a `client_id` in
a 28 day window `NULL` is used. For example `days_since_visited_5_uri` uses the
condition `scalar_parent_browser_engagement_total_uri_count_sum >= 5`. These
columns can be used for user counts where a condition must be met on any day
in a window instead of using the most recent values for each `client_id`.

The `days_seen_bits` field stores the daily history of a client in the 28 day
window. The daily history is converted into a sequence of bits, with a `1` for
the days a client is in `clients_daily` and a `0` otherwise, and this sequence
is converted to an integer. A tutorial on how to use these bit patterns to
create filters in SQL can be found in
[this notebook](https://colab.research.google.com/drive/13AwwORpOtRsq22op_3rMSwPssQkJU1ok).

The rest of the columns use the most recent value in `clients_daily` where
the `client_id` appeared.

#### Background and Caveats

User counts generated using `days_since_seen` only reflect the most recent
values from `clients_daily` for each `client_id` in a 28 day window. This means
[Active MAU](../../../cookbooks/active_dau.md)
as defined cannot be efficiently calculated using `days_since_seen` because if
a given `client_id` appeared every day in February and only on February 1st had
`scalar_parent_browser_engagement_total_uri_count_sum >= 5` then it would only
be counted on the 1st, and not the 2nd-28th. Active MAU can be efficiently and
correctly calculated using `days_since_visited_5_uri`.

MAU can be calculated over a `GROUP BY submission_date[, ...]` clause using
`COUNT(*)`, because there is exactly one row in the dataset for each
`client_id` in the 28 day MAU window for each `submission_date`.

User counts generated using `days_since_seen` can use `SUM` to reduce groups,
because a given `client_id` will only be in one group per `submission_date`. So
if MAU were calculated by `country` and `channel`, then the sum of the MAU for
each `country` would be the same as if MAU were calculated only by `channel`.

#### Accessing the Data

The data is available in Re:dash and BigQuery. Take a look at this full running
[example query in Re:dash](https://sql.telemetry.mozilla.org/queries/62029/source#159510).

# Data Reference

## Field Descriptions

The [`*_bits` fields](../../../cookbooks/clients_last_seen_bits.md) store the relevant activity of a client in a 28 day
window, as a 28 bit integer.
For each bit, a 1 corresponds to the specific activity occurring on that day.

### Activity Segment/User State/Core Active Specific

Please see this [section](../../../concepts/segments.md) for descriptions regarding user states/segments.

- `is_core_active_v1`: Boolean indicating if the client satisfies conditions of being core active on that day.
- `activity_segments_v1`: The activity segment applicable to the client that day.
- `is_regular_user_v3`: Boolean indicating if the client satisfies conditions of being a regular user on that day.
- `is_new_or_resurrected_v3`: Boolean indicating if the client satisfies conditions of being a regular user on that day.
- `is_weekday_regular_v1`: Boolean indicating if the client satisfies conditions of being a weekday regular user on that day.
- `is_allweek_regular_v1`: Boolean indicating if the client satisfies conditions of being an all-week regular user on that day.

### Usage Specific

- `days_visited_1_uri_bits`: Each bit field represents if a client browsed at least 1 URI on that day.
- `days_since_visited_1_uri`: Number of days since the client browsed at least 1 URI.
- `days_interacted_bits`: Each bit field represents if a client had at least 1 active tick on that day.
  This is derived from the `active_hours_sum` in `clients_daily`.
- `days_since_interacted`: Number of days since the clients had at least 1 active tick.
- `days_had_8_active_ticks_bits`: Each bit field represents if a client had at least 8 active ticks on that day.
  This can be used to approximate the threshold of 1 URI, and is useful for determining activity for clients using
  Private Browsing Mode where URI counts are not recorded.
- `days_since_visited_8_active_ticks`: Number of days since the client had at least 8 active ticks.

### New Profile Specific

- `first_seen_date`: Date the client sent their first main ping.
- `second_seen_date`: Date the client sent their first main ping.
- `days_since_first_seen`: Number of days since `first_seen_date`
- `days_since_second_seen`: Number of days since `second_seen_date`
- `new_profile_5_day_activated_v1`: Boolean indicating if a new profile has sent a ping 5 out of their first 7 days.
- `new_profile_14_day_activated_v1`: Boolean indicating if a new profile has sent a ping 8 out of their first 14 days.
- `new_profile_21_day_activated_v1`: Boolean indicating if a new profile has sent a ping 12 out of their first 21 days.
- `days_since_created_profile`: Number of days since the profile creation date. This field is only populated when the
  value is 27 days or less. Otherwise, it is NULL. `profile_age_in_days` can be used in the latter cases for all clients
  who have a profile creation date.

## Example Queries

#### Compute DAU for non-windows clients for the last week

```sql
SELECT
    submission_date,
    os,
    COUNT(*) AS count
FROM
    mozdata.telemetry.clients_last_seen
WHERE
    submission_date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 WEEK)
    AND days_since_seen = 0
GROUP BY
    submission_date,
    os
HAVING
    count > 10 -- remove outliers
    AND lower(os) NOT LIKE '%windows%'
ORDER BY
    os,
    submission_date DESC
```

#### Compute WAU by Channel for the last week

```sql
SELECT
    submission_date,
    normalized_channel,
    COUNT(*) AS count
FROM
    mozdata.telemetry.clients_last_seen
WHERE
    submission_date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 WEEK)
    AND days_since_seen < 7
GROUP BY
    submission_date,
    normalized_channel
HAVING
    count > 10 -- remove outliers
ORDER BY
    normalized_channel,
    submission_date DESC
```

## Scheduling

This dataset is updated daily via the
[telemetry-airflow](https://github.com/mozilla/telemetry-airflow)
infrastructure. The job runs as part of the
[`main_summary` DAG](https://github.com/mozilla/bigquery-etl/blob/ad84a15d580333b41d36cfe8331e51238f3bafa1/dags/bqetl_main_summary.py#L104).

## Schema

The data is partitioned by `submission_date`.

As of 2019-03-25, the current version of the `clients_last_seen` dataset is
`v1`, and the schema is visible in the BigQuery console
[here](https://console.cloud.google.com/bigquery?p=mozdata&d=telemetry&t=clients_last_seen_v1&page=table).

# Code Reference

This dataset is generated by
[`bigquery-etl`](https://github.com/mozilla/bigquery-etl/blob/master/sql/moz-fx-data-shared-prod/telemetry_derived/clients_last_seen_v1/query.sql).
Refer to this repository for information on how to run or augment the dataset.
