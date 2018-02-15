# Search Data

## Introduction

This article introduces the datasets we maintain for search analyses.
After reading this article,
you should understand the search datasets well enough to produce moderately complex analyses.

## Table of Contents

<!-- toc -->

# Permissions

Access to both `search_aggregates` and `search_clients_daily`
is heavily restricted in re:dash.
We also maintain a restricted group for search on Github and Bugzilla.
If you reach a 404 on Github or don't have access to a re:dash query or bug
this is likely your issue.
To get access permissions, file a bug using the [search permissions template]

Once you have proper permissions,
you'll have access to a new source in re:dash called `Presto Search`.
**You will not be able to access any of the search datasets
via the standard `Presto` datasource**, even with proper permissions.


# Terminology

## Direct vs Follow-on Search

Searches can be split into two major classes `direct` and `follow-on`.

Direct searches result from a direct interaction with a `search access point` (SAP).
These searches are often called SAP searches.
There are currently 6 SAPs:

* `urlbar`
* `searchbar`
* `newtab`
* `abouthome`
* `contextmenu`
* `system`

Users will often interact with the Search Engine Results Page (SERP)
to create "downstream" queries.
These queries are called `follow-on queries`.
For example, follow-on queries can be caused by:

* Revising a query (`restaurants` becomes `restaurants near me`)
* Clicking on the "next" button
* Accepting spelling suggestions

## Tagged vs Untagged Searches

Our partners (search engines) attribute queries to Mozilla using **partner codes**.
When a user issues a query through one of our SAPs,
we include our partner code in the URL of the resulting search.

**Tagged queries** are queries that **include one of our partner codes**.

**Untagged queries** are queries that **do not include one of our partner codes**.
If a query is untagged,
it's usually because we do not have a partner deal for that search engine and region.

If an SAP query is tagged, any follow-on query should also be tagged.

# Standard Search Aggregates

We report three types of searches in our search datasets:
`SAP`, `tagged-sap`, and `tagged-follow-on`.
These aggregates show up as columns in the
`search_aggregates` and `search_clients_daily` datasets.

The **`SAP` column counts all SAP (or direct) searches**.
`SAP` search counts are collected via `UI telemetry`.
`UI telemetry` refers to the probes integrated with the Firefox UI.
`UI telemetry`, and thus `SAP` search counts,
 are **very reliable, but do not count follow-on queries**.

In 2017-06 we deployed the [followonsearch addon],
which adds probes for `tagged-sap` and `tagged-follow-on` searches.
These columns **attempt to count all tagged searches**
by looking for Mozilla partner codes in the URL of requests to partner search engines.
These search counts are critical to understanding revenue
since they exclude untagged searches and include follow-on searches.
However, these search counts have **important caveats affecting their reliability**.
See [In Content Telemetry Issues](#in-content-telemetry-issues) for more information.

## Outlier Filtering

We remove search count observations representing more than
10,000 searches for a single search engine in a single ping.


# In Content Telemetry Issues

The [followonsearch addon] implements the probe
used to measure `tagged-sap` and `tagged-follow-on` searches.
This probe is critical to understanding our revenue.
It's the only tool that gives us a view of follow-on searches
and differentiates between tagged and untagged queries.
However, it comes with some notable caveats.

## Relies on whitelists

The [followonsearch addon] attempts to count all tagged searches
by looking for Mozilla partner codes in the URL of requests to partner search engines.
To do this, the addon relies on a whitelist of partner codes and URL formats.
The list of partner codes is incomplete and only covers a few top partners.
These codes also occasionally change so there will be gaps in the data.

Additionally, changes to search engine URL formats can cause problems with our data collection.
See 
[this query](https://sql.telemetry.mozilla.org/queries/47631/source#128887)
for a notable example.

## Addon uptake

This probe is shipped as an addon.
Versions 55 and greater have the addon installed by default
([Bug](https://bugzilla.mozilla.org/show_bug.cgi?id=1369028)).
The addon was deployed to older versions of Firefox via GoFaster,
but uptake is not 100%.

## Limited historical data

The addon was first deployed in 2017-06.
There is no `tagged-*` search data available before this.

[followonsearch addon]: https://github.com/mozilla/followonsearch
[search permissions template]: https://bugzilla.mozilla.org/enter_bug.cgi?assigned_to=rharter%40mozilla.com&bug_file_loc=http%3A%2F%2F&bug_ignored=0&bug_severity=normal&bug_status=NEW&cf_fx_iteration=---&cf_fx_points=---&comment=Please%20add%20the%20following%20user%20to%20the%20Search%20group%3A%0D%0A%0D%0AMozilla%20email%20address%3A%0D%0AGithub%20handle%3A&component=Datasets%3A%20Search&contenttypemethod=autodetect&contenttypeselection=text%2Fplain&defined_groups=1&flag_type-4=X&flag_type-607=X&flag_type-800=X&flag_type-803=X&flag_type-916=X&form_name=enter_bug&maketemplate=Remember%20values%20as%20bookmarkable%20template&op_sys=Linux&priority=--&product=Data%20Platform%20and%20Tools&rep_platform=x86_64&short_desc=Add%20user%20to%20search%20user%20groups&target_milestone=---&version=unspecified
