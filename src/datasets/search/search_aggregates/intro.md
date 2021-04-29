`search_aggregates` is designed to power high level search dashboards.
It's quick and easy to query, but the data are coarse.
In particular, this dataset allows you to segment
by a limited number of client characteristics which are relevant to search markets.
However, it is not possible to normalize by client count.
If you need fine-grained data, consider using `search_clients_daily`
which breaks down search counts by client

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
For more details, see the [search data documentation]

<!--
#### Further Reading
-->

[followonsearch addon]: https://github.com/mozilla/followonsearch
[search data documentation]: ../../search.md
