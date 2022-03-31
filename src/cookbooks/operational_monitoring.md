# Operational Monitoring (OpMon)

[Operational Monitoring (OpMon)](https://github.com/mozilla/opmon) is a self-service tool that aggregates and summarizes operational metrics that indicate the health of software.
OpMon can be used to continuously monitor rollouts, experiments (including experiments with continuous enrollments) or the population of a specific product (for example, Firefox Desktop).
OpMon automatically generates Looker dashboards that will provide insights into whether landing code changes impact certain metrics in a meaningful way.

A couple of specific use cases are supported:

1. Monitoring build over build. This is typically used for Nightly where one build may contain changes that a previous build doesn't and we want to see if those changes affected certain metrics.
2. Monitoring by submission date over time. This is helpful for a rollout in Release for example, where we want to make sure there are no performance or stability regressions over time as a new build rolls out.

The monitoring dashboards produced for these use cases are available in [Looker](https://mozilla.cloud.looker.com/folders/494).
OpMon does not emit real-time results. Dashboards and related datasets get updated on a daily basis.

Access to the Looker Operational Monitoring dashboards is currently limited to Mozilla employees and designated contributors. For more information, see [gaining access](../concepts/gaining_access.md).

## Configuring a Operational Monitoring project

To add or update a project configuration, open a pull request against [opmon-config](https://github.com/mozilla/opmon-config).
CI checks will validate the columns, data sources, and SQL syntax. Once CI completes, the pull request can be merged and results for the new project will be available within the next 24 hours.

Project configurations files are written in [TOML](https://toml.io/en/). To reuse configurations across multiple projects, project configurations can reference configurations from definition files.
These definitions files are platform-specific and located in the `definitions/` directory of [opmon-config](https://github.com/mozilla/opmon-config). Platform-specific configuration files follow the same format and structure as project configuration files.

If the project is used to monitor a rollout or experiment, then the configuration files should have the same name as the slug that has been assigned in [Experimenter](https://experimenter.services.mozilla.com/).
Generally, configuration files have four main sections: `[project]`, `[data_sources]`, `[probes]`, and `[dimensions]`. All of these sections are optional.

Examples of every value you can specify in each section are given below. **You do not need to, and should not, specify everything!**
OpMon will take values from Experimenter (for rollouts and experiments) and combine them with a reasonable set of defaults.

Lines starting with a `#` are comments and have no effect.

### `[project]` Section

This part of the configuration file is optional and allows to:

- specify the probes that should be analyzed
- define the clients that should be monitored
- indicate if/how the client population should be segmented, and
- override some values from Experimenter

This section is usually not specified in definition configuration.

```toml
[project]
# A custom, descriptive name of the project.
# This will be used as the generated Looker dashboard title.
name = "A new operational monitoring project"

# The name of the platform this project targets.
# For example, "firefox_desktop", "fenix", "firefox_ios", ...
platform = "firefox_desktop"

# Specifies the type of monitoring desired as described above.
# Either "submission_date" (to monitor each day) or "build_id" (to monitor build over build)
xaxis = "submission_date"

# Both start_date and end_date can be overridden, otherwise the dates configured in
# Experimenter will be used as defaults.
start_date = "2022-01-01"

# Metrics, that are based on probes, to compute.
# Defined as a list of strings. These strings are the "slug" of the metric, which is the
# name of the metric definition section in either the project configuration or the platform-specific
# configuration file.
# See [probes] section on how these metrics get defined.
probes = [
    'shutdown_hangs',
    'oom_crashes',
    'main_crashes',
    'startup_crashes'
]

# This section specifies the clients that should be monitored.
[project.population]

# Slug/name fo the data source definition section in either the project configuration or the platform-specific
# configuration file. This data source refers to a database table.
# See [data_sources] section on how this gets defined.
data_source = "main"

# The name of the branches that have been configured for a rollout or experiment.
# If defined, this configuration overrides boolean_pref.
branches = ["enabled", "disabled"]

# A SQL snippet that results in a boolean representing whether a client is included in the rollout or experiment or not.
boolean_pref = "environment.settings.fission_enabled"

# The channel the clients should be monitored from: "release", "beta", or "nightly".
channel = "beta"

# If set to "true", the rollout and experiment configurations will be ignored and instead
# the entire client population (regardless of whether they are part of the experiment or rollout)
# will be monitored.
# This option is useful if the project is not associated to a rollout or experiment and the general
# client population of a product should be monitored.
monitor_entire_population = false

# References to dimension slugs that are used to segment the client population.
# Defined as a list of strings. These strings are the "slug" of the dimension, which is the
# name of the dimension definition section in either the project configuration or the platform-specific
# configuration file. See [dimensions] section on how these get defined.
dimensions = ["os"]
```

### `[data_sources]` Section

Data sources specify the tables data should be queried from.

In most cases, it is not necessary to define project-specific data sources, instead data sources can be specified in and referenced from the
platform-specific definition configurations.

```toml
[data_sources]

[data_sources.main]
# FROM expression - often just a fully-qualified table name. Sometimes a subquery.
from_expression = "mozdata.telemetry.main"

# SQL snippet specifying the submission_date column
submission_date_column = "DATE(submission_timestamp)"

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
submission_date_column = "DATE(submission_date)"
```

### `[probes]` Section

The probes sections allows to specify metrics based on probes that should be monitored.

In most cases, it is not necessary to define project-specific probes, instead probes can be specified and referenced from the
platform-specific definition configurations.

A new probe can be defined by adding a new section with a name like:

`[probes.<new_probe_slug>]`

```toml
[probes]

[probes.memory_pressure_count]

# The data source to use. Use the slug of a data source defined in a platform-specific config,
# or else define a new data source (see above).
data_source = "events_memory"

# A clause of a SELECT expression
select_expression = "SAFE_CAST(SPLIT(event_string_value, ',')[OFFSET(1)] AS NUMERIC)"

# Type of the probe to be evaluated.
# This is used to determine the method of aggregation to be applied.
# Either "scalar" or "histogram".
type = "scalar"

# A friendly metric name displayed in dashboards.
friendly_name = "Memory Pressure Count"

# A description that will be displayed by dashboards.
description = "Number of memory pressure events"

# This can be any string value. It's currently not being used but in the future, this could be used to visually group different probes by category.
category = "performance"
```

### `[dimensions]` Section

Dimensions define how the client population should be segmented.

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

The `os` dimension will result in the client population being segmented by operation system. For each dimension a filter is being added to the resulting
dashboard which allows to, for example, only show results for all Windows clients.

## Data Products

OpMon writes monitoring results and metadata to BigQuery. OpMon runs as part of the nightly ETL job (see [Scheduling](#scheduling) below).

### Result Tables

The result tables that back the Looker dashboards are available in the `operational_monitoring_derived` dataset in `moz-fx-data-shared-prod`.
Result tables are named like:

`<slug>_<data_type>`

`<slug>` is referring to the slug that has been set for the project and a separate table is created for each `data_type` (scalar and histogram). The schema for result tables is flexible and slightly different for each data type.

Views for each tables are also created in the `operational_monitoring` dataset. These views will compute the percentiles based on the generated results and are used by the Looker dashboards.

#### Scalar result tables

| Column name       | Type     | Description                                        |
| ----------------- | -------- | -------------------------------------------------- |
| `submission_date` | `DATE`   | Date the monitoring results are for                |
| `client_id`       | `STRING` | Client's telemetry `client_id`                     |
| `branch`          | `STRING` | Branch client is enrolled in                       |
| `build_id`        | `STRING` | Build the client is on                             |
| `name`            | `STRING` | Slug of the probe-based metric the results are for |
| `agg_type`        | `STRING` | The type of aggregation used (`MAX`, `SUM`)        |
| `value`           | `FLOAT`  | The result value                                   |

The result table will have additional columns for each dimension that has been defined.

#### Histogram Result Tables

| Column name       | Type     | Description                                        |
| ----------------- | -------- | -------------------------------------------------- |
| `submission_date` | `DATE`   | Date the monitoring results are for                |
| `client_id`       | `STRING` | Client's telemetry `client_id`                     |
| `branch`          | `STRING` | Branch client is enrolled in                       |
| `build_id`        | `STRING` | Build the client is on                             |
| `probe`           | `STRING` | Slug of the probe-based metric the results are for |
| `value`           | `RECORD` | This record is a histogram                         |

The result table will have additional columns for each dimension that has been defined.

### Metadata

The table `projects_v1` in `operational_monitoring_derived` contains metadata about the configured projects that is required for generating the dashboards. The table is updated after each ETL run for a specific project.

| Column name  | Type     | Description                                                                              |
| ------------ | -------- | ---------------------------------------------------------------------------------------- |
| `slug`       | `STRING` | Project slug                                                                             |
| `name`       | `STRING` | Descriptive name of the project used as dashboard title                                  |
| `xaxis`      | `STRING` | Specifies which column should be used as x-axis (either "submission_date" or "build_id") |
| `branches`   | `ARRAY`  | List of branch names                                                                     |
| `dimensions` | `ARRAY`  | List of dimension slugs                                                                  |
| `start_date` | `DATE`   | Date for when monitoring should start for the project                                    |
| `end_date`   | `DATE`   | Date for when monitoring should end for the project                                      |
| `probes`     | `RECORD` | Repeated record with the probe slug and aggregation type                                 |

### Scheduling

OpMon is updated nightly by telemetry-airflow. It is invoked by the [operational_monitoring DAG](https://github.com/mozilla/telemetry-airflow/blob/main/dags/operational_monitoring.py).

## Experiments vs OpMon

The requirements for Operational Monitoring are related to, but mostly distinct from those for experiments:

- With an A/B experiment, the goal is to determine with confidence whether a single change (i.e. the treatment) has an expected impact on a metric or small number of metrics. The change is only applied to a sample of clients for a fixed period of time.
- With operational monitoring, a project team is making many changes over a long but indeterminate period of time and must identify if any one change or set of changes (e.g., changes in a given Nightly build) moves a metric in the target population. An identified metric impact may result in a change being backed out, but may also be used to guide future project work.

OpMon can be used to monitor experiments. For experiments with continuous enrollments or no fixed end date, OpMon will provide insights that would otherwise not be available. Other experiments, that are interested in looking at operational metrics could also benefit from OpMon.

## Going Deeper

To get a deeper understanding of what happens under the hood, please see the [opmon repository and developer documentation](https://github.com/mozilla/opmon).

## Getting Help

If you have further questions, please reach out on the [#data-help](https://mozilla.slack.com/archives/C4D5ZA91B) Slack channel.
