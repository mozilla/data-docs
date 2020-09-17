# Normalized Client Lifetime Value (LTV)

<!-- toc -->

# Introduction

{{#include ./intro.md}}


# Example Queries



*Percent of users who clicked an ad in the last 365 days, and who are expected to click an ad in the **next** 365 days by Engine.*
```sql
SELECT
  engine,
  AVG(IF(ad_click_days > 0, 1, 0)) as pct_ad_clickers_past_year,
  AVG(IF(pred_num_days_clicking_ads > 0, 1, 0)) as pct_predicted_ad_clickers_next_year
FROM
  `moz-it-eip-revenue-users.ltv_derived.client_ltv_v1`
WHERE
  submission_date = DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY)
GROUP BY
  1

```

# Schema

As of 2020-09-16,
the current version of `normalized_client_ltv` is `v1`,
and has a schema as follows.
The dataset is backfilled through yyyy-mm-dd.

```
root
 |-- submission_date: date (nullable = true)
 |-- engine: string (nullable = true)
 |-- country: string (nullable = true)
 |-- client_id: string (nullable = true)
 |-- total_client_searches_past_year: long (nullable = true)
 |-- total_client_tagged_searches_past_year: long (nullable = true)
 |-- total_client_ad_clicks_past_year: long (nullable = true)
 |-- total_client_searches_with_ads_past_year: long (nullable = true)
 |-- ad_click_days: long (nullable = true)
 |-- search_days: long (nullable = true)
 |-- search_with_ads_days: long (nullable = true)
 |-- tagged_search_days: long (nullable = true)
 |-- active_days: long (nullable = true)
 |-- pred_num_days_clicking_ads: double (nullable = true)
 |-- pred_num_days_seeing_ads: double (nullable = true)
 |-- pred_num_days_searching: double (nullable = true)
 |-- pred_num_days_tagged_searching: double (nullable = true)
 |-- ad_clicks_per_day: double (nullable = true)
 |-- searches_with_ads_per_day: double (nullable = true)
 |-- searches_per_day: double (nullable = true)
 |-- tagged_searches_per_day: double (nullable = true)
 |-- ad_clicks_cutoff: double (nullable = true)
 |-- searches_with_ads_cutoff: double (nullable = true)
 |-- searches_cutoff: double (nullable = true)
 |-- tagged_searches_cutoff: double (nullable = true)
 |-- ad_clicks_per_day_capped: double (nullable = true)
 |-- searches_with_ads_per_day_capped: double (nullable = true)
 |-- searches_per_day_capped: double (nullable = true)
 |-- tagged_searches_per_day_capped: double (nullable = true)
 |-- total_ad_clicks: long (nullable = true)
 |-- normalized_ltv_ad_clicks_current: double (nullable = true)
 |-- normalized_ltv_search_with_ads_current: double (nullable = true)
 |-- normalized_ltv_search_current: double (nullable = true)
 |-- normalized_ltv_tagged_search_current: double (nullable = true)
 |-- normalized_ltv_ad_clicks_future: double (nullable = true)
 |-- normalized_ltv_search_with_ads_future: double (nullable = true)
 |-- normalized_ltv_search_future: double (nullable = true)
 |-- normalized_ltv_tagged_search_future: double (nullable = true)
 ```

 # Code References

* [LTV daily model fitting](https://github.com/mozilla/telemetry-airflow/blob/master/jobs/ltv_daily.py)
* [`client_ltv` query](https://github.com/mozilla/bigquery-etl/blob/master/sql/revenue_derived/client_ltv_v1/query.sql)
* [`client_ltv_normalized`  view](https://github.com/mozilla/bigquery-etl/blob/master/sql/revenue_derived/client_ltv_normalized/query.sql)



