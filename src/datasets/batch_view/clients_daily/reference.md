# Clients Daily

<!-- toc -->

# Introduction

{{#include ./intro.md}}

# Data Reference

## Example Queries

#### Compute Churn for a one-day cohort:

```sql
SELECT
  date_parse(submission_date_s3, '%Y%m%d') AS submission_date_s3,
  approx_distinct(client_id) AS cohort_dau
FROM clients_daily
WHERE
  submission_date_s3 > '20170831'
  AND submission_date_s3 < '20171001'
  AND profile_creation_date LIKE '2017-09-01%'
GROUP BY 1
ORDER BY 1
```

#### Distribution of pings per client per day:

```sql
SELECT
  normalized_channel,
  CASE
    WHEN pings_aggregated_by_this_row > 50 THEN 50
    ELSE pings_aggregated_by_this_row
  END AS pings_per_day,
  approx_distinct(client_id) AS client_count
FROM clients_daily
WHERE
  submission_date_s3 = '20170901'
  AND normalized_channel <> 'Other'
GROUP BY
  1,
  2
ORDER BY
  2,
  1
```

## Scheduling

This dataset is updated daily via the
[telemetry-airflow](https://github.com/mozilla/telemetry-airflow) infrastructure.
The job runs as part of the [`main_summary` DAG](https://github.com/mozilla/telemetry-airflow/blob/master/dags/main_summary.py#L160).

## Schema

The data is partitioned by `submission_date_s3` which is formatted as `%Y%m%d`,
like `20180130`.

As of 2018-11-01, the current version of the `clients_daily` dataset is `v6`, and has a schema as follows:

```
root
 |-- client_id: string (nullable = true)
 |-- aborts_content_sum: long (nullable = true)
 |-- aborts_gmplugin_sum: long (nullable = true)
 |-- aborts_plugin_sum: long (nullable = true)
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
 |    |    |-- is_web_extension: boolean (nullable = true)
 |    |    |-- multiprocess_compatible: boolean (nullable = true)
 |-- active_addons_count_mean: double (nullable = true)
 |-- active_hours_sum: double (nullable = true)
 |-- addon_compatibility_check_enabled: boolean (nullable = true)
 |-- app_build_id: string (nullable = true)
 |-- app_display_version: string (nullable = true)
 |-- app_name: string (nullable = true)
 |-- app_version: string (nullable = true)
 |-- attribution: struct (nullable = true)
 |    |-- source: string (nullable = true)
 |    |-- medium: string (nullable = true)
 |    |-- campaign: string (nullable = true)
 |    |-- content: string (nullable = true)
 |-- blocklist_enabled: boolean (nullable = true)
 |-- channel: string (nullable = true)
 |-- city: string (nullable = true)
 |-- client_clock_skew_mean: double (nullable = true)
 |-- client_submission_latency_mean: double (nullable = true)
 |-- country: string (nullable = true)
 |-- cpu_cores: integer (nullable = true)
 |-- cpu_count: integer (nullable = true)
 |-- cpu_family: integer (nullable = true)
 |-- cpu_l2_cache_kb: integer (nullable = true)
 |-- cpu_l3_cache_kb: integer (nullable = true)
 |-- cpu_model: integer (nullable = true)
 |-- cpu_speed_mhz: integer (nullable = true)
 |-- cpu_stepping: integer (nullable = true)
 |-- cpu_vendor: string (nullable = true)
 |-- crashes_detected_content_sum: long (nullable = true)
 |-- crashes_detected_gmplugin_sum: long (nullable = true)
 |-- crashes_detected_plugin_sum: long (nullable = true)
 |-- crash_submit_attempt_content_sum: long (nullable = true)
 |-- crash_submit_attempt_main_sum: long (nullable = true)
 |-- crash_submit_attempt_plugin_sum: long (nullable = true)
 |-- crash_submit_success_content_sum: long (nullable = true)
 |-- crash_submit_success_main_sum: long (nullable = true)
 |-- crash_submit_success_plugin_sum: long (nullable = true)
 |-- default_search_engine: string (nullable = true)
 |-- default_search_engine_data_load_path: string (nullable = true)
 |-- default_search_engine_data_name: string (nullable = true)
 |-- default_search_engine_data_origin: string (nullable = true)
 |-- default_search_engine_data_submission_url: string (nullable = true)
 |-- devtools_toolbox_opened_count_sum: long (nullable = true)
 |-- distribution_id: string (nullable = true)
 |-- e10s_enabled: boolean (nullable = true)
 |-- env_build_arch: string (nullable = true)
 |-- env_build_id: string (nullable = true)
 |-- env_build_version: string (nullable = true)
 |-- experiments: map (nullable = true)
 |    |-- key: string
 |    |-- value: string (valueContainsNull = true)
 |-- first_paint_mean: double (nullable = true)
 |-- flash_version: string (nullable = true)
 |-- geo_subdivision1: string (nullable = true)
 |-- geo_subdivision2: string (nullable = true)
 |-- gfx_features_advanced_layers_status: string (nullable = true)
 |-- gfx_features_d2d_status: string (nullable = true)
 |-- gfx_features_d3d11_status: string (nullable = true)
 |-- gfx_features_gpu_process_status: string (nullable = true)
 |-- histogram_parent_devtools_aboutdebugging_opened_count_sum: long (nullable = true)
 |-- histogram_parent_devtools_animationinspector_opened_count_sum: long (nullable = true)
 |-- histogram_parent_devtools_browserconsole_opened_count_sum: long (nullable = true)
 |-- histogram_parent_devtools_canvasdebugger_opened_count_sum: long (nullable = true)
 |-- histogram_parent_devtools_computedview_opened_count_sum: long (nullable = true)
 |-- histogram_parent_devtools_custom_opened_count_sum: long (nullable = true)
 |-- histogram_parent_devtools_developertoolbar_opened_count_sum: long (nullable = true)
 |-- histogram_parent_devtools_dom_opened_count_sum: long (nullable = true)
 |-- histogram_parent_devtools_eyedropper_opened_count_sum: long (nullable = true)
 |-- histogram_parent_devtools_fontinspector_opened_count_sum: long (nullable = true)
 |-- histogram_parent_devtools_inspector_opened_count_sum: long (nullable = true)
 |-- histogram_parent_devtools_jsbrowserdebugger_opened_count_sum: long (nullable = true)
 |-- histogram_parent_devtools_jsdebugger_opened_count_sum: long (nullable = true)
 |-- histogram_parent_devtools_jsprofiler_opened_count_sum: long (nullable = true)
 |-- histogram_parent_devtools_layoutview_opened_count_sum: long (nullable = true)
 |-- histogram_parent_devtools_memory_opened_count_sum: long (nullable = true)
 |-- histogram_parent_devtools_menu_eyedropper_opened_count_sum: long (nullable = true)
 |-- histogram_parent_devtools_netmonitor_opened_count_sum: long (nullable = true)
 |-- histogram_parent_devtools_options_opened_count_sum: long (nullable = true)
 |-- histogram_parent_devtools_paintflashing_opened_count_sum: long (nullable = true)
 |-- histogram_parent_devtools_picker_eyedropper_opened_count_sum: long (nullable = true)
 |-- histogram_parent_devtools_responsive_opened_count_sum: long (nullable = true)
 |-- histogram_parent_devtools_ruleview_opened_count_sum: long (nullable = true)
 |-- histogram_parent_devtools_scratchpad_opened_count_sum: long (nullable = true)
 |-- histogram_parent_devtools_scratchpad_window_opened_count_sum: long (nullable = true)
 |-- histogram_parent_devtools_shadereditor_opened_count_sum: long (nullable = true)
 |-- histogram_parent_devtools_storage_opened_count_sum: long (nullable = true)
 |-- histogram_parent_devtools_styleeditor_opened_count_sum: long (nullable = true)
 |-- histogram_parent_devtools_webaudioeditor_opened_count_sum: long (nullable = true)
 |-- histogram_parent_devtools_webconsole_opened_count_sum: long (nullable = true)
 |-- histogram_parent_devtools_webide_opened_count_sum: long (nullable = true)
 |-- install_year: long (nullable = true)
 |-- is_default_browser: boolean (nullable = true)
 |-- is_wow64: boolean (nullable = true)
 |-- locale: string (nullable = true)
 |-- memory_mb: integer (nullable = true)
 |-- normalized_channel: string (nullable = true)
 |-- normalized_os_version: string (nullable = true)
 |-- os: string (nullable = true)
 |-- os_service_pack_major: long (nullable = true)
 |-- os_service_pack_minor: long (nullable = true)
 |-- os_version: string (nullable = true)
 |-- pings_aggregated_by_this_row: long (nullable = true)
 |-- places_bookmarks_count_mean: double (nullable = true)
 |-- places_pages_count_mean: double (nullable = true)
 |-- plugin_hangs_sum: long (nullable = true)
 |-- plugins_infobar_allow_sum: long (nullable = true)
 |-- plugins_infobar_block_sum: long (nullable = true)
 |-- plugins_infobar_shown_sum: long (nullable = true)
 |-- plugins_notification_shown_sum: long (nullable = true)
 |-- previous_build_id: string (nullable = true)
 |-- profile_age_in_days: integer (nullable = true)
 |-- profile_creation_date: string (nullable = true)
 |-- push_api_notify_sum: long (nullable = true)
 |-- sample_id: string (nullable = true)
 |-- sandbox_effective_content_process_level: integer (nullable = true)
 |-- scalar_combined_webrtc_nicer_stun_retransmits_sum: long (nullable = true)
 |-- scalar_combined_webrtc_nicer_turn_401s_sum: long (nullable = true)
 |-- scalar_combined_webrtc_nicer_turn_403s_sum: long (nullable = true)
 |-- scalar_combined_webrtc_nicer_turn_438s_sum: long (nullable = true)
 |-- scalar_content_navigator_storage_estimate_count_sum: long (nullable = true)
 |-- scalar_content_navigator_storage_persist_count_sum: long (nullable = true)
 |-- scalar_parent_aushelper_websense_reg_version: string (nullable = true)
 |-- scalar_parent_browser_engagement_max_concurrent_tab_count_max: integer (nullable = true)
 |-- scalar_parent_browser_engagement_max_concurrent_window_count_max: integer (nullable = true)
 |-- scalar_parent_browser_engagement_tab_open_event_count_sum: long (nullable = true)
 |-- scalar_parent_browser_engagement_total_uri_count_sum: long (nullable = true)
 |-- scalar_parent_browser_engagement_unfiltered_uri_count_sum: long (nullable = true)
 |-- scalar_parent_browser_engagement_unique_domains_count_max: integer (nullable = true)
 |-- scalar_parent_browser_engagement_unique_domains_count_mean: double (nullable = true)
 |-- scalar_parent_browser_engagement_window_open_event_count_sum: long (nullable = true)
 |-- scalar_parent_devtools_accessibility_node_inspected_count_sum: long (nullable = true)
 |-- scalar_parent_devtools_accessibility_opened_count_sum: long (nullable = true)
 |-- scalar_parent_devtools_accessibility_picker_used_count_sum: long (nullable = true)
 |-- scalar_parent_devtools_accessibility_select_accessible_for_node_sum: map (nullable = true)
 |    |-- key: string
 |    |-- value: integer (valueContainsNull = true)
 |-- scalar_parent_devtools_accessibility_service_enabled_count_sum: long (nullable = true)
 |-- scalar_parent_devtools_copy_full_css_selector_opened_sum: long (nullable = true)
 |-- scalar_parent_devtools_copy_unique_css_selector_opened_sum: long (nullable = true)
 |-- scalar_parent_devtools_toolbar_eyedropper_opened_sum: long (nullable = true)
 |-- scalar_parent_navigator_storage_estimate_count_sum: long (nullable = true)
 |-- scalar_parent_navigator_storage_persist_count_sum: long (nullable = true)
 |-- scalar_parent_storage_sync_api_usage_extensions_using_sum: long (nullable = true)
 |-- search_cohort: string (nullable = true)
 |-- search_count_all: long (nullable = true)
 |-- search_count_abouthome: long (nullable = true)
 |-- search_count_contextmenu: long (nullable = true)
 |-- search_count_newtab: long (nullable = true)
 |-- search_count_searchbar: long (nullable = true)
 |-- search_count_system: long (nullable = true)
 |-- search_count_urlbar: long (nullable = true)
 |-- session_restored_mean: double (nullable = true)
 |-- sessions_started_on_this_day: long (nullable = true)
 |-- shutdown_kill_sum: long (nullable = true)
 |-- subsession_hours_sum: decimal(37,6) (nullable = true)
 |-- ssl_handshake_result_failure_sum: long (nullable = true)
 |-- ssl_handshake_result_success_sum: long (nullable = true)
 |-- sync_configured: boolean (nullable = true)
 |-- sync_count_desktop_sum: long (nullable = true)
 |-- sync_count_mobile_sum: long (nullable = true)
 |-- telemetry_enabled: boolean (nullable = true)
 |-- timezone_offset: integer (nullable = true)
 |-- update_auto_download: boolean (nullable = true)
 |-- update_channel: string (nullable = true)
 |-- update_enabled: boolean (nullable = true)
 |-- vendor: string (nullable = true)
 |-- web_notification_shown_sum: long (nullable = true)
 |-- windows_build_number: long (nullable = true)
 |-- windows_ubr: long (nullable = true)
 |-- submission_date_s3: string (nullable = true)
```

# Code Reference

This dataset is generated by
[`telemetry-batch-view`](https://github.com/mozilla/telemetry-batch-view/blob/master/GRAVEYARD.md#main-summary-clients-daily-and-addons).
Refer to this repository for information on how to run or augment the dataset.
