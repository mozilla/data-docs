The churn dataset tracks the 7-day churn rate of telemetry profiles. This
dataset is generally used for analyzing cohort churn across segments and time.

#### Content

Churn is the rate of attrition defined by `(clients seen in week N)/(clients seen in week 0)`
for groups of clients with some shared attributes. A group of clients with
shared attributes is called a *cohort*. The cohorts in this dataset are created
every week and can be tracked over time using the `acquisition_date` and the
weeks since acquisition or `current_week`.

The following example demonstrates the current logic for generating this
dataset. Each column represents the days since some arbitrary starting date.

|   client | 00 | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 | 12 | 13 | 14 |
|----------|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|
| A        | X  |    |    |    |    |    |    | X  |    |    |    |    |    |    |    |
| B        |    | X  | X  | X  | X  | X  | X  |    |    |    |    |    |    |    |    |
| C        | X  |    |    |    |    |    |    |    |    |    |    |    |    |    | X  |

All three clients are part of the same cohort. Client A is retained for weeks 0
and 1 since there is activity in both periods. A client only needs to show up
once in the period to be counted as retained. Client B is acquired in week 0 and
is active frequently but does not appear in following weeks. Client B is
considered churned on week 1. However, a client that is churned can become
retained again. Client C is considered churned on week 1 but retained on week 3.

The following table summarizes the above daily activity into the following view
where every column represents the current week since acquisition date..

|   client | 0 | 1 |  2 |
|----------|---|---|----|
| A        | X | X |    |
| B        | X |   |    |
| C        | X |   | X  |


The clients are then grouped into cohorts by attributes. An attribute describes
a property about the cohort such as the country of origin or the binary
distribution channel. Each group also contains descriptive aggregates of
engagement. Each metric describes the activity of a cohort such as size and
overall usage at a given time instance.


#### Background and Caveats

* Each row in this dataset describes a unique segment of users
  - The number of rows is exponential with the number of dimensions
  - New fields should be added sparing to account for data-set size
* The dataset lags by 10 days in order account for submission latency
  - This value was determined to be time for 99% of main pings to arrive at the
    server. With the shutdown-ping sender, this has been reduced to 4 days.
    However, `churn_v3` still tracks releases older than Firefox 55.
* The start of the period is fixed to Sundays. Once it has been aggregated, the
  period cannot be shifted due to the way clients are counted.
  - A supplementary 1-day `retention` dataset using HyperLogLog for client
    counts is available for counting over arbitrary retention periods and date
    offsets. Additionally, calculating churn or retention over specific cohorts
    is tractable in STMO with `main_summary` or `clients_daily` datasets.

#### Accessing the Data

`churn` is available in Redash under Athena and Presto. The data is also
available in parquet for consumption by columnar data engines at
`s3://telemetry-parquet/churn/v3`.
