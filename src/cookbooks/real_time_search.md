
# Search metrics

Search metrics are delivered in main pings and often reflect usage over the course of many previous hours, so there is inherent delay (which makes it more reasonable to call `introday` search metrics instead of `almost realy-time` search metrics. Below is the query to give the hourly `sap` search metrics per each major search engine since the start of current day in `CA` based on `1%` of the sample from `telemetry_live` dataset. 

```sql
SELECT
  DATE_TRUNC(submission_timestamp, HOUR) AS submission_hour, 
  `moz-fx-data-shared-prod.udf.normalize_search_engine`(split(key,".")[offset(0)]) as normalized_engine,
  sum(mozfun.hist.`extract`(value).`sum`) AS searches
FROM
  `moz-fx-data-shared-prod.telemetry_live.main_v4`,
  UNNEST(payload.keyed_histograms.search_counts) AS sc
WHERE
  DATE(submission_timestamp) >= date_trunc(current_date(), DAY)
  AND submission_timestamp < TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), HOUR)
  AND metadata.geo.country = 'CA'
  -- Live tables are not clustered on sample_id, so we would get no benefit from using a 1% sample
  -- AND sample_id = 18
GROUP BY 1,2
ORDER BY 1,2
```

You can include any other fields that might be of interest to you.

