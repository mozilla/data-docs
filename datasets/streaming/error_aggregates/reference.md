# Error Aggregates Reference

<!-- toc -->

# Introduction

{% include "./intro.md" %}

# Data Reference

## Example Queries

Getting a large number of different crash measures across many platforms and channels
([view on redash](https://sql.telemetry.mozilla.org/queries/4769/source)):

```sql
SELECT window_start,
       build_id,
       channel,
       os_name,
       version,
       sum(usage_hours) AS usage_hours,
       sum(main_crashes) AS main,
       sum(content_crashes) AS content,
       sum(gpu_crashes) AS gpu,
       sum(plugin_crashes) AS plugin,
       sum(gmplugin_crashes) AS gmplugin
FROM telemetry.error_aggregates
  WHERE application = 'Firefox' 
  AND (os_name = 'Darwin' or os_name = 'Linux' or os_name = 'Windows_NT')
  AND (channel = 'beta' or channel = 'release' or channel = 'nightly' or channel = 'esr')
  AND build_id > '201801'
  AND window_start > current_timestamp - (1 * interval '24' hour)
GROUP BY window_start, channel, build_id, version, os_name
```


Get the number of main_crashes on Windows over a small interval
([view on redash](https://sql.telemetry.mozilla.org/queries/51677)):

```sql
SELECT window_start as time, sum(main_crashes) AS main_crashes
FROM telemetry.error_aggregates_v1
  WHERE application = 'Firefox'
  AND os_name = 'Windows_NT'
  AND channel = 'release'
  AND version = '58.0.2'
  AND window_start > timestamp '2018-02-21'
  AND window_end < timestamp '2018-02-22'
GROUP BY window_start
```

## Sampling

### Data sources

The aggregates in this data source are derived from main and crash [pings](../../pings.md).
Crash pings are only used to count/gather main crash events, all other errors (including all other crashes) are gathered from main pings.

## Scheduling

The `error_aggregates` job is run continously, using the spark streaming infrastructure

## Schema

The `error_aggregates` table has the following columns which define its dimensions:

* `window_start`: Beginning of interval when this sample was taken
* `window_end`: End of interval when this sample was taken (will always be 5 minutes more
  than `window_start` for any given row)
* `channel`: the channel, like `release` or `beta`
* `version`: the version e.g. `57.0.1`
* `display_version`: like version, but includes beta number if applicable e.g. `57.0.1b4`
* `build_id`: the YYYYMMDDhhmmss timestamp the program was built, like `20160123180541`. This is also known as the "build ID" or "buildid"
* `application`: application name (e.g. `Firefox`)
* `os_name`: name of the OS (e.g. `Darwin` or `Windows_NT`)
* `os_version`: version of the OS
* `country`: country code for the user (determined using geoIP), like `US` or `UK`
* `experiment_id`: identifier of the experiment being participated in, such as `e10s-beta46-noapz@experiments.mozilla.org`, or null if no experiment
* `experiment_branch`: the branch of the experiment being participated in, such as `control` or `experiment`, or null if no experiment
* `e10s_enabled`: whether e10s is enabled
* `gfx_compositor`: the graphics backend compositor used by the program, such as `d3d11`, `opengl` and `simple`. Null values may be reported as `none` as well
* `quantum_ready`: whether the ping was submitted from an instance of Firefox that was Quantum-ready (i.e. no old-style add-ons)

And these are the various measures we are counting:

* `usage_hours`: number of usage hours (i.e. total number of hours of usage reported by the pings in this aggregate)
* `main_crashes`: number of main process crashes (or just program crashes, in the non-e10s case)
* `content_crashes`: number of content process crashes
* `plugin_crashes`: number of plugin process crashes
* `gmplugin_crashes`: number of Gecko media plugin (often abbreviated GMPlugin) process crashes
* `content_shutdown_crashes`: number of content process crashes that were caused by failure to shut down in a timely manner (should always be
  less than the number of `content_crashes`)
* `gpu_crashes`: number of gpu process crashes
* `browser_shim_usage_blocked`: number of times a CPOW shim was blocked from being created by browser code
* `permissions_sql_corrupted`: number of times the permissions SQL error occurred (beta/nightly only)
* `defective_permissions_sql_removed`: number of times there was a removal of defective permissions.sqlite (beta/nightly only)
* `slow_script_notice_count`: number of times the slow script notice count was shown (beta/nightly only)
* `slow_script_page_count`: number of pages that trigger slow script notices (beta/nightly only)
