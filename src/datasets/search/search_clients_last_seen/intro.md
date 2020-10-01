`search_clients_last_seen` is designed for individual search analysis for clients over the past year.
This can be useful when wondering about client search behavior over the past year.

**NOTE**: `search_clients_last_seen` is currently a 1% sample, and the first day with a full year of
search activity is 2020-01-01.

### Contents

`search_clients_last_seen` has just one row per-client, for any client
who was active over the past year. Here we define active as "sent a main
ping"; so if they are present that does not mean they searched.

**NOTE**: Always choose a single `submission_date` when querying `search_clients_last_seen`.

The key pieces of this dataset are byte arrays that contain
daily information about client activity over the past year.
We have these for a variety of activity types:

- `days_seen_bytes`: Days when we received a main ping from the client
- `days_searched_bytes`: Days that the client searched in any form
- `days_tagged_searched_bytes`: Days that the client performed a tagged search
- `days_searched_with_ads_bytes`: Days that the client performed a search that contained ads
- `days_clicked_ads_bytes`: Days that the client clicked an ad post-search
  See "Utilizing BYTE columns" for how to use these fields.

There are some convenience columns around these, that give the number of days
since the client was last active for that usage criteria:

- `days_since_seen`
- `days_since_searched`
- `days_since_tagged_searched`
- `days_since_searched_with_ads`
- `days_since_clicked_ad`
- `days_since_created_profile`

We also include a variety of dimension information (e.g. os,
country, channel, default_search) to aggregate on. The
[query itself](https://github.com/mozilla/bigquery-etl/blob/master/sql/moz-fx-data-shared-prod/search_derived/search_clients_last_seen_v1/query.sql#L37)
lays out all of the available dimensional fields.

There are, finally, a few fields with daily activity data.
These include `active_hours_sum`, `organic` for organic searches,
and `total_searches`. Please note that these are just for the current day,
and not over the entire year of history contained in the `days_*_bytes` columns.

#### Utilizing BYTE columns

These are stored as BigQuery `BYTE` type, so they can be a bit confusing
to use. We have a few convenience functions for using them. For these functions,
anytime we say "was active", we mean "within the usage criteria defined by that
column"; for example, it could be days that clients searched with ads.:

`udf.bits_to_days_seen` - The number of days the user was active.
`udf.bits_to_days_since_seen` - The number of days since the user was last active.
`udf.bits_to_days_since_first_seen` - The number of days since the user's _first_
active day. Note that this will be at most 365 days, since that is the beginning
of history for this dataset.
`udf.bits_to_active_n_weeks_ago` - Returns whether or not the user was active n weeks
ago for the given activity type.

#### Engine Searches

Warning: This column was designed specifically for use with the revenue data, and probably isn't good for other kinds of analysis.

For each search engine, we store an array that contains the number of searches that user
completed each month for the past 12 months. This is across calendar months, so the number of
days are not directly comparable.

We have the same data for tagged searches, search with ads, and ad clicks.

#### Background and Caveats

`search_clients_last_seen` does includes
(`client_id` `submission_date`) pairs
even if we did not receive a ping for that `submission_date`.
Any client who was active over the past year will be included.

#### Accessing the Data

Access the data at `search.search_clients_last_seen`.

<!--
#### Further Reading
-->

[search data documentation]: ../../search.md
