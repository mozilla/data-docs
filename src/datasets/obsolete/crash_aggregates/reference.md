# Crash Aggregates

> As of 2018-04-02, this dataset has been deprecated and is no longer maintained. See [Bug 1388025](https://bugzilla.mozilla.org/show_bug.cgi?id=1388025) for more information.

<!-- toc -->

# Introduction

{{#include ./intro.md}}

# Data Reference

## Example Queries

Here's an example query that computes crash rates
for each channel (sorted by number of usage hours):

```sql
SELECT dimensions['channel'] AS channel,
       sum(stats['usage_hours']) AS usage_hours,
       1000 * sum(stats['main_crashes']) / sum(stats['usage_hours']) AS main_crash_rate,
       1000 * sum(stats['content_crashes']) / sum(stats['usage_hours']) AS content_crash_rate,
       1000 * sum(stats['plugin_crashes']) / sum(stats['usage_hours']) AS plugin_crash_rate,
       1000 * sum(stats['gmplugin_crashes']) / sum(stats['usage_hours']) AS gmplugin_crash_rate,
       1000 * sum(stats['gpu_crashes']) / sum(stats['usage_hours']) AS gpu_crash_rate
FROM crash_aggregates
GROUP BY dimensions['channel']
ORDER BY -sum(stats['usage_hours'])
```

Main process crashes by build date and OS version.

```sql
WITH channel_rates AS (
  SELECT dimensions['build_id'] AS build_id,
         SUM(stats['main_crashes']) AS main_crashes, -- total number of crashes
         SUM(stats['usage_hours']) / 1000 AS usage_kilohours, -- thousand hours of usage
         dimensions['os_version'] AS os_version -- os version
   FROM crash_aggregates
   WHERE dimensions['experiment_id'] is null -- not in an experiment
     AND regexp_like(dimensions['build_id'], '^\d{14}$') -- validate build IDs
     AND dimensions['build_id'] > '20160201000000' -- only in the date range that we care about
   GROUP BY dimensions['build_id'], dimensions['os_version']
)
SELECT cast(parse_datetime(build_id, 'yyyyMMddHHmmss') as date) as build_id, -- program build date
       usage_kilohours, -- thousands of usage hours
       os_version, -- os version
       main_crashes / usage_kilohours AS main_crash_rate -- crash rate being defined as crashes per thousand usage hours
FROM channel_rates
WHERE usage_kilohours > 100 -- only aggregates that have statistically significant usage hours
ORDER BY build_id ASC
```

## Sampling

### Invalid Pings

We ignore invalid pings in our processing. Invalid pings are defined as those that:

- The submission dates or activity dates are invalid or missing.
- The build ID is malformed.
- The `docType` field is missing or unknown.
- The ping is a main ping without usage hours or a crash ping with usage hours.

## Scheduling

The `crash_aggregates` job is run daily, at midnight UTC.
The job is scheduled on [Airflow](https://github.com/mozilla/telemetry-airflow).
The DAG is [here](https://github.com/mozilla/telemetry-airflow/blob/d50b938/dags/crash_aggregates.py)

## Schema

The `crash_aggregates` table has 4 commonly-used columns:

- `submission_date` is the date pings were submitted for a particular aggregate.
  - For example, `select sum(stats['usage_hours']) from crash_aggregates where submission_date = '2016-03-15'` will give the total number of user hours represented by pings submitted on March 15, 2016.
  - The dataset is partitioned by this field. Queries that limit the possible values of `submission_date` can run significantly faster.
- `activity_date` is the day when the activity being recorded took place.
  - For example, `select sum(stats['usage_hours']) from crash_aggregates where activity_date = '2016-03-15'` will give the total number of user hours represented by activities that took place on March 15, 2016.
  - This can be several days before the pings are actually submitted, so it will always be before or on its corresponding `submission_date`.
  - Therefore, queries that are sensitive to when measurements were taken on the client should prefer this field over `submission_date`.
- `dimensions` is a map of all the other dimensions that we currently care about. These fields include:
  - `dimensions['build_version']` is the program version, like `46.0a1`.
  - `dimensions['build_id']` is the `YYYYMMDDhhmmss` timestamp the program was built, like `20160123180541`. This is also known as the `build ID` or `buildid`.
  - `dimensions['channel']` is the channel, like `release` or `beta`.
  - `dimensions['application']` is the program name, like `Firefox` or `Fennec`.
  - `dimensions['os_name']` is the name of the OS the program is running on, like `Darwin` or `Windows_NT`.
  - `dimensions['os_version']` is the version of the OS the program is running on.
  - `dimensions['architecture']` is the architecture that the program was built for (not necessarily the one it is running on).
  - `dimensions['country']` is the country code for the user (determined using geoIP), like `US` or `UK`.
  - `dimensions['experiment_id']` is the identifier of the experiment being participated in, such as `e10s-beta46-noapz@experiments.mozilla.org`, or null if no experiment.
  - `dimensions['experiment_branch']` is the branch of the experiment being participated in, such as `control` or `experiment`, or null if no experiment.
  - `dimensions['e10s_enabled']` is whether E10s is enabled.
  - `dimensions['gfx_compositor']` is the graphics backend compositor used by the program, such as `d3d11`, `opengl` and `simple`. Null values may be reported as `none` as well.
  - All of the above fields can potentially be blank, which means "not present". That means that in the actual pings, the corresponding fields were null.
- `stats` contains the aggregate values that we care about:
  - `stats['usage_hours']` is the number of user-hours represented by the aggregate.
  - `stats['main_crashes']` is the number of main process crashes represented by the aggregate (or just program crashes, in the non-E10S case).
  - `stats['content_crashes']` is the number of content process crashes represented by the aggregate.
  - `stats['plugin_crashes']` is the number of plugin process crashes represented by the aggregate.
  - `stats['gmplugin_crashes']` is the number of Gecko media plugin (often abbreviated `GMPlugin`) process crashes represented by the aggregate.
  - `stats['content_shutdown_crashes']` is the number of content process crashes that were caused by failure to shut down in a timely manner.
  - `stats['gpu_crashes']` is the number of GPU process crashes represented by the aggregate.

`TODO(harter)`: https://bugzilla.mozilla.org/show_bug.cgi?id=1361862
