
#### Contents

The `main_summary` table contains one row for each ping.
Each column represents one field from the main ping payload,
though only a subset of all main ping fields are included.
This dataset **does not include most histograms**.

#### Background and Caveats
This table is massive, and due to its size, it can be difficult to work with.

Instead, we recommend using the `clients_daily` or `clients_last_seen` dataset
where possible.

If you do need to query this table, make use of the `sample_id` field and
limit to a short submission date range.

#### Accessing the Data

The `main_summary` table is accessible through re:dash.
Here's an [example query](https://sql.telemetry.mozilla.org/queries/4201/source).