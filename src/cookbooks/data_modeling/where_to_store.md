# Introduction

For the purposes of this documentation, the analytics data model is defined as the set of data assets designed to collect meaningful data from our raw datasets and structure it for an efficient understanding and analysis of our products, business processes and events.

Mozilla’s current setup allows for the implementation of data modeling and business logic in different locations e.g BigQuery or Looker. The purpose of this document is to provide guidelines to decide where to store a new asset.


##What to check in a Pull Request in Looker

When reviewing a PR first check if the data required is already fully or partially implemented in an existing asset and always give preference to extending or making available in Looker existing datasets over creating new ones or moving the calculation to Looker.
- Check the [bigquery-etl repository](https://github.com/mozilla/bigquery-etl) for an existing dataset (table, aggregate, view, materialized view)
- Check the [looker-hub](https://github.com/mozilla/looker-hub) repository for the availability of the table in Looker.
- Check the [looker-spoke-default](https://github.com/mozilla/looker-spoke-default/tree/e1315853507fc1ac6e78d252d53dc8df5f5f322b) repository for existing Explores in Looker.


We want to avoid merging a PR in one of the Looker repositories that:

- Includes the definition of a core metric or the implementation of business logic e.g. the [type of search](https://github.com/mozilla/bigquery-etl/blob/a3e59f90326816a2ecaaa3e9d5b57fe9552f7d70/sql/moz-fx-data-shared-prod/search_derived/mobile_search_clients_daily_v1/query.sql#L781) or the [calculation of DAU or visited URIs](https://github.com/mozilla/bigquery-etl/blob/9bca48821a8a0d40b1700cc14ecd8068d132ed06/sql/moz-fx-data-shared-prod/telemetry_derived/firefox_desktop_exact_mau28_by_dimensions_v1/query.sql).
- Implements an analysis that may need to be replicated in the future, applies to different browsers or to different scenarios.
- Includes a transformation that needs to be tested and health checked.
- Includes a definition that is already implemented in a BigQuery dataset. If it is partially implemented e.g. not all the dimensions are available, the recommendation is to extend the dataset instead of moving the calculation to Looker.

For these cases, the recommendation in the PR is to move the implementation to bigquery-etl.


##What to store in BigQuery datasets and the bigquery-etl repository
- All transformations, calculations and business logic are stored in the bigquery-etl repository and the resulting datasets are stored in BigQuery as a derived table, an aggregate table, a view or a materialized view. Some examples:
- Calculations of DAU, WAU, MAU, new profiles.
- Calculation of search metrics (For ex. ad clicks, search with ads, organic searches).
- Calculation of acquisition, retention and churn metrics.
- Classification of events. E.g. The query for this PDT in the event type view would preferably be stored in BigQuery.
- Mapping from partner code to platform for Bing's revenue in Looker.
Segmentation of clients that require the implementation of business logic, rather than just filtering on certain columns.

##What to store in Looker

- Aggregates for summarization or creating a subset from a BigQuery dataset, and that don’t include business logic. Some examples:
  - A subset of data for a specific year. See this [aggregate for data after 2019 in Looker](https://github.com/mozilla/looker-spoke-default/blob/4ee892234963d3305f087b99a38caa501e45098f/activity_stream/explores/pocket_tile_impressions.explore.lkml#L6).
  - A subset of data with the most used dimensions. See this [aggregate for specific dimensions and a time frame](https://github.com/mozilla/looker-spoke-default/blob/e1315853507fc1ac6e78d252d53dc8df5f5f322b/mozilla_vpn/explores/subscriptions.explore.lkml#L66).
  - An aggregate that covers a commonly used dashboard or view. See this aggregate to support the views that include a [year over year analysis](https://github.com/mozilla/looker-spoke-default/blob/c3e1dba99fe29364fdc8d46bf3a4ea53cfa87c56/combined_browser_metrics/combined_browser_metrics.model.lkml#L18).
- Percentages, (e.g. in this view for [Focus Android DAU](https://mozilla.cloud.looker.com/looks/499), click through rates). These calculations are highly dependent on the dimensions and filters used and not always can be summed directly, therefore it is not recommended calculating them in BigQuery.
- Cumulative days of use. E.g. [this Looker view](https://github.com/mozilla/looker-spoke-default/blob/c09b5dd11f977a0c20cf04c872e997712cbe6418/kpi/views/browser_kpis.view.lkml#L40).