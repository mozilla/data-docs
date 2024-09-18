# Cost considerations

The Freshness and Volume metrics, which represent Pipeline Reliability, are included in the free tier. There is no charge when these metrics are added to a table.

However, if additional monitors are added to a table, it becomes a billable table, and charges will apply based on the number of billable tables.

**Try to avoid Autometrics!** - On tables with many columns a large number of monitors might get deployed. This increases noise and cost. Instead, it is recommended to [choose relevant metrics from the list of available metrics](deploying_metrics.md#list-of-available-metrics) manually.
