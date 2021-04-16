# Release information

[Product Details] is a public JSON API which contains release information for Firefox desktop, Fenix and Thunderbird. The data contains release dates for different product versions.

Product Details data is exported to BigQuery daily. Data for Firefox Desktop releases is available at `mozdata.telemetry.releases` and for Fenix releases at `mozdata.org_mozilla_fenix.releases`.

As an example, the following query finds release dates for each non-dev release in the Firefox 82 series:

```sql
SELECT
  date,
  version
FROM mozdata.telemetry.releases
WHERE version LIKE "82.%"
  AND category != "dev"
ORDER BY date
```

# Code reference

- [BigQuery schema](https://github.com/mozilla/bigquery-etl/blob/main/sql/moz-fx-data-shared-prod/telemetry_derived/releases_v1/schema.yaml)
- [Import script](https://github.com/mozilla/bigquery-etl/blob/main/sql/moz-fx-data-shared-prod/telemetry_derived/releases_v1/query.py)

[product details]: https://product-details.mozilla.org/1.0
