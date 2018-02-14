`search_clients_daily` is designed to enable client-level search analyses.
Querying this dataset can be slow;
Consider using `search_aggregates` for coarse analyses.

#### Contents

`search_clients_daily` has one row for each unique combination of:
(`client_id`, `submission_date`, `engine`, `source`).

In addition to the standard search count aggregations,
this dataset includes some descriptive data for each client.
For example, we include `country` and `channel` for each row of data.
In the event that a client sends multiple pings on a given `submission_date`
we choose an arbitrary value from the pings for that (`client_id`, `submission_date`),
unless otherwise noted.

There are three standard search count aggregation columns:
`sap`, `tagged-sap`, and `tagged-follow-on`.
Each of these columns represent different types of searches.
For more details, see the [search data documentation]

#### Background and Caveats

`search_clients_daily` does not include
(`client_id` `submission_date`) pairs
if we did not receive a ping for that `submission_date`
or if the ping contained no searches.
In other words,
This dataset **does not include `client_ids` that do not search**.

#### Accessing the Data

Access to `search_clients_daily` is heavily restricted.
You will not be able to access this table without additional permissions.
For more details see the [search data documentation].

<!--
#### Further Reading
-->


[search data documentation]: /datasets/search.md
