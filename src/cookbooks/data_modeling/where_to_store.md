# Where to Store our analytics data models

Mozilla’s current setup allows for the implementation of data modeling and business logic in different locations e.g BigQuery or Looker. The purpose of this document is to provide guidelines to decide where to store a new asset and to review pull requests that implement them.

For the purpose of this documentation, the analytics data model is defined as the set of data assets designed to collect meaningful data from our raw datasets and structure it for an efficient understanding and analysis of our products, business processes and events.

## What to store in BigQuery datasets and the bigquery-etl repository

bigquery-etl is the repository for tools and also transformations and business logic that is stored in a BigQuery dataset (derived table, aggregate table, view, materialized view).

Some examples of logic expected in bigquery-etl:

- The calculation of [core metrics](https://docs.telemetry.mozilla.org/metrics/index.html): DAU, WAU, MAU, new profiles.
- Calculation of [search metrics](https://docs.telemetry.mozilla.org/datasets/search.html?highlight=search#terminology). E.g. Ad clicks, search with ads, organic search.
- Calculation of acquisition, retention and churn metrics.
- Mapping from partner code to platform for Bing revenue.
- Segmentation of clients that require the implementation of business logic, not just filtering on specific columns.

## What to store in Looker

Data aggregations or aggregate awareness to improve performance, preferably that don't implement or replicate business logic.

Some examples:

- Aggregates for summarization or creating a subset from a BigQuery dataset, and that don’t include business logic. Some examples:
  - A subset of data for a specific year. See this [aggregate for data after 2019 in Looker](https://github.com/mozilla/looker-spoke-default/blob/4ee892234963d3305f087b99a38caa501e45098f/activity_stream/explores/pocket_tile_impressions.explore.lkml#L6).
  - A subset of data with the most used dimensions. See this [aggregate for specific dimensions and a time frame](https://github.com/mozilla/looker-spoke-default/blob/e1315853507fc1ac6e78d252d53dc8df5f5f322b/mozilla_vpn/explores/subscriptions.explore.lkml#L66).
  - An aggregate that covers a commonly used dashboard or view. See this aggregate to support the views that include a [year over year analysis](https://github.com/mozilla/looker-spoke-default/blob/c3e1dba99fe29364fdc8d46bf3a4ea53cfa87c56/combined_browser_metrics/combined_browser_metrics.model.lkml#L18).
- Percentages, (e.g. in this view for [Focus Android DAU](https://mozilla.cloud.looker.com/looks/499), click through rates). These calculations are highly dependent on the dimensions and filters used and not always can be summed directly, therefore it is not recommended calculating them in BigQuery.
- Cumulative days of use. E.g. Implemented as a SUM in the [Browsers KPIs view](https://github.com/mozilla/looker-spoke-default/blob/c09b5dd11f977a0c20cf04c872e997712cbe6418/kpi/views/browser_kpis.view.lkml#L40).
