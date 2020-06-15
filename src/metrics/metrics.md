# Metrics

Here we provide definitions and information about our standard metrics.

## Table of Contents

<!-- toc -->

-----

## Daily Active Users (DAU)

### Overview

Daily Active Users or DAU counts the number of unique profiles active in the product on each day.  This is intended to approximate the number of people using the product each day.

### Details

The concept of a "unique profile" may vary from product to product and the relationship between that concept and actual users may also vary.  As such care should be taken interpreting this metric as an actual count of users.

The concept of being "active" is defined as in the [`usage criterion`](./usage.md) section and will vary by product.  A product may even have multiple possible `usage criteria`, but there will be one default choice that is our best approximation of general product usage.

### Caveats

If the number of users stays constant, but the average number of active profiles per user increases, this metric will tend to increase.

### Dashboards

This metric is available on the [standard Growth and Usage Dashboard (GUD)](https://go.corp.mozilla.com/gud) for most products and with some slicing available.

### Tables

DAU can easily be calculated from the Smoot tables; for example:

```sql
SELECT
  date,
  SUM(dau) AS dau
FROM
  `moz-fx-data-shared-prod.telemetry.smoot_usage_day_0`
-- You must always filter to a single usage criterion
-- For a full list of available usage criteria, see https://sql.telemetry.mozilla.org/queries/65338/source
WHERE
  usage = 'Any Firefox Desktop Activity'

  -- You define your slice using additional filters here.
  -- Available dimensions: app_name, app_version, country, locale, os, os_version, channel
  AND country IN ('US', 'GB', 'CA', 'FR', 'DE')

GROUP BY
  date
```

-----

Reference below.

{{Metric name}}

TL;DR: two sentence max.

E.g: MAU counts the number of distinct users we see over a 28-day period. Desktop and Mobile MAU are both corporate KPIs for 2020.

 - Overview:
  - What the metric measures
 - Calculation:
  - Definitions for both Mobile and Desktop, if applicable.
  - What is the easiest way to calculate this metric? E.g. MAU over `clients_last_seen`.
  - At least one working definition
  - Link to a scheduled re:dash query (link with `stmocli`?)
  - Possibly an API-linked graph from STMO
  - If it’s non-obvious, examples for how to stratify. E.g. calculating MAU from `clients_daily`
 - Common Issues: Failures and Gotchas
 - Resources
  - Link to the STMO query from Definition section
  - Notable dashboards for the metric
  - Similar metrics

 ----

 Next metric
