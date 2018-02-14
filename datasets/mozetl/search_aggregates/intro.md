`search_aggregates` is designed to power high level search dashboards.
It's quick and easy to query, but the data are coarse.
If you need fine-grained data, consider using `search_clients_daily`.

#### Contents

Each row of `search_aggregates` contains
the standard search count aggregations
and a unique combination of the following columns.
Unless otherwise noted, these columns are taken directly from main_summary.

* `submission_date`
* `engine` - e.g. `google`, `bing`, `yahoo`
* `source` - The UI component used to issue a search - e.g. `urlbar`, `abouthome`
* `country`
* `locale`
* `addon_version` - The installed version of the [followonsearch addon]
* `app_version`
* `distribution_id`
* `search_cohort`

There are three aggregation columns:
`sap`, `tagged-sap`, and `tagged-follow-on`.
Each of these columns represent different types of searches.
For more details, see the [search data documentation]

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
