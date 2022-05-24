# Search Data

## Introduction

This article introduces the datasets we maintain for search analyses:
`search_aggregates` and `search_clients_engines_sources_daily`. After reading this article,
you should understand the search datasets well enough to produce moderately
complex analyses.

Additionally, see the `Building Intuition` search dashboards for applications to search datasets. Listed in recommended order of consumption:

- [Search Monetization](https://mozilla.cloud.looker.com/dashboards-next/312), an overview of how search partnerships generate revenue
- [Search Mechanics](https://mozilla.cloud.looker.com/dashboards-next/314), an in-depth look at the search types described below + searches with ads and ad clicks, with special attention to search behavior in important subgroups of the population
- [Search Analyses](https://mozilla.cloud.looker.com/dashboards-next/319), a mapping of the search datasets to corresponding Looker Explores
- [Search Access Points](https://mozilla.cloud.looker.com/dashboards-next/256), an overview of search, ad impressions, and ad clicks across the different search access points (SAPs) built into the browser
- [Regional Search Providers](https://mozilla.cloud.looker.com/dashboards/542), an introduction to regional search providers `Baidu`, `Yandex`, `Qwant`, `Ecosia`, and `Yahoo Japan`.

## Table of Contents

<!-- toc -->

# Terminology

## Direct vs Follow-on Search

Searches can be split into three major classes: _sap_, _follow-on_, and _organic_.

SAP searches result from a direct interaction with a **search access point (SAP)**, locations on the Firefox UI where clients can enter search queries. Searches that originate from these SAPs are often called SAP searches. For the most recent list of search access points, see [Search telemetry doc](https://firefox-source-docs.mozilla.org/browser/search/telemetry.html#browsersearchtelemetry-jsm) as SAPs continue to be developed over time.

The Firefox browser has multiple SAPs available at the same time. For visuals noting the location of Firefox SAPs, see [here](https://mozilla.cloud.looker.com/dashboards-next/256). These SAPs are recorded in the `source` field in search tables, and include the following:

- `urlbar` - entering a search query in the Awesomebar. Searches typed into the search bar in the middle of the browser window will also be recorded as `urlbar` searches.
- `urlbar-searchmode` - selecting a search partner icon while entering a search query in the Awesomebar or tagging the search partner (i.e. `@duckduckgo`) before entering search query via Awesomebar (was formerly called `alias` [added](https://bugzilla.mozilla.org/show_bug.cgi?id=1499193) as of Firefox 64.)
- `urlbar-handoff` - often referred to as new tab search. Searches by typing into the search box in the middle of the browser window will be attributed to the `urlbar-handoff` starting in Firefox 94. See more in [probe dictionary](https://probes.telemetry.mozilla.org/?search=urlbar&view=detail&probeId=scalar%2Fbrowser.search.content.urlbar_handoff) and [bug here](https://bugzilla.mozilla.org/show_bug.cgi?id=1732429).
- `newtab` - referred to new tab search on `about:newtab` page.
- `abouthome` - referred to new tab search on `about:home` page.
- `searchbar` - the main search bar (on the top right corner of browser window); not present by default for new profiles on Firefox 57+. `Searchmode` searches via the `searchbar` are logged as regular `searchbar` searches.
- `contextmenu` - highlight text, right click, and select "Search [search engine] for [highlighted text]" from the context menu.
- `system` - starting Firefox from the command line with an option that immediately makes a search.
- `webextension` - initiated from a web extension ([added](https://bugzilla.mozilla.org/show_bug.cgi?id=1492233) as of Firefox 63).

Note: Search telemetry evolves so the actual `source` name used for a specific search access point may vary between different versions of Firefox. For example, to catch SAP searches performed in Awesomebar after Firefox 94, you will need to use `source in ("urlbar", "urlbar-searchmode", "urlbar-handoff")`.

Users will often interact with the Search Engine Results Page (SERP) to create "downstream" queries. These queries are called **follow-on queries** but may also be referred to as **in-content queries** since they are initiated from the content of the page itself and not from the Firefox UI.

For example, follow-on queries can be caused by:

- Revising a query (`restaurants` becomes `restaurants near me`)
- Clicking on the "next" button
- Accepting spelling suggestions

Finally, we track the number of _organic_ searches. These searches are not via SAPs and are instead entered directly via a search engine provider, typically by visiting the provider's website and entering a search query through their website's interface.

## Tagged vs Untagged Searches

Our partners (search engines) attribute queries to Mozilla using **partner codes**. When a user issues a query through one of our SAPs, we include our partner code in the URL of the resulting search.

**Tagged queries** are queries that **include one of our partner codes**. If a SAP query is tagged, any follow-on query should also be tagged.

**Untagged queries** are queries that **do not include one of our partner codes**. If a query is untagged, it's usually because we do not have a partner deal for that search engine and region (or it is an organic search that did not start from an SAP).

# Standard Search Aggregates

We report five types of searches in our search datasets: `sap`, `tagged-sap`, `tagged-follow-on`, `organic`, and `unknown`. These aggregates show up as columns in the `search_aggregates` and `search_clients_engines_sources_daily` datasets. Our search datasets are all derived from `main_summary`. The aggregate columns are derived from the `SEARCH_COUNTS` histogram.

The **`sap` column counts all SAP (or direct) searches**. `sap` search counts are collected via [probes](https://firefox-source-docs.mozilla.org/browser/browser/BrowserUsageTelemetry.html#search-telemetry) within the Firefox UI These counts are **very reliable, but do not count follow-on queries**.

In 2017-06 we deployed the [`followonsearch` addon], which adds probes for `tagged-sap` and `tagged-follow-on` searches. These columns **attempt to count all tagged searches** by looking for Mozilla partner codes in the URL of requests to partner search engines. These search counts are critical to understanding revenue since they exclude untagged searches and include follow-on searches. However, these search counts have **important caveats affecting their reliability**. See [In Content Telemetry Issues](#in-content-telemetry-issues) for more information.

In 2018, we [incorporated](https://bugzilla.mozilla.org/show_bug.cgi?id=1475571) this code into the product (as of version 61) and also started tracking so-called "organic" searches that weren't initiated through a search access point (sap). This data has the same caveats as those for follow on searches, above.

We also started tracking "unknown" searches, which generally correspond to clients submitting random/unknown search data to our servers as part of their telemetry payload. This category can generally safely be ignored, unless its value is extremely high (which indicates a bug in either Firefox or the aggregation code which creates our datasets).

In `main_summary`, all of these searches are stored in `search_counts.count`, **which makes it easy to over count searches**. However, in general, please avoid using `main_summary` for search analyses -- it's slow and you will need to duplicate much of the work done to make analyses of our search datasets tractable.

## Outlier Filtering

We remove search count observations representing more than 10,000 searches for a single search engine in a single ping.

# In Content Telemetry Issues

The search code module inside Firefox (formerly implemented as an addon until version 60) implements the probe used to measure `tagged-sap` and
`tagged-follow-on` searches and also tracks organic searches. This probe is critical to understanding our revenue. It's the only tool that gives us a view of follow-on searches and differentiates between tagged and untagged queries. However, it comes with some notable caveats.

## Relies on whitelists

Firefox's search module attempts to count all tagged searches by looking for Mozilla partner codes in the URL of requests to partner search engines. To do this, it relies on a whitelist of partner codes and URL formats. The list of partner codes is incomplete and only covers a few top partners. These codes also occasionally change so there will be gaps in the data.

Additionally, changes to search engine URL formats can cause problems with our data collection. See [this query](https://sql.telemetry.mozilla.org/queries/47631/source#128887) for a notable example.

## Limited historical data

The [`followonsearch` addon] was first deployed in 2017-06. There is no `tagged-*` search data available before this.

`default_private_search_engine` is only available starting 2019-11-19.

[`followonsearch` addon]: https://github.com/mozilla/followonsearch
[search permissions template]: https://bugzilla.mozilla.org/enter_bug.cgi?assigned_to=rharter%40mozilla.com&bug_file_loc=http%3A%2F%2F&bug_ignored=0&bug_severity=normal&bug_status=NEW&cf_fx_iteration=---&cf_fx_points=---&comment=Please%20add%20the%20following%20user%20to%20the%20Search%20group%3A%0D%0A%0D%0AMozilla%20email%20address%3A%0D%0AGithub%20handle%3A&component=Datasets%3A%20Search&contenttypemethod=autodetect&contenttypeselection=text%2Fplain&defined_groups=1&flag_type-4=X&flag_type-607=X&flag_type-800=X&flag_type-803=X&flag_type-916=X&form_name=enter_bug&maketemplate=Remember%20values%20as%20bookmarkable%20template&op_sys=Linux&priority=--&product=Data%20Platform%20and%20Tools&rep_platform=x86_64&short_desc=Add%20user%20to%20search%20user%20groups&target_milestone=---&version=unspecified

# Address Bar & Search Overviews

- Address Bar Overview by Marco Bonardo [[Presentation](https://mozilla.hosted.panopto.com/Panopto/Pages/Viewer.aspx?id=3cfa519d-d8cc-4b9d-a432-adff012b7bb9) / [Slides](https://docs.google.com/presentation/d/1Li7uBp8HJ2trTLkj8Qx_bt7nIGQyU-QyniTCo9VSesY/edit#slide=id.g82d2da351e_5_3617)] - an overview of Firefox's address bar (aka: the Awesomebar)
- Address Bar Results Ranking by Marco Bonardo [[Slides](https://docs.google.com/presentation/d/1r3Y70Qhpdp5Cd51hdIiX9W2AE9Tq-W8CXfumyFaNdW4/edit#slide=id.g82d2da351e_5_3617)] - deep-dive on how results are ranked and displayed in Firefox's address bar
- Search Engines Overview by Mark Banner [[Presentation](https://mozilla.hosted.panopto.com/Panopto/Pages/Viewer.aspx?id=c0dd7221-a31f-449c-a874-adfd012609de) / [Slides](https://docs.google.com/presentation/d/1ibE04t8dm1ZpxJVRpVDupPnG_UOEhgEWaePS2C5BHQY/edit#slide=id.g832b271044_1_1173)] - an overview on how search engines are included in Firefox
- Search Engine Configuration by Mark Banner [[Presentation](https://mozilla.hosted.panopto.com/Panopto/Pages/Viewer.aspx?id=774320a1-cd71-49a4-bf36-ae210156dcd5) / [Slides](https://docs.google.com/presentation/d/1Jg7ct3G7IU7iqunuByOyLvIXwV8nYCOqyIPENTOpW9Y/edit#slide=id.g832b271044_1_1173)] - deep-dive on how search engines are configured and deployed in Firefox
