# Main Summary

<!-- toc -->

# Introduction

{% include "./intro.md" %}

# Adding New Fields

We support a few basic types that can be easily added to `main_summary`.

Non-addon scalars are automatically added to `main_summary`.

## User Preferences

These are added in the `userPrefsList`, near the top of the
[Main Summary file](https://github.com/mozilla/telemetry-batch-view/blob/master/src/main/scala/com/mozilla/telemetry/views/MainSummaryView.scala).
They must be available in the [ping environment](http://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/environment.html)
to be included here. There is more information in the file itself.

Once added, they will show as top-level fields, with the string `user_pref` prepended. For example, `IntegerUserPref("dom.ipc.processCount")` becomes `user_pref_dom_ipc_processcount`.

## Histograms

Histograms can simply be added to the `histogramsWhitelist` near the top of
[Main Summary file](https://github.com/mozilla/telemetry-batch-view/blob/master/src/main/scala/com/mozilla/telemetry/views/MainSummaryView.scala).
Simply add the name of the histogram in the alphabetically-sorted position in the list.

Each process a histogram is recorded in will have a column in `main_summary`, with the string `histogram_` prepended. For example, `CYCLE_COLLECTOR_MAX_PAUSE`
is recorded in the `parent`, `content`, and `gpu` processes (according to the [definition](https://telemetry.mozilla.org/probe-dictionary/?search=CYCLE_COLLECTOR_MAX_PAUSE&detailView=histogram%2FCYCLE_COLLECTOR_MAX_PAUSE)).
It will then result in three columns:
- `histogram_parent_cycle_collector_max_pause`
- `histogram_content_cycle_collector_max_pause`
- `histogram_gpu_cycle_collector_max_pause`

## Addon Scalars

Addon scalars are recorded by an addon. To include one of these, add the [definition](https://dxr.mozilla.org/mozilla-central/rev/tip/toolkit/components/telemetry/Scalars.yaml) to the
[addon scalars definition file](https://github.com/mozilla/telemetry-batch-view/blob/master/src/main/resources/addon/Scalars.yaml) in [telemetry-batch-view](https://github.com/mozilla/telemetry-batch-view).
Be sure to include the section:
```
    record_in_processes:
      - 'dynamic'
```

The addon scalars can then be found in the associated column, depending on their type:
- `string_addon_scalars`
- `keyed_string_addon_scalars`
- `uint_addon_scalars`
- `keyed_uint_addon_scalars`
- `boolean_addon_scalars`
- `keyed_boolean_addon_scalars`

These columns are all maps. Each addon scalar will be a key within that map, concatenating the top-level subsection within `Scalars.yaml` with its name to get the key. As an example, consider the following scalar definition:
```
test:
  misunderestimated_nucular:
    description: A test scalar, no soup for you!
    expires: never
    kind: string
    keyed: true
    notification_emails:
      - frank@mozilla.com
    record_in_processes:
      - 'dynamic'
```

For example, you could find the addon scalar `test.misunderestimated_nucular`, a keyed string scalar, using `keyed_string_addon_scalars['test_misunderestimated_nucular']`.
In general, use `element_at`, which returns `NULL` when the key is not found: `element_at(keyed_string_addon_scalars, 'test_misunderestimated_nucular')`

## Other Fields

We can include other types of fields as well, for example if there needs to be a specific transformation done. We do need the data to be available in the [Main Ping](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/main-ping.html)

# Data Reference

## Example Queries

We recommend working with this dataset via Spark rather than `sql.t.m.o`.
Due to the large number of records,
queries can consume a lot of resources on the
**shared cluster and impact other users**.
Queries via `sql.t.m.o` should limit to a short `submission_date_s3` range,
and ideally make use of the `sample_id` field.

When using Presto to query the data from `sql.t.m.o`,
you can use the `UNNEST` feature to access items in the
`search_counts`, `popup_notification_stats` and `active_addons` fields.

For example, to compare the search volume for different search source values,
you could use:
```sql
WITH search_data AS (
  SELECT
    s.source AS search_source,
    s.count AS search_count
  FROM
    main_summary
    CROSS JOIN UNNEST(search_counts) AS t(s)
  WHERE
    submission_date_s3 = '20160510'
    AND sample_id = '42'
    AND search_counts IS NOT NULL
)

SELECT
  search_source,
  sum(search_count) as total_searches
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

As of 2017-12-03, the current version of the `main_summary` dataset is `v4`, and has a schema as follows:

```
root
 |-- document_id: string (nullable = false)
 |-- client_id: string (nullable = true)
 |-- channel: string (nullable = true)
 |-- normalized_channel: string (nullable = true)
 |-- normalized_os_version: string (nullable = true)
 |-- country: string (nullable = true)
 |-- city: string (nullable = true)
 |-- geo_subdivision1: string (nullable = true)
 |-- geo_subdivision2: string (nullable = true)
 |-- os: string (nullable = true)
 |-- os_version: string (nullable = true)
 |-- os_service_pack_major: long (nullable = true)
 |-- os_service_pack_minor: long (nullable = true)
 |-- windows_build_number: long (nullable = true)
 |-- windows_ubr: long (nullable = true)
 |-- install_year: long (nullable = true)
 |-- is_wow64: boolean (nullable = true)
 |-- memory_mb: integer (nullable = true)
 |-- cpu_count: integer (nullable = true)
 |-- cpu_cores: integer (nullable = true)
 |-- cpu_vendor: string (nullable = true)
 |-- cpu_family: integer (nullable = true)
 |-- cpu_model: integer (nullable = true)
 |-- cpu_stepping: integer (nullable = true)
 |-- cpu_l2_cache_kb: integer (nullable = true)
 |-- cpu_l3_cache_kb: integer (nullable = true)
 |-- cpu_speed_mhz: integer (nullable = true)
 |-- gfx_features_d3d11_status: string (nullable = true)
 |-- gfx_features_d2d_status: string (nullable = true)
 |-- gfx_features_gpu_process_status: string (nullable = true)
 |-- gfx_features_advanced_layers_status: string (nullable = true)
 |-- apple_model_id: string (nullable = true)
 |-- antivirus: array (nullable = true)
 |    |-- element: string (containsNull = false)
 |-- antispyware: array (nullable = true)
 |    |-- element: string (containsNull = false)
 |-- firewall: array (nullable = true)
 |    |-- element: string (containsNull = false)
 |-- profile_creation_date: long (nullable = true)
 |-- profile_reset_date: long (nullable = true)
 |-- previous_build_id: string (nullable = true)
 |-- session_id: string (nullable = true)
 |-- subsession_id: string (nullable = true)
 |-- previous_session_id: string (nullable = true)
 |-- previous_subsession_id: string (nullable = true)
 |-- session_start_date: string (nullable = true)
 |-- subsession_start_date: string (nullable = true)
 |-- session_length: long (nullable = true)
 |-- subsession_length: long (nullable = true)
 |-- subsession_counter: integer (nullable = true)
 |-- profile_subsession_counter: integer (nullable = true)
 |-- creation_date: string (nullable = true)
 |-- distribution_id: string (nullable = true)
 |-- submission_date: string (nullable = false)
 |-- sync_configured: boolean (nullable = true)
 |-- sync_count_desktop: integer (nullable = true)
 |-- sync_count_mobile: integer (nullable = true)
 |-- app_build_id: string (nullable = true)
 |-- app_display_version: string (nullable = true)
 |-- app_name: string (nullable = true)
 |-- app_version: string (nullable = true)
 |-- timestamp: long (nullable = false)
 |-- env_build_id: string (nullable = true)
 |-- env_build_version: string (nullable = true)
 |-- env_build_arch: string (nullable = true)
 |-- e10s_enabled: boolean (nullable = true)
 |-- e10s_multi_processes: long (nullable = true)
 |-- locale: string (nullable = true)
 |-- update_channel: string (nullable = true)
 |-- update_enabled: boolean (nullable = true)
 |-- update_auto_download: boolean (nullable = true)
 |-- attribution: struct (nullable = true)
 |    |-- source: string (nullable = true)
 |    |-- medium: string (nullable = true)
 |    |-- campaign: string (nullable = true)
 |    |-- content: string (nullable = true)
 |-- sandbox_effective_content_process_level: integer (nullable = true)
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
 |-- default_search_engine_data_load_path: string (nullable = true)
 |-- default_search_engine_data_origin: string (nullable = true)
 |-- default_search_engine_data_submission_url: string (nullable = true)
 |-- default_search_engine: string (nullable = true)
 |-- devtools_toolbox_opened_count: integer (nullable = true)
 |-- client_submission_date: string (nullable = true)
 |-- client_clock_skew: long (nullable = true)
 |-- client_submission_latency: long (nullable = true)
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
 |    |-- element: struct (containsNull = false)
 |    |    |-- engine: string (nullable = true)
 |    |    |-- source: string (nullable = true)
 |    |    |-- count: long (nullable = true)
 |-- active_addons: array (nullable = true)
 |    |-- element: struct (containsNull = false)
 |    |    |-- addon_id: string (nullable = false)
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
 |    |    |-- is_web_extension: boolean (nullable = true)
 |    |    |-- multiprocess_compatible: boolean (nullable = true)
 |-- disabled_addons_ids: array (nullable = true)
 |    |-- element: string (containsNull = false)
 |-- active_theme: struct (nullable = true)
 |    |-- addon_id: string (nullable = false)
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
 |    |-- is_web_extension: boolean (nullable = true)
 |    |-- multiprocess_compatible: boolean (nullable = true)
 |-- blocklist_enabled: boolean (nullable = true)
 |-- addon_compatibility_check_enabled: boolean (nullable = true)
 |-- telemetry_enabled: boolean (nullable = true)
 |-- user_prefs: struct (nullable = true)
 |    |-- dom_ipc_process_count: integer (nullable = true)
 |    |-- extensions_allow_non_mpc_extensions: boolean (nullable = true)
 |-- events: array (nullable = true)
 |    |-- element: struct (containsNull = false)
 |    |    |-- timestamp: long (nullable = false)
 |    |    |-- category: string (nullable = false)
 |    |    |-- method: string (nullable = false)
 |    |    |-- object: string (nullable = false)
 |    |    |-- string_value: string (nullable = true)
 |    |    |-- map_values: map (nullable = true)
 |    |    |    |-- key: string
 |    |    |    |-- value: string (valueContainsNull = true)
 |-- ssl_handshake_result_success: integer (nullable = true)
 |-- ssl_handshake_result_failure: integer (nullable = true)
 |-- ssl_handshake_result: map (nullable = true)
 |    |-- key: string
 |    |-- value: integer (valueContainsNull = true)
 |-- active_ticks: integer (nullable = true)
 |-- main: integer (nullable = true)
 |-- first_paint: integer (nullable = true)
 |-- session_restored: integer (nullable = true)
 |-- total_time: integer (nullable = true)
 |-- plugins_notification_shown: integer (nullable = true)
 |-- plugins_notification_user_action: struct (nullable = true)
 |    |-- allow_now: integer (nullable = true)
 |    |-- allow_always: integer (nullable = true)
 |    |-- block: integer (nullable = true)
 |-- plugins_infobar_shown: integer (nullable = true)
 |-- plugins_infobar_block: integer (nullable = true)
 |-- plugins_infobar_allow: integer (nullable = true)
 |-- plugins_infobar_dismissed: integer (nullable = true)
 |-- experiments: map (nullable = true)
 |    |-- key: string
 |    |-- value: string (valueContainsNull = true)
 |-- search_cohort: string (nullable = true)
 |-- gfx_compositor: string (nullable = true)
 |-- quantum_ready: boolean (nullable = true)
 |-- gc_max_pause_ms_main_above_150: long (nullable = true)
 |-- gc_max_pause_ms_main_above_250: long (nullable = true)
 |-- gc_max_pause_ms_main_above_2500: long (nullable = true)
 |-- gc_max_pause_ms_content_above_150: long (nullable = true)
 |-- gc_max_pause_ms_content_above_250: long (nullable = true)
 |-- gc_max_pause_ms_content_above_2500: long (nullable = true)
 |-- cycle_collector_max_pause_main_above_150: long (nullable = true)
 |-- cycle_collector_max_pause_main_above_250: long (nullable = true)
 |-- cycle_collector_max_pause_main_above_2500: long (nullable = true)
 |-- cycle_collector_max_pause_content_above_150: long (nullable = true)
 |-- cycle_collector_max_pause_content_above_250: long (nullable = true)
 |-- cycle_collector_max_pause_content_above_2500: long (nullable = true)
 |-- input_event_response_coalesced_ms_main_above_150: long (nullable = true)
 |-- input_event_response_coalesced_ms_main_above_250: long (nullable = true)
 |-- input_event_response_coalesced_ms_main_above_2500: long (nullable = true)
 |-- input_event_response_coalesced_ms_content_above_150: long (nullable = true)
 |-- input_event_response_coalesced_ms_content_above_250: long (nullable = true)
 |-- input_event_response_coalesced_ms_content_above_2500: long (nullable = true)
 |-- ghost_windows_main_above_1: long (nullable = true)
 |-- ghost_windows_content_above_1: long (nullable = true)
 |-- user_pref_dom_ipc_plugins_sandbox_level_flash: integer (nullable = true)
 |-- user_pref_dom_ipc_processcount: integer (nullable = true)
 |-- user_pref_extensions_allow_non_mpc_extensions: boolean (nullable = true)
 |-- user_pref_extensions_legacy_enabled: boolean (nullable = true)
 |-- user_pref_browser_search_widget_innavbar: boolean (nullable = true)
 |-- user_pref_general_config_filename: string (nullable = true)
 |-- ** dynamically included scalar fields, see source **
 |-- ** dynamically included whitelisted histograms, see source **
 |-- boolean_addon_scalars: map (nullable = true)
 |    |-- key: string
 |    |-- value: boolean (valueContainsNull = true)
 |-- keyed_boolean_addon_scalars: map (nullable = true)
 |    |-- key: string
 |    |-- value: map (valueContainsNull = true)
 |    |    |-- key: string
 |    |    |-- value: boolean (valueContainsNull = true)
 |-- string_addon_scalars: map (nullable = true)
 |    |-- key: string
 |    |-- value: string (valueContainsNull = true)
 |-- keyed_string_addon_scalars: map (nullable = true)
 |    |-- key: string
 |    |-- value: map (valueContainsNull = true)
 |    |    |-- key: string
 |    |    |-- value: string (valueContainsNull = true)
 |-- uint_addon_scalars: map (nullable = true)
 |    |-- key: string
 |    |-- value: integer (valueContainsNull = true)
 |-- keyed_uint_addon_scalars: map (nullable = true)
 |    |-- key: string
 |    |-- value: map (valueContainsNull = true)
 |    |    |-- key: string
 |    |    |-- value: integer (valueContainsNull = true)
 |-- submission_date_s3: string (nullable = true)
 |-- sample_id: string (nullable = true)
```

For more detail on where these fields come from in the
[raw data](https://gecko.readthedocs.io/en/latest/toolkit/components/telemetry/telemetry/data/main-ping.html),
please look
[in the `MainSummaryView` code](https://github.com/mozilla/telemetry-batch-view/blob/master/src/main/scala/com/mozilla/telemetry/views/MainSummaryView.scala).
in the `buildSchema` function.

Most of the fields are simple scalar values, with a few notable exceptions:

* The `search_count` field is an array of structs, each item in the array representing
  a 3-tuple of (`engine`, `source`, `count`). The `engine` field represents the name of
  the search engine against which the searches were done. The `source` field represents
  the part of the Firefox UI that was used to perform the search. It contains values
  such as `abouthome`, `urlbar`, and `searchbar`. The `count` field contains the number
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
  Please note that while using this field is generally OK, this was introduced to support
  the [TAAR](https://github.com/mozilla/taar/pulls) project and you should not count on it
  in the future. The field can stay in the `main_summary`, but we might need to slightly change
  the ping structure to something better than `payload.addonDetails`.
* The `theme` field contains a single struct in the same shape as the items in the
  `active_addons` array. It contains information about the currently active browser
  theme.
* The `user_prefs` field contains a struct with values for preferences of interest.
* The `events` field contains an array of event structs.
* Dynamically-included histogram fields are present as key->value maps,
  or key->(key->value) nested maps for keyed histograms.

# Code Reference

This dataset is generated by
[telemetry-batch-view](https://github.com/mozilla/telemetry-batch-view/blob/master/src/main/scala/com/mozilla/telemetry/views/MainSummaryView.scala).
Refer to this repository for information on how to run or augment the dataset.
