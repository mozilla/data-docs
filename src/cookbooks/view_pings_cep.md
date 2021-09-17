# See My Pings

So you want to see what you're sending the telemetry pipeline, huh?
Well follow these steps and we'll have you perusing your own data in no time.

## Steps to Viewing Your Pings

1. Get your `clientId` from whatever product you're using. For desktop, it's available in `about:telemetry`.

2. Go [STMO](https://sql.telemetry.mozilla.org).

3. Enter the following query:

```sql
SELECT
  submission_timestamp,
  document_id
FROM
  `moz-fx-data-shared-prod.telemetry_live.main_v4` -- or crash, event, core, etc
WHERE
  submission_timestamp > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 3 HOUR)
  AND client_id = '<your_client_id>'
ORDER BY
  submission_timestamp DESC
LIMIT 10
```

This will show you the timestamp and document id of the ten most recent
`main` pings you've sent in the last 3 hours.
You may include any other fields here that might be of interest to you.

The tables in the `telemetry_live` dataset have only a few minutes of
latency, so you can query those tables for pings from your `client_id`
with minimal additional waiting.

One thing to note is that BigQuery has its own query cache, so if you
run the same query several times in a row, it may fetch results from
its cache. You can make any change at all (such as adding a comment)
to force the query to run again and fetch updated results.
