# `addons_daily` Derived Dataset

## Introduction:

The `addons_daily` dataset serves as the central hub for all Firefox extension related questions.
This includes questions regarding browser performance, user engagement, click through rates, etc.
Each row in the table represents a unique add-on, and each column is a unique metric.

### Contents
Prior to construction of this dataset, extension related data lived in several different sources.
`Addons_daily` has combined metrics aggregated from several sources,
including raw pings, telemetry data, and google analytics data.
Note that the data is a 1% sample of Release Firefox, so metrics like `DAU`, `WAU`, etc are approximate.

### Accessing the Data
The data is stored as a parquet table in S3 `s3://telemetry-parquet/addons_daily/v1/`


***The `addons_daily` table is accessible through re:dash using the Athena data source.
It is also available via the Presto data source,
though Athena should be preferred for performance and stability reasons.***

## Data Reference

### Example Queries


#### Query 1

Select average daily, weekly, monthly active users,
as well as the proportion of total daily active users per  for all non system `add-ons`.

```
SELECT addon_id,
       arbitrary(name) as name,
       avg(dau) as "Average DAU",
       avg(wau) as "Average WAU",
       avg(mau) as "Average MAU",
       avg(dau_prop) as "Average % of Total DAU"
FROM addons_daily
WHERE
  is_system = false
  and addon_id not like '%mozilla%'
GROUP BY 1
ORDER BY 3 DESC
```

This query can be seen and ran in STMO [here](https://sql.telemetry.mozilla.org/queries/63294/source).

#### Query 2

Select average daily active users for the `uBlock add-on` for all dates.

```
SELECT DATE_PARSE(submission_date_s3, '%Y%m%d') as "Date",
       dau as "DAU"
FROM addons_daily
WHERE
    addon_id = 'uBlock0@raymondhill.net'
```

This query can be seen and ran in STMO [here](https://sql.telemetry.mozilla.org/queries/63293/source#162153)

### Scheduling

This dataset is updated daily via the telemetry-airflow infrastructure.
The job runs as part of the `main_summary` DAG.

### Schema

The data is partitioned by `submission_date_s3` which is formatted as `%Y%m%d`, like `20180130`.
As of 2019-06-05, the current version of the `addons_daily` dataset is `v1`, and has a schema as follows:

```
root
|-- addon_id: string (nullable = true)
 |-- name: string (nullable = true)
 |-- os_pct: map (nullable = true)
 |    |-- key: string
 |    |-- value: double (valueContainsNull = false)
 |-- country_pct: map (nullable = true)
 |    |-- key: string
 |    |-- value: double (valueContainsNull = false)
 |-- avg_time_total: double (nullable = true)
 |-- active_hours: double (nullable = true)
 |-- disabled: long (nullable = true)
 |-- avg_tabs: double (nullable = true)
 |-- avg_bookmarks: double (nullable = true)
 |-- avg_toolbox_opened_count: double (nullable = true)
 |-- avg_uri: double (nullable = true)
 |-- pct_w_tracking_prot_enabled: double (nullable = true)
 |-- mau: long (nullable = true)
 |-- wau: long (nullable = true)
 |-- dau: long (nullable = true)
 |-- dau_prop: double (nullable = true)
 |-- search_with_ads: map (nullable = true)
 |    |-- key: string
 |    |-- value: long (valueContainsNull = true)
 |-- ad_click: map (nullable = true)
 |    |-- key: string
 |    |-- value: long (valueContainsNull = true)
 |-- organic_searches: map (nullable = true)
 |    |-- key: string
 |    |-- value: long (valueContainsNull = true)
 |-- sap_searches: map (nullable = true)
 |    |-- key: string
 |    |-- value: long (valueContainsNull = true)
 |-- tagged_sap_searches: map (nullable = true)
 |    |-- key: string
 |    |-- value: long (valueContainsNull = true)
 |-- installs: map (nullable = true)
 |    |-- key: string
 |    |-- value: long (valueContainsNull = true)
 |-- download_times: map (nullable = true)
 |    |-- key: string
 |    |-- value: double (valueContainsNull = false)
 |-- uninstalls: map (nullable = true)
 |    |-- key: string
 |    |-- value: long (valueContainsNull = true)
 |-- is_system: boolean (nullable = true)
 |-- avg_webext_storage_local_get_ms_: double (nullable = true)
 |-- avg_webext_storage_local_set_ms_: double (nullable = true)
 |-- avg_webext_extension_startup_ms_: double (nullable = true)
 |-- top_10_coinstalls: map (nullable = true)
 |    |-- key: string
 |    |-- value: string (valueContainsNull = true)
 |-- avg_webext_background_page_load_ms_: double (nullable = true)
 |-- avg_webext_browseraction_popup_open_ms_: double (nullable = true)
 |-- avg_webext_pageaction_popup_open_ms_: double (nullable = true)
 |-- avg_webext_content_script_injection_ms_: double (nullable = true)
```

## Code Reference

All code can be found [here](https://github.com/mozilla/addons_daily).
Refer to this repository for information on how to run or augment the dataset.
