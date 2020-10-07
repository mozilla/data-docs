# Jetstream datasets

<!-- toc -->

Statistical summaries of telemetry data from experiments run in Mozilla
products are provided by [Jetstream]. These summaries are published to
BigQuery and serve both as the substrate for the result visualization
platform and as a resource for data scientists.

Jetstream runs as part of the nightly ETL job (see [Scheduling](#scheduling) below).
Jetstream is also run after pushes to the [`jetstream-config`] repository.
Jetstream publishes tables to the dataset `moz-fx-data-experiments.mozanalysis`.

Experiments are analyzed using the concept of analysis windows. Analysis
windows describe an interval marked from each client’s day of
enrollment. The “day 0” analysis window aggregates data from the days
that each client enrolled in the experiment. Because the intervals are
demarcated from enrollment, they are not calendar dates; for some
clients in an experiment, day 0 could be a Tuesday, and for others a
Saturday.

The week 0 analysis window aggregates data from each client’s days 0
through 6, the week 1 window aggregates data from days 7 through 13, and
so on.

Clients are given a fixed amount of time, specified in Experimenter and
often a week long, to enroll. Final day 0 results are available for
reporting at the end of the enrollment period, after the last eligible
client has enrolled, and week 0 results are available a week after the
enrollment period closes. Results for each window are published as soon
as complete data is available for all enrolled clients.

The “overall” window, published after the experiment has ended, is a
window beginning on each client’s day 0 that spans the longest period
for which all clients have complete data.

Jetstream computes statistics over several metrics by default, including
for any features associated with the experiment in Experimenter. Data
scientists can provide configuration to add additional metrics. Advice
on configuring Jetstream can be found at the [`jetstream-config`] repository.

[jetstream]: https://github.com/mozilla/jetstream
[`jetstream-config`]: https://github.com/mozilla/jetstream-config

## Statistics tables

The statistics tables contain statistical summaries of their
corresponding aggregate tables. These tables are suitable for plotting
directly without additional transformations.

Statistics tables are named like:

`statistics_<slug>_{day, week, overall}_<index>`

A view is also created that concatenates all statistics tables for an
experiment of a given period type, named like:

`statistics_<slug>_{daily, weekly, overall}`

Statistics tables have the schema:

| Column name            | Type                | Description                                                                                                                                                                                                                      |
| ---------------------- | ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `segment`              | `STRING`            | The segment of the population being analyzed. “all” for the entire population.                                                                                                                                                   |
| `metric`               | `STRING`            | The slug of the metric, like `active_ticks` or `retained`                                                                                                                                                                        |
| `statistic`            | `STRING`            | The slug of the statistic that was used to summarize the metric, like “mean” or “deciles”                                                                                                                                        |
| `parameter`            | `NUMERIC` (decimal) | A statistic-dependent quantity. For two-dimensional statistics like “decile,” this represents the x axis of the plot. For one-dimensional statistics, this is NULL.                                                              |
| `comparison`           | `STRING`            | If this row represents a comparison between two branches, this row describes what kind of comparison, like `difference` or `relative_uplift`. If this row represents a measurement of a single branch, then this column is NULL. |
| `comparison_to_branch` | `STRING`            | If this row represents a comparison between two branches, this row describes which branch is being compared to. For simple A/B tests, this will be “control.”                                                                    |
| `ci_width`             | `FLOAT64`           | A value between 0 and 1 describing the width of the confidence interval represented by the lower and upper columns. Valued at 0.95 for 95% confidence intervals.                                                                 |
| `point`                | `FLOAT64`           | The point estimate of the statistic for the metric given the parameter.                                                                                                                                                          |
| `lower`                | `FLOAT64`           | The lower bound of the confidence interval for the estimate.                                                                                                                                                                     |
| `upper`                | `FLOAT64`           | The upper bound of the confidence interval for the estimate.                                                                                                                                                                     |
| `window_index`         | `INT64`             | (views only) A base-1 index reflecting the analysis window from which the row is drawn (i.e. day 1, day 2, …).                                                                                                                   |

Each combination of `(segment, metric, statistic, parameter, comparison, comparison_to_branch, ci_width)` uniquely describes a single data
point.

The available segments in a table should be derived from inspection of
the table.

[Jetstream’s Github wiki][jetstream-wiki] has a description of each statistic and
comparison.

### Examples

To extract the mean of `active_hours` for each branch from a weekly
statistics view with a name like `statistics_bug_12345_slug_weekly`,
you could run the query:

```sql
SELECT
    segment,
    window_index AS week,
    branch,
    point,
    lower,
    upper
FROM `moz-fx-data-experiments`.mozanalysis.statistics_bug_12345_slug_weekly
WHERE
    metric = "active_hours"
    AND statistic = "mean"
    AND comparison IS NULL
```

This query would return a row for each user segment, for each week of
the experiment, for each branch, with the mean of the `active_hours`
metric.

To see whether the absolute difference of the mean of `active_hours` was
different between the control and treatment branches, you could run:

```sql
SELECT
    window_index AS week,
    branch,
    point,
    lower,
    upper
FROM `moz-fx-data-experiments`.mozanalysis.statistics_bug_12345_slug_weekly
WHERE
    metric = "active_hours"
    AND statistic = "mean"
    AND comparison = "difference"
    AND branch = "treatment"
    AND comparison_to_branch = "control"
    AND segment = "all"
```

This query would return a row for each week of the experiment containing
an estimate of the absolute difference between the treatment and control
branches for the segment containing all users.

[jetstream-wiki]: https://github.com/mozilla/jetstream/wiki

## Client-window aggregate tables

The aggregate tables contain one row per enrolled `client_id`. An
aggregate table is written for each analysis window. The statistics
tables are derived from the aggregate tables. The aggregate tables are
less useful without additional processing but they may be useful for
diagnostics.

Aggregate tables are named like:

`<slug>_{day,week,overall}_<index>`

Aggregate tables have flexible schemas. Every table contains the
columns:

| Column name             | Type     | Description                                                                              |
| ----------------------- | -------- | ---------------------------------------------------------------------------------------- |
| `client_id`             | `STRING` | Client’s telemetry `client_id`                                                           |
| `branch`                | `STRING` | Branch client enrolled in                                                                |
| `enrollment_date`       | `DATE`   | First date that the client enrolled in the branch                                        |
| `num_enrollment_events` | `INT64`  | Number of times a client enrolled in the given branch                                    |
| `analysis_window_start` | `INT64`  | The day after enrollment that this analysis window began; day 0 is the day of enrollment |
| `analysis_window_end`   | `INT64`  | The day after enrollment that this analysis window terminated (inclusive)                |

The combination of `(client_id, branch)` is unique.

Each metric associated with the experiment defines an additional
(arbitrarily-typed) column.

Each data source associated with the experiment defines additional
`<data_source>_has_contradictory_branch` and
`<data_source>_has_non_enrolled_data` columns, which respectively
indicate whether `client_id` reported data from more than one branch or
without any tagged branch in that dataset over that analysis window.

Each segment associated with the experiment defines an additional boolean column.

## Scheduling

Jetstream is updated nightly by telemetry-airflow.
It is invoked by the [`jetstream` DAG](https://github.com/mozilla/telemetry-airflow/blob/master/dags/jetstream.py).

## Code reference

Jetstream's datasets are generated by invoking [Jetstream].
Data scientists can configure Jetstream or trigger a Jetstream invocation
by interacting with the [`jetstream-config`] repository.
