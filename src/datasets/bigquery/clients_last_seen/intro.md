The `clients_last_seen` dataset is useful for determining exact user counts
such as MAU, WAU, and DAU.

The `clients_last_seen` dataset is similar to the
[`client_count_daily` dataset](/datasets/batch_view/client_count/reference.md)
except it is used to efficiently generate exact counts, and it includes the most
recent values in a 28 day window for all columns from the
[`clients_daily` dataset](/datasets/batch_view/clients_daily/reference.md).

#### Content

For each `submission_date` this dataset contains one row per `client_id`
that appeared in the [`clients_daily`
dataset](/datasets/batch_view/clients_daily/reference.md)
in a 28 day window including `submission_date`. The `generated_timestamp`
column indicates when the row was generated. The `last_seen_date` column
indicates the date the client last appeared in `clients_daily`.

#### Background and Caveats

User counts from this table only check the most recent column values for a
client. This means [Active MAU](../../../cookbooks/active_dau.md) as defined
cannot be calculated from `last_seen_date` because if a given `client_id`
appeared every day in February and only on February 1st had
`scalar_parent_browser_engagement_total_uri_count_sum >= 5` then it would only
be counted on the 1st, and not the 2nd-28th.

MAU can be calculated over a `GROUP BY submission_date[, ...]` clause using
`COUNT(*)`, because there is exactly one row in the dataset for each
`client_id` in the 28 day MAU window for each `submission_date`.

User counts generated using `last_seen_date` can use `SUM` to reduce groups,
because a given `client_id` will only be in one group per `submission_date`. So
if MAU were calculated by `country` and `channel`, then the sum of the MAU for
each `country` would be the same as if MAU were calculated only by `channel`.

#### Accessing the Data

The data is available in Re:dash and BigQuery.
Take a look at this
[full running example query in Re:dash](https://sql.telemetry.mozilla.org/queries/62029/source#159510).
