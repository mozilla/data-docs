# Metrics

This section contains definitions and information about standard metrics used at Mozilla.  You may wish to refer to the [terminology section](../concepts/terminology.html) while reading this document, in case a particular concept is not clear.

## Table of Contents

<!-- toc -->

-----

## Daily Active Users (DAU)

### Overview

Daily Active Users or DAU counts the number of unique profiles active in the product on each day.  This is intended to approximate the number of people using the product each day.

### Details

DAU counts unique profiles. Keep in mind that a [profile is not necessarily a user](/concepts/analysis_gotchas.html#profiles-vs-users)

The standard concept of active varies by product, but generally, active users are defined as unique profiles who've sent a `main` ping (on desktop) or a `baseline` ping (on mobile).  The precise criteria are defined in the [`usage criterion`](./usage.md) section of this documentation.

We can also occasionally restrict the metric to alternative usage critera. It's **critical to clearly state any non-standard usage criteria on the metric**. The metrics team suggest the following format: `DAU(usage criteria)`. For example, we might be interested in the count of users who've viewed more than 5 URIs in a day. We'd denote that metric as `DAU(URI > 5)`.

We also some common alternative usage criteria documented in [`usage criterion`](./usage.md).

### Caveats

If the number of users stays constant, but the average number of active profiles per user increases, this metric will tend to increase.  For more details on the relationship between users and profiles, see [the profiles vs users section in analysis gotchas](https://docs.telemetry.mozilla.org/concepts/analysis_gotchas.html#profiles-vs-users).

### Dashboards

This metric is available on the [standard Growth and Usage Dashboard (GUD)](https://go.corp.mozilla.com/gud) for most products and with some slicing available.

### Tables

DAU can easily be calculated from the [Exact MAU tables](https://docs.telemetry.mozilla.org/datasets/bigquery/exact_mau/reference.html); for example:

```sql
SELECT
  submission_date,
  SUM(dau) AS dau
FROM
  `moz-fx-data-derived-datasets.telemetry.firefox_desktop_exact_mau28_by_dimensions_v1`
WHERE
  -- You define your slice using additional filters here.
  country IN ('US', 'GB', 'CA', 'FR', 'DE')

GROUP BY
  submission_date
```

You can run this query on [STMO](https://sql.telemetry.mozilla.org/queries/72012/source).

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
