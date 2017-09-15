# Main Summary

<!-- toc -->

# Introduction

{% include "./intro.md" %}

# Data Reference

## Example Queries

We recommend working with this dataset via Spark rather than sql.t.m.o.
Due to the large number of records, 
queries can consume a lot of resources on the 
**shared cluster and impact other users**.
Queries via sql.t.m.o should limit to a short `submission_date_s3` range,
and ideally make use of the `sample_id` field.

When using Presto to query the data from sql.t.m.o,
you can use the UNNEST feature to access items in the 
`search_counts`, `popup_notification_stats` and `active_addons` fields.

For example, to compare the search volume for different search source values,
you could use:
```sql
WITH search_data AS
  (SELECT s.source AS search_source,
          s.count AS search_count
   FROM main_summary CROSS JOIN UNNEST(search_counts) AS t(s)
   WHERE submission_date_s3 = '20160510'
     AND sample_id = '42'
     AND search_counts IS NOT NULL)
SELECT search_source, sum(search_count) as total_searches
FROM search_data
GROUP BY search_source
ORDER BY sum(search_count) DESC
```

## Sampling

The `main_summary` dataset contains one record for each `main` ping
as long as the record contains a non-null value for 
`documentId`, `submissionDate`, and `Timestamp`.
We do not ever expect nulls for these fields.

## Scheduling

This dataset is updated daily via the [telemetry-airflow](https://github.com/mozilla/telemetry-airflow) infrastructure.
The job DAG runs every day shortly after midnight UTC.
You can find the job definition
[here](https://github.com/mozilla/telemetry-airflow/blob/master/dags/main_summary.py)

## Schema

As of 2016-07-05, the current version of the `main_summary` dataset is `v3`, and has a schema as follows:

```
root
 |-- document_id: string (nullable = true)
 |-- client_id: string (nullable = true)
 |-- channel: string (nullable = true)
 |-- normalized_channel: string (nullable = true)
 |-- country: string (nullable = true)
 |-- city: string (nullable = true)
 |-- os: string (nullable = true)
 |-- os_version: string (nullable = true)
 |-- os_service_pack_major: long (nullable = true)
 |-- os_service_pack_minor: long (nullable = true)
 |-- windows_build_number: long (nullable = true)
 |-- windows_ubr: long (nullable = true)
 |-- install_year: long (nullable = true)
 |-- profile_creation_date: long (nullable = true)
 |-- subsession_start_date: string (nullable = true)
 |-- subsession_length: long (nullable = true)
 |-- distribution_id: string (nullable = true)
 |-- submission_date: string (nullable = true)
 |-- sync_configured: boolean (nullable = true)
 |-- sync_count_desktop: integer (nullable = true)
 |-- sync_count_mobile: integer (nullable = true)
 |-- app_build_id: string (nullable = true)
 |-- app_display_version: string (nullable = true)
 |-- app_name: string (nullable = true)
 |-- app_version: string (nullable = true)
 |-- timestamp: long (nullable = true)
 |-- env_build_id: string (nullable = true)
 |-- env_build_version: string (nullable = true)
 |-- env_build_arch: string (nullable = true)
 |-- e10s_enabled: boolean (nullable = true)
 |-- e10s_cohort: string (nullable = true)
 |-- locale: string (nullable = true)
 |-- active_experiment_id: string (nullable = true)
 |-- active_experiment_branch: string (nullable = true)
 |-- reason: string (nullable = true)
 |-- timezone_offset: integer (nullable = true)
 |-- plugin_hangs: integer (nullable = true)
 |-- aborts_plugin: integer (nullable = true)
 |-- aborts_content: integer (nullable = true)
 |-- aborts_gmplugin: integer (nullable = true)
 |-- crashes_detected_plugin: integer (nullable = true)
 |-- crashes_detected_content: integer (nullable = true)
 |-- crashes_detected_gmplugin: integer (nullable = true)
 |-- crash_submit_attempt_main: integer (nullable = true)
 |-- crash_submit_attempt_content: integer (nullable = true)
 |-- crash_submit_attempt_plugin: integer (nullable = true)
 |-- crash_submit_success_main: integer (nullable = true)
 |-- crash_submit_success_content: integer (nullable = true)
 |-- crash_submit_success_plugin: integer (nullable = true)
 |-- shutdown_kill: integer (nullable = true)
 |-- active_addons_count: long (nullable = true)
 |-- flash_version: string (nullable = true)
 |-- vendor: string (nullable = true)
 |-- is_default_browser: boolean (nullable = true)
 |-- default_search_engine_data_name: string (nullable = true)
 |-- default_search_engine: string (nullable = true)
 |-- loop_activity_counter: struct (nullable = true)
 |    |-- open_panel: integer (nullable = true)
 |    |-- open_conversation: integer (nullable = true)
 |    |-- room_open: integer (nullable = true)
 |    |-- room_share: integer (nullable = true)
 |    |-- room_delete: integer (nullable = true)
 |-- devtools_toolbox_opened_count: integer (nullable = true)
 |-- client_submission_date: string (nullable = true)
 |-- places_bookmarks_count: integer (nullable = true)
 |-- places_pages_count: integer (nullable = true)
 |-- push_api_notify: integer (nullable = true)
 |-- web_notification_shown: integer (nullable = true)
 |-- popup_notification_stats: map (nullable = true)
 |    |-- key: string
 |    |-- value: struct (valueContainsNull = true)
 |    |    |-- offered: integer (nullable = true)
 |    |    |-- action_1: integer (nullable = true)
 |    |    |-- action_2: integer (nullable = true)
 |    |    |-- action_3: integer (nullable = true)
 |    |    |-- action_last: integer (nullable = true)
 |    |    |-- dismissal_click_elsewhere: integer (nullable = true)
 |    |    |-- dismissal_leave_page: integer (nullable = true)
 |    |    |-- dismissal_close_button: integer (nullable = true)
 |    |    |-- dismissal_not_now: integer (nullable = true)
 |    |    |-- open_submenu: integer (nullable = true)
 |    |    |-- learn_more: integer (nullable = true)
 |    |    |-- reopen_offered: integer (nullable = true)
 |    |    |-- reopen_action_1: integer (nullable = true)
 |    |    |-- reopen_action_2: integer (nullable = true)
 |    |    |-- reopen_action_3: integer (nullable = true)
 |    |    |-- reopen_action_last: integer (nullable = true)
 |    |    |-- reopen_dismissal_click_elsewhere: integer (nullable = true)
 |    |    |-- reopen_dismissal_leave_page: integer (nullable = true)
 |    |    |-- reopen_dismissal_close_button: integer (nullable = true)
 |    |    |-- reopen_dismissal_not_now: integer (nullable = true)
 |    |    |-- reopen_open_submenu: integer (nullable = true)
 |    |    |-- reopen_learn_more: integer (nullable = true)
 |-- search_counts: array (nullable = true)
 |    |-- element: struct (containsNull = true)
 |    |    |-- engine: string (nullable = true)
 |    |    |-- source: string (nullable = true)
 |    |    |-- count: long (nullable = true)
 |-- active_addons: array (nullable = true)
 |    |-- element: struct (containsNull = true)
 |    |    |-- addon_id: string (nullable = true)
 |    |    |-- blocklisted: boolean (nullable = true)
 |    |    |-- name: string (nullable = true)
 |    |    |-- user_disabled: boolean (nullable = true)
 |    |    |-- app_disabled: boolean (nullable = true)
 |    |    |-- version: string (nullable = true)
 |    |    |-- scope: integer (nullable = true)
 |    |    |-- type: string (nullable = true)
 |    |    |-- foreign_install: boolean (nullable = true)
 |    |    |-- has_binary_components: boolean (nullable = true)
 |    |    |-- install_day: integer (nullable = true)
 |    |    |-- update_day: integer (nullable = true)
 |    |    |-- signed_state: integer (nullable = true)
 |    |    |-- is_system: boolean (nullable = true)
 |-- disabled_addons_ids: array (nullable = true)
 |    |-- element: string (containsNull = true)
 |-- active_theme: struct (nullable = true)
 |    |-- addon_id: string (nullable = true)
 |    |-- blocklisted: boolean (nullable = true)
 |    |-- name: string (nullable = true)
 |    |-- user_disabled: boolean (nullable = true)
 |    |-- app_disabled: boolean (nullable = true)
 |    |-- version: string (nullable = true)
 |    |-- scope: integer (nullable = true)
 |    |-- type: string (nullable = true)
 |    |-- foreign_install: boolean (nullable = true)
 |    |-- has_binary_components: boolean (nullable = true)
 |    |-- install_day: integer (nullable = true)
 |    |-- update_day: integer (nullable = true)
 |    |-- signed_state: integer (nullable = true)
 |    |-- is_system: boolean (nullable = true)
 |-- blocklist_enabled: boolean (nullable = true)
 |-- addon_compatibility_check_enabled: boolean (nullable = true)
 |-- telemetry_enabled: boolean (nullable = true)
 |-- user_prefs: struct (nullable = true)
 |    |-- dom_ipc_process_count: integer (nullable = true)
 |-- max_concurrent_tab_count: integer (nullable = true)
 |-- tab_open_event_count: integer (nullable = true)
 |-- max_concurrent_window_count: integer (nullable = true)
 |-- window_open_event_count: integer (nullable = true)
 |-- total_uri_count: integer (nullable = true)
 |-- unfiltered_uri_count: integer (nullable = true)
 |-- unique_domains_count: integer (nullable = true)
 |-- submission_date_s3: string (nullable = true)
 |-- sample_id: string (nullable = true)
 |-- events: array (nullable = true)
 |    |-- element: struct (containsNull = true)
 |    |    |-- timestamp: long (nullable = false)
 |    |    |-- category: string (nullable = false)
 |    |    |-- method: string (nullable = false)
 |    |    |-- object: string (nullable = false)
 |    |    |-- string_value: string (nullable = true)
 |    |    |-- map_values: map (nullable = true)
 |    |    |    |-- key: string
 |    |    |    |-- value: string
```

For more detail on where these fields come from in the
[raw data](https://gecko.readthedocs.io/en/latest/toolkit/components/telemetry/telemetry/data/main-ping.html),
please look 
[in the MainSummaryView code](https://github.com/mozilla/telemetry-batch-view/blob/master/src/main/scala/com/mozilla/telemetry/views/MainSummaryView.scala).
in the `buildSchema` function.

Most of the fields are simple scalar values, with a few notable exceptions:

* The `search_count` field is an array of structs, each item in the array representing
  a 3-tuple of (`engine`, `source`, `count`). The `engine` field represents the name of
  the search engine against which the searches were done. The `source` field represents
  the part of the Firefox UI that was used to perform the search. It contains values
  such as "abouthome", "urlbar", and "searchbar". The `count` field contains the number
  of searches performed against this engine+source combination during that subsession.
  Any of the fields in the struct may be null (for example if the search key did not
  match the expected pattern, or if the count was non-numeric).
* The `loop_activity_counter` field is a simple struct containing inner fields for each
  expected value of the `LOOP_ACTIVITY_COUNTER` Enumerated Histogram. Each inner field
  is a count for that histogram bucket.
* The `popup_notification_stats` field is a map of `String` keys to struct values,
  each field in the struct being a count for the expected values of the
  `POPUP_NOTIFICATION_STATS` Keyed Enumerated Histogram.
* The `places_bookmarks_count` and `places_pages_count` fields contain the **mean**
  value of the corresponding Histogram, which can be interpreted as the average number
  of bookmarks or pages in a given subsession.
* The `active_addons` field contains an array of structs, one for each entry in
  the `environment.addons.activeAddons` section of the payload. More detail in
  [Bug 1290181](https://bugzilla.mozilla.org/show_bug.cgi?id=1290181).
* The `disabled_addons_ids` field contains an array of strings, one for each entry in
  the `payload.addonDetails` which is not already reported in the `environment.addons.activeAddons`
  section of the payload. More detail in
  [Bug 1390814](https://bugzilla.mozilla.org/show_bug.cgi?id=1390814).
  Please note that while using this field is generally ok, this was introduced to support
  the [TAAR](https://github.com/mozilla/taar/pulls) project and you should not count on it
  in the future. The field can stay in the main_summary, but we might need to slightly change
  the ping structure to something better than `payload.addonDetails`.
* The `theme` field contains a single struct in the same shape as the items in the
  `active_addons` array. It contains information about the currently active browser
  theme.
* The `user_prefs` field contains a struct with values for preferences of interest.

# Code Reference

This dataset is generated by 
[telemetry-batch-view](https://github.com/mozilla/telemetry-batch-view/blob/master/src/main/scala/com/mozilla/telemetry/views/MainSummaryView.scala).
Refer to this repository for information on how to run or augment the dataset.
