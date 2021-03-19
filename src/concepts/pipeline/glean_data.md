# Glean Data

The following describes in detail how we structure Glean data in BigQuery. For information on
the actual software which does this, see the [Generated Schemas](schemas.md) reference.

## Tables

Each ping type is recorded in its own table, and these tables are named using `{application_id}.{ping_type}`.
For example, for Fenix, the application id is `org.mozilla.fenix`, so its `metrics` pings are available in the table `org_mozilla_fenix.metrics`.

## Columns

Fields are nested inside BigQuery STRUCTs to organize them into groups, and we can use dot notation to specify individual subfields in a query.
For example, columns containing Glean's built-in client information are in the `client_info` struct, so accessing its columns involves using a `client_info.` prefix.

The top-level groups are:

- `client_info`: [Client information provided by Glean](https://mozilla.github.io/glean/book/user/pings/index.html#the-client_info-section).
- `ping_info`: [Ping information provided by Glean](https://mozilla.github.io/glean/book/user/pings/index.html#the-ping_info-section).
- `metrics`: [Custom metrics](https://mozilla.github.io/glean/book/user/metrics/index.html) defined by the application and its libraries.
- `events`: [Custom events](https://mozilla.github.io/glean/book/user/metrics/event.html) defined by the application and its libraries.

### Ping and Client Info sections

[Core attributes sent with every ping](https://mozilla.github.io/glean/book/user/pings/index.html#glean-pings) are mapped to the [`client_info`](https://mozilla.github.io/glean/book/user/pings/index.html#the-client_info-section) and [`ping_info`](https://mozilla.github.io/glean/book/user/pings/index.html#the-ping_info-section) sections.
For example, the client id is mapped to a column called `client_info.client_id`.

### The `metrics` group

Custom metrics in the `metrics` section have two additional levels of indirection in their column name: they are organized by the metric type, and then by their category: `metrics.{metric_type}.{category}_{name}`.

For example, suppose you had the following `boolean` metric defined in a `metrics.yaml` file (abridged for clarity):

```yaml
browser:
  is_default:
    type: boolean
    description: >
      Is this application the default browser?
    send_in_pings:
      - metrics
```

It would be available in the column `metrics.boolean.browser_is_default`.

```sql
-- Count number of pings where Fenix is the default browser
SELECT
  COUNT(*),
  COUNTIF(metrics.boolean.browser_is_default)
FROM
  -- We give the table an alias so that the table name `metrics` and field name
  -- `metrics` don't conflict.
  org_mozilla_fenix.metrics AS m
WHERE
  date(submission_timestamp) = '2019-11-11'
```

### The `events` group

Custom events in the `events` section have a different structure.

Documentation TBD. [See bug 1606836](https://bugzilla.mozilla.org/show_bug.cgi?id=1606836)
