`search_aggregates` is designed to power high level search dashboards.
It's quick and easy to query, but the data are coarse.
In particular, this dataset allows you to segment
by a limited number of client characteristics which are relevant to search markets.
However, it is not possible to normalize by client count.
If you need fine-grained data, consider using `search_clients_daily`
which breaks down search counts by client

#### Contents

Each row of `search_aggregates` contains
the standard search count aggregations
for each unique combination of the following columns.
Unless otherwise noted, these columns are taken directly from `main_summary`.

* `submission_date` - `yyyymmdd`
* `engine` - e.g. `google`, `bing`, `yahoo`
* `source` - The UI component used to issue a search - e.g. `urlbar`, `abouthome`
* `country`
* `locale`
* `addon_version` - The installed version of the [`followonsearch` addon]
* `app_version`
* `distribution_id` - `NULL` means the standard Firefox build
* `search_cohort` - `NULL` except for small segments relating to search experimentation

There are three aggregation columns:
`sap`, `tagged-sap`, and `tagged-follow-on`.
Each of these columns represent different types of searches.
For more details, see the [search data documentation]
Note that, if there were no such searches in a row's segment
(i.e. the count would be 0),
the column value is `null`.

<!--
#### Background and Caveats
-->

#### Accessing the Data

Access to `search_aggregates` is heavily restricted.
You will not be able to access this table without additional permissions.
For more details see the [search data documentation].

<!--
#### Further Reading
-->


[followonsearch addon]: https://github.com/mozilla/followonsearch
[search data documentation]: /datasets/search.md
