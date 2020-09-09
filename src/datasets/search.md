# Search Data

## Introduction

This article introduces the datasets we maintain for search analyses:
`search_aggregates` and `search_clients_daily`. After reading this article,
you should understand the search datasets well enough to produce moderately
complex analyses.

## Table of Contents

<!-- toc -->

# Terminology

## Direct vs Follow-on Search

Searches can be split into three major classes: _sap_, _follow-on_, and _organic_.

SAP searches result from a direct interaction with a `search access point` (SAP),
which is part of the Firefox UI.
These searches are often called SAP searches.
There are currently 7 SAPs:

- `urlbar` - entering a search query in the Awesomebar
- `searchbar` - the main search bar; not present by default for new profiles on Firefox 57+
- `newtab` - the search bar on the `about:newtab` page
- `abouthome` - the search bar on the `about:home` page
- `contextmenu` - selecting text and clicking "Search" from the context menu
- `system` - starting Firefox from the command line with an option that immediately makes a search
- `webextension` - initiated from a web extension ([added](https://bugzilla.mozilla.org/show_bug.cgi?id=1492233) as of Firefox 63)
- `alias` - initiated from a search keyword (like @google) ([added](https://bugzilla.mozilla.org/show_bug.cgi?id=1499193) as of Firefox 64)

Users will often interact with the Search Engine Results Page (SERP)
to create "downstream" queries.
These queries are called `follow-on queries`.
These are sometimes also referred to as **in-content queries**
since they are initiated from the content of the page itself
and not from the Firefox UI.

For example, follow-on queries can be caused by:

- Revising a query (`restaurants` becomes `restaurants near me`)
- Clicking on the "next" button
- Accepting spelling suggestions

Finally, we track the number of _organic_ searches. These would be searches initiated directly
from a search engine provider, not through a search access point.

## Tagged vs Untagged Searches

Our partners (search engines) attribute queries to Mozilla using **partner codes**.
When a user issues a query through one of our SAPs,
we include our partner code in the URL of the resulting search.

**Tagged queries** are queries that **include one of our partner codes**.

**Untagged queries** are queries that **do not include one of our partner codes**.
If a query is untagged,
it's usually because we do not have a partner deal for that search engine and region
(or it is an organic search that did not start from an SAP).

If an SAP query is tagged, any follow-on query should also be tagged.

# Standard Search Aggregates

We report five types of searches in our search datasets:
`sap`, `tagged-sap`, `tagged-follow-on`, `organic`, and `unknown`.
These aggregates show up as columns in the
`search_aggregates` and `search_clients_daily` datasets.
Our search datasets are all derived from `main_summary`.
The aggregate columns are derived from the `SEARCH_COUNTS` histogram.

The **`sap` column counts all SAP (or direct) searches**.
`sap` search counts are collected via
[probes](https://firefox-source-docs.mozilla.org/browser/browser/BrowserUsageTelemetry.html#search-telemetry)
within the Firefox UI
These counts are **very reliable, but do not count follow-on queries**.

In 2017-06 we deployed the [`followonsearch` addon], which adds probes for `tagged-sap` and `tagged-follow-on` searches.
These columns **attempt to count all tagged searches**
by looking for Mozilla partner codes in the URL of requests to partner search engines.
These search counts are critical to understanding revenue
since they exclude untagged searches and include follow-on searches.
However, these search counts have **important caveats affecting their reliability**.
See [In Content Telemetry Issues](#in-content-telemetry-issues) for more information.

In 2018, we
[incorporated](https://bugzilla.mozilla.org/show_bug.cgi?id=1475571) this code
into the product (as of version 61) and also started tracking so-called
"organic" searches that weren't initiated through a search access point (sap).
This data has the same caveats as those for follow on searches, above.

We also started tracking "unknown" searches, which generally correspond
to clients submitting random/unknown search data to our servers as part
of their telemetry payload. This category can generally safely be ignored, unless its value
is extremely high (which indicates a bug in either Firefox or the aggregation code
which creates our datasets).

In `main_summary`, all of these searches are stored in `search_counts.count`,
**which makes it easy to over count searches**.
However, in general, please avoid using `main_summary` for search analyses --
it's slow and you will need to duplicate much of the work done to make
analyses of our search datasets tractable.

## Outlier Filtering

We remove search count observations representing more than
10,000 searches for a single search engine in a single ping.

# In Content Telemetry Issues

The search code module inside Firefox (formerly implemented
as an addon until version 60) implements the probe used to measure `tagged-sap` and
`tagged-follow-on` searches and also tracks organic searches. This probe is critical
to understanding our revenue. It's the only tool that gives us a view of follow-on searches
and differentiates between tagged and untagged queries.
However, it comes with some notable caveats.

## Relies on whitelists

Firefox's search module attempts to count all tagged searches
by looking for Mozilla partner codes in the URL of requests to partner search engines.
To do this, it relies on a whitelist of partner codes and URL formats.
The list of partner codes is incomplete and only covers a few top partners.
These codes also occasionally change so there will be gaps in the data.

Additionally, changes to search engine URL formats can cause problems with our data collection.
See
[this query](https://sql.telemetry.mozilla.org/queries/47631/source#128887)
for a notable example.

## Limited historical data

The [`followonsearch` addon] was first deployed in 2017-06.
There is no `tagged-*` search data available before this.

`default_private_search_engine` is only available starting 2019-11-19.

[`followonsearch` addon]: https://github.com/mozilla/followonsearch
[search permissions template]: https://bugzilla.mozilla.org/enter_bug.cgi?assigned_to=rharter%40mozilla.com&bug_file_loc=http%3A%2F%2F&bug_ignored=0&bug_severity=normal&bug_status=NEW&cf_fx_iteration=---&cf_fx_points=---&comment=Please%20add%20the%20following%20user%20to%20the%20Search%20group%3A%0D%0A%0D%0AMozilla%20email%20address%3A%0D%0AGithub%20handle%3A&component=Datasets%3A%20Search&contenttypemethod=autodetect&contenttypeselection=text%2Fplain&defined_groups=1&flag_type-4=X&flag_type-607=X&flag_type-800=X&flag_type-803=X&flag_type-916=X&form_name=enter_bug&maketemplate=Remember%20values%20as%20bookmarkable%20template&op_sys=Linux&priority=--&product=Data%20Platform%20and%20Tools&rep_platform=x86_64&short_desc=Add%20user%20to%20search%20user%20groups&target_milestone=---&version=unspecified
