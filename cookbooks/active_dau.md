# Active DAU

An "Active User" is defined as a client who has `total_daily_uri` >= 5 URI for a given date. 
* Dates are defined by `submission_date_s3`.
* A client's `total_daily_uri` is defined as their sum of `scalar_parent_browser_engagement_total_uri_count` for a given date[1]. 

For quick analysis, using `clients_daily_v6` is recommended. Below is an example query for getting Active DAU (aDAU) using `clients_daily_v6`.

```sql
SELECT 
    submission_date_s3,
    count(*) AS total_clients_cdv6
FROM 
    clients_daily_v6
WHERE 
    scalar_parent_browser_engagement_total_uri_count_sum >= 5
GROUP BY 
    1
ORDER BY 
    1 ASC
```

`main_summary` can also be used for getting aDAU. Below is an example query using a 1% sample over March 2018 using `main_summary`: 

```sql
SELECT
    submission_date_s3, 
    count(DISTINCT client_id) * 100 as aDAU
FROM 
    (SELECT 
            submission_date_s3, 
            client_id, 
            sum(coalesce(scalar_parent_browser_engagement_total_uri_count, 0)) as total_daily_uri
        FROM
            main_summary
        WHERE
            sample_id = '51'
            AND submission_date_s3 >= '20180301'
            AND submission_date_s3 < '20180401'
        GROUP BY 
            1, 2) as daily_clients_table
WHERE
    total_daily_uri >= 5
GROUP BY 
    1
ORDER BY 
    1 ASC
```

[1] Note, the probe measuring `scalar_parent_browser_engagement_total_uri_count` only exists in clients with Firefox 50 and up. Clients on earlier versions of Firefox won't be counted as an Active User (regardless of their use). Similarly, `scalar_parent_browser_engagement_total_uri_count` doesn't increment when a client is in Private Browsing mode, so that won't be included as well.