`search_aggregates` is designed to power high level search dashboards.
It's quick and easy to query, but the data are coarse.
In particular, this dataset allows you to segment
by a limited number of client characteristics which are relevant to search markets.
However, it is not possible to normalize by client count.
If you need fine-grained data, consider using `search_clients_engines_sources_daily`
which breaks down search counts by client, engine, and source.

## Contents

Each row of `search_aggregates` contains
the standard search count aggregations
for each unique combination of the following columns.
Unless otherwise noted, these columns are taken directly from `main_summary`.

- `submission_date` - `yyyymmdd`
- `engine` - e.g. `google`, `bing`, `yahoo`
- `source` - The UI component used to issue a search - e.g. `urlbar`, `abouthome`
- `country`
- `locale`
- `addon_version` - The installed version of the [`followonsearch` addon] (before version 61)
- `app_version`
- `distribution_id` - `NULL` means the standard Firefox build
- `search_cohort` - `NULL` except for small segments relating to search experimentation
- `default_search_engine`
- `default_private_search_engine`
- `os` - e.g. `Linux`, `Windows_NT`, `Darwin` ...
- `os_version`
- `is_default_browser`

There are ten aggregation columns:
`sap`, `tagged-sap`, `tagged-follow-on`,`organic`, `unknown`, `ad_click`, `ad_click_organic`, `search_with_ads`, `search_with_ads_organic`, and `client_count`.
Each of these columns represent different types of searches.
For more details, see the [search data documentation].

<!--
#### Further Reading
-->

[followonsearch addon]: https://github.com/mozilla/followonsearch
[search data documentation]: ../../search.md


## Gotcha
Although `search_aggregates` table is created on top of `search_clients_engines_sources_daily`, you may expect the total search metrics reported to match exactly. It's actually not the case. In case you notice the total number reported in `search_aggregates` higher than `search_clients_engines_sources_daily`, it's most likely due to [Shredder](https://mana.mozilla.org/wiki/display/DATA/Shredder). `search_aggregates` table is aggregated beyond the client level, so shredder doesn’t have to touch it. But `search_clients_engines_sources_daily` contains `client_id` and is subject to shredder. It's expected to lose up to 1% of rows every month as Firefox responds to clients' deletion requests, which would reduce count in `search_clients_engines_soruces` but not in `search_aggregates`. An example query to show such a difference can be found [here](https://sql.telemetry.mozilla.org/queries/84302/source). 
