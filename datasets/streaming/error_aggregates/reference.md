# Error Aggregates Reference

<!-- toc -->

# Introduction

{% include "./intro.md" %}

# Data Reference

## Sampling

### Invalid Pings

We ignore invalid pings in our processing. Invalid pings are defined as those that:

* The submission dates or activity dates are invalid or missing.
* The build ID is malformed.
* The docType field is missing or unknown.
* The ping does not include a positive count of usage hours.

## Scheduling

The `error_aggregates` job is run continously, using the spark streaming infrastructure

## Schema

The `error_aggregates` table has the following columns which define its dimensions:

* `window_start`: Beginning of time when this sample was taken
* `window_end`: End of time when this sample was taken (will always be 5 minutes more
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

* `usage_hours`: number of user-hours represented by the aggregate
* `main_crashes`: number of main process crashes represented by the aggregate (or just program crashes, in the non-E10S case)
* `content_crashes`: number of content process crashes represented by the aggregate
* `plugin_crashes`: number of plugin process crashes represented by the aggregate
* `gmplugin_crashes`: number of Gecko media plugin (often abbreviated GMPlugin) process crashes represented by the aggregate
* `content_shutdown_crashes`: number of content process crashes that were caused by failure to shut down in a timely manner
* `gpu_crashes`: number of gpu process crashes
* `browser_shim_usage_blocked`: number of times a CPOW shim was blocked from being created by browser code
* `permissions_sql_corrupted`: number of times the permissions SQL error occurred (beta/nightly only)
* `defective_permissions_sql_removed`: number of times there was a removal of defective permissions.sqlite (beta/nightly only)
* `slow_script_notice_count`: number of times the slow script notice count was shown (beta/nightly only)
* `
The `error_aggregates` table has the following columns which define its dimensions:

* `window_start`: Beginning of time when this sample was taken
* `window_end`: End of time when this sample was taken (will always be 5 minutes more
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

* `usage_hours`: number of user-hours
* `main_crashes`: number of main process crashes (or just program crashes, in the non-E10S case)
* `content_crashes`: number of content process crashes
* `plugin_crashes`: number of plugin process crashes
* `gmplugin_crashes`: number of Gecko media plugin (often abbreviated GMPlugin) process crashes
* `content_shutdown_crashes`: number of content process crashes that were caused by failure to shut down in a timely manner
* `gpu_crashes`: number of gpu process crashes
* `browser_shim_usage_blocked`: number of times a CPOW shim was blocked from being created by browser code
* `permissions_sql_corrupted`: number of times the permissions SQL error occurred (beta/nightly only)
* `defective_permissions_sql_removed`: number of times there was a removal of defective permissions.sqlite (beta/nightly only)
* `slow_script_notice_count`: number of times the slow script notice count was shown (beta/nightly only)
* `slow_script_page_count`: number of pages that trigger slow script notices (beta/nightly only)