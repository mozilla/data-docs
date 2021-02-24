# Scheduling Queries

Want to refresh a dashboard or other query against our data store automatically? There's a few options available, depending on what you want to do.

<!-- toc -->

## sql.telemetry.mozilla.org

This is by far the easiest option. Any query on [STMO](../tools/stmo.md) can be made to refresh itself automatically. This can be used to power both dashboards inside sql.telemetry.mozilla.org as well as web sites like the [Tab Spinner Dashboard](https://mikeconley.github.io/bug1310250/) and [Numbers that Matter](https://github.com/mozilla/funnel) via Redash's CSV and JSON APIs.

However, there are disadvantages to this approach:

- Every time it is refreshed, STMO re-runs the query from scratch. This is fine for smaller or less frequently updated dashboards but when querying a large amount of data, [this can get expensive](./bigquery/optimization.md).
- Aside from hand-rolled JavaScript or Python scripts, there isn't a way to run a query over the results of an STMO query.
- Queries on STMO are not peer reviewed and are not supported by Data SRE (read: no one will be notified if your query breaks).

## bigquery-etl

Mozilla's Data Engineering maintains a repository called [bigquery-etl](https://github.com/mozilla/bigquery-etl) which can incrementally create datasets based on an SQL query using our Airflow infrastructure. This requires a little bit more work to set up than scheduling a query on STMO, but has the advantage of being more cost effective, reliable, and amenable to further exploration.

Also, since the procedure for scheduling a query in this way is submitting a pull request against the bigquery-etl repository, this is an easy route to getting peer review from the extended Data Team.

For more information on how to use this approach, see [A quick guide to creating a derived dataset with bigquery-etl](https://mozilla.github.io/bigquery-etl/cookbooks/creating_a_derived_dataset/).

## Scheduling Queries using GCP

Finally, [you can schedule queries using GCP](https://cloud.google.com/bigquery/docs/scheduling-queries). This is generally not recommended, [reach out to the Data team](../concepts/getting_help.md) if you think you need to do this.

GCP scheduled queries are to be used only for short-lived queries: queries that are active for more than 30 days will be automatically unscheduled.
