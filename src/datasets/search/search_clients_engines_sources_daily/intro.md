`search_clients_engines_sources_daily` is designed to enable client-level search analyses.
Querying this dataset can be slow;
consider using `search_aggregates` for coarse analyses.

## Contents

`search_clients_engines_sources_daily` has one row for each unique combination of:
(`client_id`, `submission_date`, `engine`, `source`).

In addition to the standard search count aggregations,
this dataset includes some descriptive data for each client.
For example, we include `country` and `channel` for each row of data.
In the event that a client sends multiple pings on a given `submission_date`
we choose an arbitrary value from the pings for that (`client_id`, `submission_date`),
unless otherwise noted.

There were originally five standard search count aggregation columns:
`sap`, `tagged-sap`, and `tagged-follow-on`, `organic` and `unknown`. Over time, more search count aggregation columns were added, including `ad_click` and `search_with_ads` in late 2018 [bug](https://bugzilla.mozilla.org/show_bug.cgi?id=1505411); and `ad_click_organic` and `search_with_ads_organic` in late 2021 [bug](https://bugzilla.mozilla.org/show_bug.cgi?id=1664849).

Note that, if there were no such searches in a row's segment
(i.e. the count would be 0),
the column value is `null`.
Each of these columns represent different types of searches.
For more details, see the [search data documentation]

## Background and Caveats

`search_clients_engines_sources_daily` does not include
(`client_id` `submission_date`) pairs
if we did not receive a ping for that `submission_date`.

We impute a `NULL` `engine` and `source` for pings with no search counts.
This ensures users who never search are included in this dataset.

This dataset is large.
If you're querying this dataset from STMO,
heavily limit the data you read using `submission_date` or `sample_id`.

The `has_adblocker_addon` field is True if the client had an active addon that blocks Mozilla's ability to monetize the searches via a search engine partnership. The logic for identifying ad-blocking addons is [here](https://github.com/mozilla/search-adhoc-analysis/blob/master/monetization-blocking-addons/Monetization%20blocking%20addons.ipynb) (private notebook).

<!--
#### Further Reading
-->

[search data documentation]: ../../search.md
