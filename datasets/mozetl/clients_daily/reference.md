# Clients Daily

<!-- toc -->

# Introduction

{% include "./intro.md" %}

# Data Reference

## Example Queries

#### Compute Churn for a one-day cohort:

```sql
SELECT activity_date,
       approx_distinct(client_id) AS cohort_dau
FROM clients_daily
WHERE activity_date > '2017-08-31'
  AND profile_creation_date LIKE '2017-09-01%'
GROUP BY 1
ORDER BY 1
```

#### Distribution of pings per client per day:

```sql
SELECT normalized_channel,
       CASE
        WHEN pings_aggregated_by_this_row > 50 THEN 50
        ELSE pings_aggregated_by_this_row
       END AS pings_per_day,
       approx_distinct(client_id) AS client_count
FROM clients_daily
WHERE activity_date_s3 = '2017-09-01'
  AND normalized_channel <> 'Other'
GROUP BY 1,
         2
ORDER BY 2,
         1
```

## Caveats

The `clients_daily` dataset is not sampled, however data that arrives after
a certain cut-off period will not appear in the dataset. This is determined
via the [`--lag-days` parameter](https://github.com/mozilla/python_mozetl/blob/master/mozetl/clientsdaily/rollup.py#L181),
which, as of 2017-10-11, defaults to 10.

## Scheduling

This dataset is updated daily via the
[telemetry-airflow](https://github.com/mozilla/telemetry-airflow) infrastructure.
The job runs as part of the [`main_summary` DAG](https://github.com/mozilla/telemetry-airflow/blob/master/dags/main_summary.py#L160).

## Schema

As of 2017-10-11, the current version of the `clients_daily` dataset is `v5`, and has a schema as follows:

```
root
 |-- client_id: string (nullable = true)
 |-- activity_date: string (nullable = true)
 |-- aborts_content_sum: long (nullable = true)
 |-- aborts_gmplugin_sum: long (nullable = true)
 |-- aborts_plugin_sum: long (nullable = true)
 |-- active_addons_count_mean: double (nullable = true)
 |-- active_experiment_branch: string (nullable = true)
 |-- active_experiment_id: string (nullable = true)
 |-- active_hours_sum: double (nullable = true)
 |-- addon_compatibility_check_enabled: boolean (nullable = true)
 |-- app_build_id: string (nullable = true)
 |-- app_display_version: string (nullable = true)
 |-- app_name: string (nullable = true)
 |-- app_version: string (nullable = true)
 |-- blocklist_enabled: boolean (nullable = true)
 |-- channel: string (nullable = true)
 |-- city: string (nullable = true)
 |-- country: string (nullable = true)
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
 |-- first_paint_mean: double (nullable = true)
 |-- flash_version: string (nullable = true)
 |-- install_year: long (nullable = true)
 |-- is_default_browser: boolean (nullable = true)
 |-- is_wow64: boolean (nullable = true)
 |-- locale: string (nullable = true)
 |-- memory_mb: integer (nullable = true)
 |-- os: string (nullable = true)
 |-- os_service_pack_major: long (nullable = true)
 |-- os_service_pack_minor: long (nullable = true)
 |-- os_version: string (nullable = true)
 |-- normalized_channel: string (nullable = true)
 |-- pings_aggregated_by_this_row: long (nullable = true)
 |-- places_bookmarks_count_mean: double (nullable = true)
 |-- places_pages_count_mean: double (nullable = true)
 |-- plugin_hangs_sum: long (nullable = true)
 |-- plugins_infobar_allow_sum: long (nullable = true)
 |-- plugins_infobar_block_sum: long (nullable = true)
 |-- plugins_infobar_shown_sum: long (nullable = true)
 |-- plugins_notification_shown_sum: long (nullable = true)
 |-- profile_age_in_days: integer (nullable = true)
 |-- profile_creation_date: string (nullable = true)
 |-- push_api_notify_sum: long (nullable = true)
 |-- sample_id: string (nullable = true)
 |-- scalar_parent_aushelper_websense_reg_version: string (nullable = true)
 |-- scalar_parent_browser_engagement_max_concurrent_tab_count_max: integer (nullable = true)
 |-- scalar_parent_browser_engagement_max_concurrent_window_count_max: integer (nullable = true)
 |-- scalar_parent_browser_engagement_tab_open_event_count_sum: long (nullable = true)
 |-- scalar_parent_browser_engagement_total_uri_count_sum: long (nullable = true)
 |-- scalar_parent_browser_engagement_unfiltered_uri_count_sum: long (nullable = true)
 |-- scalar_parent_browser_engagement_unique_domains_count_max: integer (nullable = true)
 |-- scalar_parent_browser_engagement_window_open_event_count_sum: long (nullable = true)
 |-- scalar_parent_devtools_copy_full_css_selector_opened_sum: long (nullable = true)
 |-- scalar_parent_devtools_copy_unique_css_selector_opened_sum: long (nullable = true)
 |-- scalar_parent_devtools_toolbar_eyedropper_opened_sum: long (nullable = true)
 |-- scalar_parent_dom_contentprocess_troubled_due_to_memory_sum: long (nullable = true)
 |-- scalar_parent_navigator_storage_estimate_count_sum: long (nullable = true)
 |-- scalar_parent_navigator_storage_persist_count_sum: long (nullable = true)
 |-- scalar_parent_services_sync_fxa_verification_method: string (nullable = true)
 |-- scalar_parent_storage_sync_api_usage_extensions_using_sum: long (nullable = true)
 |-- scalar_parent_telemetry_os_shutting_down: boolean (nullable = true)
 |-- scalar_parent_webrtc_nicer_stun_retransmits_sum: long (nullable = true)
 |-- scalar_parent_webrtc_nicer_turn_401s_sum: long (nullable = true)
 |-- scalar_parent_webrtc_nicer_turn_403s_sum: long (nullable = true)
 |-- scalar_parent_webrtc_nicer_turn_438s_sum: long (nullable = true)
 |-- search_cohort: string (nullable = true)
 |-- search_count_all_sum: long (nullable = true)
 |-- search_count_abouthome_sum: long (nullable = true)
 |-- search_count_contextmenu_sum: long (nullable = true)
 |-- search_count_newtab_sum: long (nullable = true)
 |-- search_count_searchbar_sum: long (nullable = true)
 |-- search_count_system_sum: long (nullable = true)
 |-- search_count_urlbar_sum: long (nullable = true)
 |-- session_restored_mean: double (nullable = true)
 |-- sessions_started_on_this_day: long (nullable = true)
 |-- subsession_hours_sum: decimal(37,6) (nullable = true)
 |-- ssl_handshake_result_failure_sum: long (nullable = true)
 |-- ssl_handshake_result_success_sum: long (nullable = true)
 |-- sync_configured: boolean (nullable = true)
 |-- sync_count_desktop_sum: long (nullable = true)
 |-- sync_count_mobile_sum: long (nullable = true)
 |-- telemetry_enabled: boolean (nullable = true)
 |-- timezone_offset: integer (nullable = true)
 |-- total_hours_sum: decimal(27,6) (nullable = true)
 |-- vendor: string (nullable = true)
 |-- web_notification_shown_sum: long (nullable = true)
 |-- windows_build_number: long (nullable = true)
 |-- windows_ubr: long (nullable = true)
 |-- shutdown_kill_sum: long (nullable = true)
 |-- activity_date_s3: date (nullable = true)
```

For more detail on the set of fields and their chosen aggregations,
please look
[in the aggregations doc](https://docs.google.com/spreadsheets/d/1jDqnhXrix8WtfBMrq1NzesYd7HrVn__VsA8RyckUrSo/edit#gid=868109559)
or at the code (linked below).

# Code Reference

This dataset is generated by
[`python_mozetl`](https://github.com/mozilla/python_mozetl/blob/master/mozetl/clientsdaily/rollup.py).
Refer to this repository for information on how to run or augment the dataset.
