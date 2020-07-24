The `clients_last_seen` dataset is useful for efficiently determining exact
user counts such as [DAU and MAU](../../../cookbooks/dau.md).
It can also allow efficient calculation of other windowed usage metrics
like retention via its [bit pattern fields](../../../cookbooks/clients_last_seen_bits.md).

It does *not* use approximates, unlike the HyperLogLog algorithm used in the
[`client_count_daily` dataset](/datasets/obsolete/client_count/reference.md),
and it includes the most recent values in a 28 day window for all columns in
the [`clients_daily` dataset](/datasets/batch_view/clients_daily/reference.md).

This dataset should be used instead of `client_count_daily`.

#### Content

For each `submission_date` this dataset contains one row per `client_id`
that appeared in `clients_daily` in a 28 day window including
`submission_date` and preceding days.

The `days_since_seen` column indicates the difference between `submission_date`
and the most recent `submission_date` in `clients_daily` where the `client_id`
appeared. A client observed on the given `submission_date` will have `days_since_seen = 0`.

Other `days_since_` columns use the most recent date in `clients_daily` where
a certain condition was met. If the condition was not met for a `client_id` in
a 28 day window `NULL` is used. For example `days_since_visited_5_uri` uses the
condition `scalar_parent_browser_engagement_total_uri_count_sum >= 5`. These
columns can be used for user counts where a condition must be met on any day
in a window instead of using the most recent values for each `client_id`.

The `days_seen_bits` field stores the daily history of a client in the 28 day
window. The daily history is converted into a sequence of bits, with a `1` for
the days a client is in `clients_daily` and a `0` otherwise, and this sequence
is converted to an integer. A tutorial on how to use these bit patterns to
create filters in SQL can be found in
[this notebook](https://colab.research.google.com/drive/13AwwORpOtRsq22op_3rMSwPssQkJU1ok).

The rest of the columns use the most recent value in `clients_daily` where
the `client_id` appeared.

#### Background and Caveats

User counts generated using `days_since_seen` only reflect the most recent
values from `clients_daily` for each `client_id` in a 28 day window. This means
[Active MAU](../../../cookbooks/active_dau.md)
as defined cannot be efficiently calculated using `days_since_seen` because if
a given `client_id` appeared every day in February and only on February 1st had
`scalar_parent_browser_engagement_total_uri_count_sum >= 5` then it would only
be counted on the 1st, and not the 2nd-28th. Active MAU can be efficiently and
correctly calculated using `days_since_visited_5_uri`.

MAU can be calculated over a `GROUP BY submission_date[, ...]` clause using
`COUNT(*)`, because there is exactly one row in the dataset for each
`client_id` in the 28 day MAU window for each `submission_date`.

User counts generated using `days_since_seen` can use `SUM` to reduce groups,
because a given `client_id` will only be in one group per `submission_date`. So
if MAU were calculated by `country` and `channel`, then the sum of the MAU for
each `country` would be the same as if MAU were calculated only by `channel`.

#### Accessing the Data

The data is available in STMO and BigQuery. Take a look at this full running
[example query in STMO](https://sql.telemetry.mozilla.org/queries/62029/source#159510).
