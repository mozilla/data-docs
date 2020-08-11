# Jetstream datasets

<!-- toc -->

Statistical summaries of telemetry data from experiments run in Mozilla
products are provided by Jetstream. These summaries are published to
BigQuery and serve both as the substrate for the result visualization
platform and as a resource for data scientists.

Jetstream runs as part of the nightly ETL job. The tables are published
to the dataset `moz-fx-data-experiments.mozanalysis`.

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
on configuring Jetstream can be found at Jetstream’s Github wiki.

# Statistics tables

The statistics tables contain statistical summaries of their
corresponding aggregate tables. These tables are suitable for plotting
directly without additional transformations.

Statistics tables are named like:

`statistics_<slug>_{day, week, overall}_<index>`

A view is also created that concatenates all statistics tables for an
experiment of a given period type, named like:

`statistics_<slug>_{daily, weekly, overall}`

Statistics tables have the schema:

<table>
<thead>
<tr class="header">
<th>Column name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>`segment`</td>
<td>STRING</td>
<td>The segment of the population being analyzed. “all” for the entire population.</td>
</tr>
<tr class="even">
<td>`metric`</td>
<td>STRING</td>
<td>The slug of the metric, like `active_ticks` or `retained`</td>
</tr>
<tr class="odd">
<td>`statistic`</td>
<td>STRING</td>
<td>The slug of the statistic that was used to summarize the metric, like “mean” or “deciles”</td>
</tr>
<tr class="even">
<td>`parameter`</td>
<td>NUMERIC (decimal)</td>
<td>A statistic-dependent quantity. For two-dimensional statistics like “decile,” this represents the x axis of the plot. For one-dimensional statistics, this is NULL.</td>
</tr>
<tr class="odd">
<td>`comparison`</td>
<td>STRING</td>
<td>If this row represents a comparison between two branches, this row describes what kind of comparison, like `difference` or `relative_uplift`. If this row represents a measurement of a single branch, then this column is NULL.</td>
</tr>
<tr class="even">
<td>`comparison_to_branch`</td>
<td>STRING</td>
<td>If this row represents a comparison between two branches, this row describes which branch is being compared to. For simple A/B tests, this will be “control.”</td>
</tr>
<tr class="odd">
<td>`ci_width`</td>
<td>FLOAT64</td>
<td>A value between 0 and 1 describing the width of the confidence interval represented by the lower and upper columns. Valued at 0.95 for 95% CIs.</td>
</tr>
<tr class="even">
<td>`point`</td>
<td>FLOAT64</td>
<td>The point estimate of the statistic for the metric given the parameter.</td>
</tr>
<tr class="odd">
<td>`lower`</td>
<td>FLOAT64</td>
<td>The lower bound of the confidence interval for the estimate.</td>
</tr>
<tr class="even">
<td>`upper`</td>
<td>FLOAT64</td>
<td>The upper bound of the confidence interval for the estimate.</td>
</tr>
<tr class="odd">
<td>`window_index`</td>
<td>INT64</td>
<td>(views only) A base-1 index reflecting the analysis window from which the row is drawn (i.e. day 1, day 2, …).</td>
</tr>
</tbody>
</table>

Each combination of `(segment, metric, statistic, parameter, comparison,
comparison_to_branch, ci_width)` uniquely describes a single data
point.

To extract the mean of `active_hours` for each branch from a weekly
statistics view v, you could run the query:

```sql
SELECT
    segment,
    window_index AS week,
    branch,
    point,
    lower,
    upper
FROM v
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
FROM v
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

The available segments in a table should be derived from inspection of
the table.

Jetstream’s Github wiki has a description of each statistic and
comparison.

# Client-window aggregate tables

The aggregate tables contain one row per enrolled `client_id`. An
aggregate table is written for each analysis window. The statistics
tables are derived from the aggregate tables. The aggregate tables are
less useful without additional processing but they may be useful for
diagnostics.

Aggregate tables are named like:

`<slug>_{day,week,overall}_<index>`

Aggregate tables have flexible schemas. Every table contains the
columns:

<table>
<thead>
<tr class="header">
<th>Column name</th>
<th>Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>`client_id`</td>
<td>STRING</td>
<td>Client’s telemetry `client_id`</td>
</tr>
<tr class="even">
<td>`branch`</td>
<td>STRING</td>
<td>Branch client enrolled in</td>
</tr>
<tr class="odd">
<td>`enrollment_date`</td>
<td>DATE</td>
<td>First date that the client enrolled in the branch</td>
</tr>
<tr class="even">
<td>`num_enrollment_events`</td>
<td>INT64</td>
<td>Number of times a client enrolled in the given branch</td>
</tr>
<tr class="odd">
<td>`analysis_window_start`</td>
<td>INT64</td>
<td>The day after enrollment that this analysis window began; day 0 is the day of enrollment</td>
</tr>
<tr class="even">
<td>`analysis_window_end`</td>
<td>INT64</td>
<td>The day after enrollment that this analysis window terminated (inclusive)</td>
</tr>
</tbody>
</table>

The combination of `(client_id, branch)` is unique.

Each metric associated with the experiment defines an additional
(arbitrarily-typed) column.

Each data source associated with the experiment defines additional
`<data_source>_has_contradictory_branch` and
`<data_source>_has_non_enrolled_data` columns, which respectively
indicate whether `client_id` reported data from more than one branch or
without any tagged branch in that dataset over that analysis window.
