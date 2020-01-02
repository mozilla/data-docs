# Accessing Glean data

This document describes how to access Glean data from an SQL query, such as in [Redash](https://sql.telemetry.mozilla.org).

## Selecting the correct table

Each ping type is recorded in its own table, and these tables are named using `{application_id}.{ping_type}`.
For example, for Fenix, the application id is `org_mozilla_fenix`, so its `metrics` pings are available in the table `org_mozilla_fenix.metrics`.

## Selecting columns

Columns of data are named using dot notation to organize them into groups.
For example, columns containing Glean's built-in client information all begin with the `client_info.` prefix.

The top-level groups are:

* `client_info`: [Client information provided by Glean](https://mozilla.github.io/glean/book/user/pings/index.html#the-client_info-section).
* `ping_info`: [Ping information provided by Glean](https://mozilla.github.io/glean/book/user/pings/index.html#the-ping_info-section).
* `metrics`: [Custom metrics](https://mozilla.github.io/glean/book/user/metrics/index.html) defined by the application and its libraries.
* `events`: [Custom events](https://mozilla.github.io/glean/book/user/metrics/event.html) defined by the application and its libraries.

### Built-in metrics

Accessing columns from the `client_info`, and `ping_info` group is reasonably straightforward.

For example, to access the `client_id` of a ping, use the column `client_info.client_id`.

```sql
-- Count unique Client IDs observed on a given day
SELECT
  count(distinct client_info.client_id)
FROM
  org_mozilla_fenix.baseline
WHERE
  date(submission_timestamp) = '2019-11-11'
```

### The `metrics` group

Custom metrics in the `metrics` section have two additional levels of indirection in their column name: they are organized by the metric type, and then by their category: `metrics.{metric_type}.{category}_{name}`. 

For example, suppose you had the following `boolean` metric defined in a `metrics.yaml` file (abridged for clarity):

```yaml
metrics:
  default_browser:
    type: boolean
    description: >
      Is this application the default browser?
    send_in_pings:
    - metrics
```

It would be availabe in the column `metrics.boolean.metrics_default_browser`.

```sql
-- Count number of pings where Fenix is the default browser
SELECT
  COUNT(*),
  COUNTIF(metrics.metrics.boolean.metrics_default_browser)
FROM
  org_mozilla_fenix.metrics
WHERE
  date(submission_timestamp) = '2019-11-11'
```

### The `events` group

Custom events in the `events` section have a different structure.

Documentation TBD.
