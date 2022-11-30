# Metric Hub

Metric Hub is a [repository](https://github.com/mozilla/metric-hub) that contains metric, data source and segment definitions that have been
reviewed and can be seen as the source of truth.
Definitions that are part of Metric Hub can be referenced in configurations of other tooling as well, such as [Jetstream](https://experimenter.info/jetstream/jetstream/) and [OpMon](https://docs.telemetry.mozilla.org/cookbooks/operational_monitoring.html?highlight=opmon#operational-monitoring-opmon).

Generated docs for available metrics is available [here](https://mozilla.github.io/metric-hub).

## Adding definitions

To add or update a project configuration, open a pull request against [metric-hub](https://github.com/mozilla/metric-hub).
CI checks will validate that the structure of the definitions as well as the SQL syntax is correct. A review by data science is required before changes can get merged.

Definitions are part of config files that are written in [TOML](https://toml.io/en/).
These definitions files are platform-specific and located in the [`definitions/` directory of the metric-hub repository](https://github.com/mozilla/metric-hub/tree/main/definitions). Definitions files are named after the platform they target, for example definitions related to Firefox Desktop are in the `firefox_desktop.toml` file.

Generally, configuration files have four main sections: `[data_sources]`, `[metrics]`, `[segments]`, and `[dimensions]`. All of these sections are optional.

Lines starting with a `#` are comments and have no effect.

### `[data_sources]` Section

Data sources specify the tables data should be queried from.

```toml
[data_sources]

[data_sources.main]
# FROM expression - often just a fully-qualified table name. Sometimes a subquery.
from_expression = "mozdata.telemetry.main"

# SQL snippet specifying the submission_date column
submission_date_column = "submission_date"

[data_sources.events_memory]
# FROM expression - subquery
from_expression = """
    (
        SELECT
            *
        FROM `moz-fx-data-shared-prod.telemetry.events`
        WHERE
            event_category = 'memory_watcher'
    )
"""
submission_date_column = "submission_date"
```

### `[metrics]` Section

The metrics sections allows to specify metrics. A metric aggregates data and is associated with some data source.

Each metric is identified by a unique slug, and can be defined by adding a new section with a name like:

`[metrics.<new_metric_slug>]`

```toml
[metrics]

[metrics.memory_pressure_count]

# The data source to use. Use the slug of a data source defined in a platform-specific config,
# or else define a new data source (see above).
data_source = "events_memory"

# A clause of a SELECT expression with an aggregation
select_expression = "SUM(SAFE_CAST(SPLIT(event_string_value, ',')[OFFSET(1)] AS NUMERIC))"

# Type of the metric to be evaluated.
# This is used to determine the method of aggregation to be applied.
# Either "scalar" or "histogram".
# scalar = a single value is returned
# histogram = an array of histograms is returned
type = "scalar"

# A friendly metric name displayed in dashboards.
friendly_name = "Memory Pressure Count"

# A description that will be displayed by dashboards.
description = "Number of memory pressure events"

# This can be any string value. It's currently not being used but in the future, this could be used to visually group different metrics by category.
category = "performance"

# And optional owner or team owning this metric
owner = "example@mozilla.org"

# Whether the metric is deprecated and should no longer be used
deprecated = false
```

Since metrics aggregate data, the metric SQL definition must contain some aggregation method (like `SUM`, `COUNT`, ...) to be valid.

Existing metrics cannot be removed after they have been added to Metric Hub. Other tools or configurations might still reference the
deleted metric resulting in their computations to break. Instead, to indicate that a metric should no longer be used `deprecated` should
be set to `true`.

### `[dimensions]` Section

Dimensions define a field or dimension on which the client population should be segmented. Dimensions are used in OpMon. For segmenting client populations clients see the `[segments]` section.

For example:

```toml
[dimensions]

[dimensions.os]
# The data source to use. Use the slug of a data source defined in a platform-specific config,
# or else define a new data source (see above).
data_source = "main"

# SQL snippet referencing a field whose values should be used to segment the client population.
select_expression = "normalized_os"
```

### `[segments]` Section

Segments specify a boolean condition that determines whether a client is part of the segment. Segment are used in Jetstream, for segmenting client populations in OpMon please see the `[dimensions]` section.

```toml
[segments.my_segment]
# Note the aggregation function; these expressions are grouped over client_id
select_expression = '{{agg_any("is_default_browser")}}'data_source = "my_data_source"

# segments require their own data source to be defined
# the standard `data_source`s cannot be used for segments
[segments.data_sources.my_data_source]
from_expression = '(SELECT submission_date, client_id, is_default_browser FROM my_cool_table)'
```

Segment SQL snippets need to be boolean expressions to be valid.

## Accessing and Using Metric Definitions

All the definitions are automatically available in some of our tooling:

- [Jetstream](https://experimenter.info/jetstream/jetstream/) - used for analyzing experiments
- [mozanalysis](https://github.com/mozilla/mozanalysis) - a Python library which standardizes how experiment data is analyzed at Mozilla
- [OpMon](https://docs.telemetry.mozilla.org/cookbooks/operational_monitoring.html) - a tool for monitoring operational metrics

Metric definitions can also be imported into Python scripts by using the [`mozilla-metric-config-parser`](https://github.com/mozilla/metric-config-parser). This library automatically parses the definitions in Metric Hub and returns their Python type representations.

```python
from metric_config_parser.config import ConfigCollection

config_collection = ConfigCollection.from_github_repo("https://github.com/mozilla/metric-hub")
metric = config_collection.get_metric_definition(slug="active_hours", app_name="firefox_desktop")
print(metric.from_expression)
```

To use the metrics with Mozanalysis, you'll need `Metric`s not `MetricDefinition`s. For example:

```python
from mozanalysis.config import ConfigLoader
metric = ConfigLoader.get_metric(slug="active_hours", app_name="firefox_desktop")
```

