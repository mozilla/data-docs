# Glean Data

The following describes in detail how we structure Glean data in BigQuery. For information on
the actual software which does this, see the [Generated Schemas](schemas.md) reference.
This document intended as a reference, if you want a tutorial on how best to access Glean Data in BigQuery,
see [Accessing Glean Data](../../cookbooks/accessing_glean_data.md).

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

### The `events` group

Events are stored as a set of records in a single column called "events": there might be many events sent as part of a single ping.
Each record has the following fields which allow you to filter for the specific metrics of interest:

- category (maps to the metric category)
- name (maps to the metric name)

For example, suppose you had the following `event` metric defined in a `metrics.yaml` file (again, abridged for clarity):

```yaml
engine_tab:
  foreground_metrics:
    type: event
    description: |
      Event collecting data about the state of tabs when the app comes back to
      the foreground.
        extra_keys:
    extra_keys:
      background_active_tabs:
        description: |
          Number of active tabs (with an engine session assigned) when the app
          went to the background.
        ...
```

In this case the event's `category` would be `engine_tab` and its name would be `foreground_metrics`.

You can use the record's `timestamp` and `extra` fields to get the event's timestamp and specifics related
to the event.
For a complete example, see ["event metrics" under Accessing Glean Data](../../cookbooks/accessing_glean_data.md#event-metrics).
