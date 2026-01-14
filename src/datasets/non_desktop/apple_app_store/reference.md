# Apple App Store

<!-- toc -->

# Introduction

The [`app_store_v2_syndicate`](https://console.cloud.google.com/bigquery?project=moz-fx-data-shared-prod&ws=!1m8!1m3!3m2!1smoz-fx-data-shared-prod!2sapp_store!1m3!3m2!1smoz-fx-data-shared-prod!2sapp_store_v2_syndicate) dataset is used to understand the acquisition performance for non-desktop products on the Apple App Store along the key metrics and dimensions. Apple’s documentation for all metrics and dimensions can be found [in the app store connect reference](https://help.apple.com/app-store-connect/#/itc21781223f).

# Contents

The `app_store_v2_syndicate` dataset contains a collection of pre-aggregated tables by a singular dimension that explains the performance of acquisition activity through the Apple App Store. The tables available are as follows:

- `moz-fx-data-shared-prod.app_store_v2_syndicate.app_crash_daily` - Daily metrics to understand crashes for your App Store apps by app version and device type.

- `moz-fx-data-shared-prod.app_store_v2_syndicate.app_session_detailed_daily` - Daily metrics to understand how often people open your app, and how long they spend in your app.
- `moz-fx-data-shared-prod.app_store_v2_syndicate.app_session_standard_daily` - Daily metrics to understand how often people open your app, and how long they spend in your app.

- `moz-fx-data-shared-prod.app_store_v2_syndicate.app_store_discovery_and_engagement_detailed_daily` - Daily metrics on how users discover and engage with your app on the App Store.
- `moz-fx-data-shared-prod.app_store_v2_syndicate.app_store_discovery_and_engagement_standard_daily` - Daily metrics on how users discover and engage with your app on the App Store.

- `moz-fx-data-shared-prod.app_store_v2_syndicate.app_store_download_detailed_daily` - Daily metrics to understand to understand your total number of downloads, including first-time downloads, redownloads, updates, and more.
- `moz-fx-data-shared-prod.app_store_v2_syndicate.app_store_download_standard_daily` - Daily metrics to understand to understand your total number of downloads, including first-time downloads, redownloads, updates, and more.

- `moz-fx-data-shared-prod.app_store_v2_syndicate.app_store_installation_and_deletion_detailed_daily` - Daily metrics to estimate the number of times people install and delete your App Store apps.
- `moz-fx-data-shared-prod.app_store_v2_syndicate.app_store_installation_and_deletion_standard_daily` - Daily metrics to estimate the number of times people install and delete your App Store apps.

- `moz-fx-data-shared-prod.app_store_v2_syndicate.app_store_review` - Pulls app reviews from the App Store.
- `moz-fx-data-shared-prod.app_store_v2_syndicate.apple_store_territory_report` - Breakdown of app impressions, installs, and downloads by source (App Store search or App Store browse) and territory (country).

# Data Reference

## Schema

A schema and field information can be found in the [dbt_apple_store docs](https://fivetran.github.io/dbt_apple_store/#!/source_list/apple_store).

## Scheduling

The raw data is retrieved from the Apple App Store using a [Fivetran Apple App Store connector](https://fivetran.com/dashboard/connections/branches_bunches/status?groupId=loading_reputation&service=itunes_connect&syncChartPeriod=1%20Day). This data is then also transformed by a [Fivetran transformation](https://fivetran.com/dashboard/transformations/quickstart/refill_regaining?groupId=loading_reputation) and made available inside a BigQuery dataset [moz-fx-data-bq-fivetran.firefox_app_store_v2](https://console.cloud.google.com/bigquery?project=moz-fx-data-shared-prod&ws=!1m8!1m3!3m2!1smoz-fx-data-shared-prod!2sapp_store!1m3!3m2!1smoz-fx-data-shared-prod!2sapp_store_v2_syndicate) from where downstream ETL processes consume the data for deriving insights (example: [app_store_funnel_v1](https://github.com/mozilla/bigquery-etl/blob/17172bf4a46483966d1971d30b9bce60e41e9d88/sql/moz-fx-data-shared-prod/firefox_ios_derived/app_store_funnel_v1/query.sql)).
