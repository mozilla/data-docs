# SERP Events

## Table of Contents

<!-- toc -->

## Introduction

The `serp_events` table, derived from Glean `serp` events, provides a source
for understanding user interactions with search engine result pages (SERPs).
It is structured around SERP page loads and engagements
with different UI components on the SERP.
This data is Desktop-only.

## SERP impression model

A **SERP impression** consists of a SERP page load,
together with any user engagements with the links and UI features displayed on the page.
It starts from when the SERP is loaded.
Soon after the page loads, the browser runs a scan to detect sponsored search results (i.e. ads).
The user may engage with the page by clicking on a link or UI element.
The SERP impression ends when the user navigates away or closes the page.

The following diagram outlines the flow through a SERP impression,
along with the Glean events which are sent at different points.

```mermaid
flowchart LR
A[User loads SERP] --> AA([<code>serp.impression</code>])
AA --> B{Ads loaded?}
B -->|Yes| C([<code>serp.ad_impression</code>])
C -->|Each component| C
B -->|No| D{User engages?}
C --> D
D -->|No| E([<code>serp.abandonment</code>])
D -->|Yes| F([<code>serp.engagement</code>])
F -->|User engages again?| F
F --> G[User leaves SERP]
E --> G
AA -.-> H{{User engages\nbefore ad\ncategorization\ncomplete}}
H -.-> E
classDef edgecase fill:lightgrey,stroke:grey,font-size:10pt
class H edgecase
linkStyle 11,12 stroke-width:1px
```

A SERP impression is considered **engaged** if the user clicks at least once
on a search result link or UI component (out of the ones we track).
If the user leaves the SERP without engaging, the impression is considered **abandoned**.

### Ad detection and visibility

Depending on the search provider, ads may displayed across different
[display components](https://docs.google.com/document/d/1OxixC4r7hytWtwsHY0tDkq3rlY9vocmf5o0ija07A9o/edit#bookmark=id.nzlxxwj74kro)
(areas of the SERP with specific UI treatments), such as inline sponsored results,
a carousel showing result tiles streaming horizontally across the top,
a sidebar with result tiles laid out in a grid.
The ad detection procedure scans each of these components to check whether ad links are present.

Ad detection checks for ad links that are **loaded**, i.e. present in the DOM.
Loaded ad links may or may not be visible to the user.

- Ad links are considered **visible** if the user has an opportunity to see them,
  i.e. display properties of the DOM element containing the ad link make them visible,
  and they are in the area of the page showing on the user's screen.
- They are considered **blocked** if the display properties of the DOM element
  containing the ad link appear to have been altered by an ad blocker so as to make it invisible.
- Ad links that are neither visible nor explicitly blocked are considered **not showing**.
  These may be hidden by the SERP or outside of the area of the page the user has seen,
  e.g. "below the fold", or additional results in the carousel the user needs to scroll to.

Usually, if an ad blocker is in use, all loaded ads will be blocked.
In such cases, we infer an **ad blocker to be in use**.

## Measurement

Measurement for SERP impressions is collected through Glean `serp` category events.
All events include the `impression_id` field in their event extras,
which is used to link together events associated with the same SERP impression.
SERP events are only implemented for specific search engines.

When a user loads a SERP, a
[`serp.impression`](https://dictionary.telemetry.mozilla.org/apps/firefox_desktop/metrics/serp_impression)
event is recorded with a newly-generated `impression_id`,
containing some top-level information about the impression and the search that led to it.
Here, a "SERP impression" means a single page load,
not a sequence of pages associated with the same search term
(which might be called a "search session").
If the user loads Page 2 of the search results, or opens the Shopping results page,
that is considered a separate SERP impression and generates a new `impression_id`.

When ad detection runs, a
[`serp.ad_impression`](https://dictionary.telemetry.mozilla.org/apps/firefox_desktop/metrics/serp_ad_impression)
event is generated for each display component containing at least 1 loaded element.
It records counts of:

- loaded elements: `ads_loaded`
- elements which are visible to the user: `ads_visible`
- elements which appear to have been blocked: `ads_hidden`.

These counts have the following properties:

- `ads_loaded > 0`
- `0 <= ads_visible + ads_hidden <= ads_loaded`
- Usually `ads_hidden = 0` or `= ads_loaded`.

Despite the naming prefixed by `ads_`,
`ad_impression` events are also reported
for certain other page components which do not contain ad links and are not monetizable,
such as the shopping tab and Google's refined search buttons.
For these, `ads_loaded` tracks whether the feature was on the page, and is either 0 or 1.
For components containing ads, the counts refer to ad links.

A separate
[`serp.engagement`](https://dictionary.telemetry.mozilla.org/apps/firefox_desktop/metrics/serp_engagement)
event is recorded each time the user clicks on one of the instrumented UI components.
These include the ad components, organic links on the page,
as well as certain other non-ad page components.
Along with clicks on links, some components report additional engagement types,
such as the Expand (right arrow) button for the carousel,
or submitting a new search from the search box.

The following table summarizes impressions and engagements instrumented for the main components.
Others components or engagement actions may be instrumented in the future;
for the most up-to-date list, refer to the
[`serp.ad_impression`](https://dictionary.telemetry.mozilla.org/apps/firefox_desktop/metrics/serp_ad_impression)
and
[`serp.engagement`](https://dictionary.telemetry.mozilla.org/apps/firefox_desktop/metrics/serp_engagement)
event documentation.

<div class="table-wrapper">
<table>
  <thead>
    <tr>
      <th></th>
      <th>Component</th>
      <th>Impression reported</th>
      <th>Possible engagement actions</th>
      <th>Search engines supported</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th rowspan="5">Ad components</th>
      <td><code>ad_carousel</code></td>
      <td><code>serp.ad_impression</code></td>
      <td><code>clicked</code>, <code>expanded</code></td>
      <td>all</td>
    </tr>
    <tr>
      <td><code>ad_image_row</code></td>
      <td><code>serp.ad_impression</code></td>
      <td><code>clicked</code></td>
      <td>all</td>
    </tr>
    <tr>
      <td><code>ad_link</code></td>
      <td><code>serp.ad_impression</code></td>
      <td><code>clicked</code></td>
      <td>all</td>
    </tr>
    <tr>
      <td><code>ad_sidebar</code></td>
      <td><code>serp.ad_impression</code></td>
      <td><code>clicked</code></td>
      <td>all except Ecosia</td>
    </tr>
    <tr>
      <td><code>ad_sitelink</code></td>
      <td><code>serp.ad_impression</code></td>
      <td><code>clicked</code></td>
      <td>all</td>
    </tr>
    <tr>
      <th rowspan="5">Other page components</th>
      <td><code>refined_search_buttons</code></td>
      <td><code>serp.ad_impression</code></td>
      <td><code>clicked</code>, <code>expanded</code></td>
      <td>Google only</td>
    </tr>
    <tr>
      <td><code>shopping_tab</code></td>
      <td><code>serp.ad_impression</code></td>
      <td><code>clicked</code></td>
      <td>all</td>
    </tr>
    <tr>
      <td><code>cookie_banner</code></td>
      <td><code>serp.ad_impression</code></td>
      <td><code>clicked_accept</code>, <code>clicked_reject</code>, <code>clicked_more_options</code></td>
      <td>all</td>
    </tr>
    <tr>
      <td><code>incontent_searchbox</code></td>
      <td>None (impression assumed)</td>
      <td><code>clicked</code>, <code>submitted</code></td>
      <td>all</td>
    </tr>
    <tr>
      <td><code>non_ads_link</code></td>
      <td>None (impression assumed)</td>
      <td><code>clicked</code></td>
      <td>all</td>
    </tr>
  </tbody>
</table>
</div>

If the user leaves the page without making an engagement,
a
[`serp.abandonment`](https://dictionary.telemetry.mozilla.org/apps/firefox_desktop/metrics/serp_abandonment)
event is generated, indicating the `reason` for abandonment:
navigating to a different page, or closing the tab or window.

One subtlety here is that there is no explicit signal for when an engaged SERP impression ends.
The user may leave the SERP open a long time and keep clicking on different links or components.
To count engagements, we need to aggregate all `engagement` events for that `impression_id`,
and these may come in over some undefined period of time.
We handle this by imposing a 2-day maximum SERP impression length at ETL time,
as described [below](#assumptions-on-event-sequences).

### Limitations of ad impression detection

As the ad detection procedure runs at most once for a SERP impression
against a snapshot of the page,
ad impression and click reporting will be subject to some small systematic bias.
This is important to be aware of, although no explicit correction is used at present.

As a user continues to interact with the SERP,
it is possible for additional ads to become visible and for the user to engage with those.
For example, if the user keeps scrolling further down the page,
they may begin to see ads which were considered "not showing" by ad detection.
Engagements with these ads will be recorded, but the impressions may not,
meaning that the number of visible ad links may be undercounted.

There is also an edge case in which the user may click on a result
before ad detection has time to complete;
such impressions are reported as abandoned, and ad impressions and clicks are ignored.

However, the Legacy Telemetry ad click measurement will count all of these cases as ad clicks,
since it checks links for ads at click time rather than taking a snapshot.
This means that the `serp` events will undercount ad clicks somewhat relative to Legacy Telemetry.

The different cases are described in the following table:

| Engagement target                                                                                                                                               | Click reporting                             | Link impression reporting                                                                        |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| Non-ad component                                                                                                                                                | `serp.engagement` for target                | No explicit reporting, impression assumed                                                        |
| Ad detected as visible                                                                                                                                          | `serp.engagement` for ad component          | Included in `ads_visible` count of `serp.ad_impression` for component                            |
| Ad detected but not visible<p>E.g. user scrolls to reveal an ad that was on the page but not in the visible area when ad detection was run                      | `serp.engagement` for ad component          | Included in `ads_loaded` count but not `ads_visible` count of `serp.ad_impression` for component |
| Ad not previously detected<p>E.g. user scrolls down and more results are loaded automatically. Includes ads that were not on the page when ad detection was run | `serp.engagement` for `non_ad_link`         | Not included in `serp.ad_impression`                                                             |
| Engagement before ad detection completed                                                                                                                        | None. A `serp.abandonment` is sent instead. | None                                                                                             |

## Ad impressions and clicks

One of the main applications of this data is to compute ad impressions and clicks per SERP impression.
As discussed above, a SERP impression may include several ad links across different display components,
as well as organic links, and see multiple engagements with any of these.
Depending on the use case, ad impressions and clicks may be viewed either per-component or per-SERP impression.

To count impressions and clicks, we can either count individual ads and clicks,
or the number of page loads with least one ad or click.
The latter is usually preferred, since the former could give CTR counts larger than 1
and is more susceptible to issues described [above](#limitations-of-ad-impression-detection).
The rate of individual ad impressions per component may be of interest as well.

A display component in a SERP impression is said to have:

- an **ad impression** if it had at least 1 visible ad
- a **click** if it had at least 1 visible ad and at least 1 click engagement.

This means that, for a given SERP impression and display component,
_ad impression_ and _click_ are both binary 0/1 variables.
**CTR** for ads is then defined as `clicks / ad impressions`, and will be between 0 and 1.
We can also compute CTR for components that don't have explicit impression reporting,
such as organic results, by assuming 1 impression per SERP.

Impressions, clicks, and CTR can be computed per SERP impression instead
by considering an impression or click to have occurred if at least 1 display component had one.

If a component has ads loaded, and they are all hidden,
an **ad blocker is inferred** to be in use on the component.
At the SERP level, ad ad blocker is inferred to be in use if is it inferred on at least 1 ad component.

## SERP events table

The
[`mozdata.firefox_desktop.serp_events`](https://github.com/mozilla/bigquery-etl/blob/main/sql_generators/serp_events_v2/templates/view.sql)
table has **1 row per SERP impression** (indexed by `impression_id`),
combining information from all 4 `serp` event types.
Rows for submission date `D` represent SERP impressions
whose `serp.impression` event has submission date `D`.

Alongside impression-level fields and summaries,
the table has 3 array-valued fields:

- `ad_components`, with 1 entry per [ad component](#measurement),
  listing counts of impressions and engagements
- `non_ad_impressions`, with 1 entry per non-ad page component,
  listing impression counts
- `non_ad_engagements`, with 1 entry per non-ad page component and engagement type,
  listing engagement counts.

These arrays only include components with at least one non-zero count.
For SERP impressions with no impressions or engagements,
the corresponding arrays will be empty.

SERP impressions with no engagements are considered abandoned and have a non-null `abandon_reason`.

### Ad component tagging

Tagging components as containing ads,
and computing related fields such as `ad_components` and `num_ad_clicks`,
is implemented at the
[view layer](https://github.com/mozilla/bigquery-etl/blob/main/sql_generators/serp_events_v2/templates/view.sql)
using the
[`is_ad_component` UDF](https://github.com/mozilla/bigquery-etl/blob/main/sql/mozfun/serp_events/is_ad_component/udf.sql).

The underlying
[derived table](https://github.com/mozilla/bigquery-etl/blob/main/sql_generators/serp_events_v2/templates/desktop_query.sql)
instead has 2 array-valued fields:

- `component_impressions`, with 1 entry per component reported in a `serp.ad_impression` event
- `engagements`, with 1 entry per component and engagement action reported in a `serp.engagement` event.

### Assumptions on event sequences

We expect to see the following events reported for a given `impression_id`:

- 1 `serp.impression` event
- Either 1 `serp.abandonment` event or else 1 or more `serp.engagement` events
- 0 or more `serp.ad_impression` events, with at most 1 per component

Impression IDs for events which don't meet these requirements
are excluded from the table (this only affects a handful of impressions).

As discussed above,
a user could potentially keep a SERP open in their browser for multiple days
and keep recording clicks over that time,
as impression IDs don't have an inherent expiration.
In filling the table,
we only allow events for an impression ID to span at most **2 consecutive submission dates**:
`serp` events with a submission date 2 or more days after
the first submission date observed for that impression ID are ignored[^1].
As a result, the `serp_events` table has a **2-day lag** in its data
rather than the 1-day lag present for most other datasets.

On day `D`, the ETL logic looks like the following:

1. Pull all `serp` events with submission dates `D-2` or `D-1`
2. Retain event sequences (sharing a common `impression_id`)
   meeting the above requirements whose `serp.impression` event has submission date `D-2`
3. Compute 1 row for each event sequence and insert into the table
   with submission date `D-2`.

### Gotchas

- The table fills at a 2-day lag: the most recent submission date in the table is 2 days ago, not yesterday.
- Use `num_ads_visible` or `ad_components.num_visible` to count ad impressions,
  and `num_ad_clicks` or `ad_components.num_clicks` to count ad clicks.
  The table does not explicitly require `num_visible > 0` when `num_clicks > 0`.
- `ad_component.blocker_inferred` applies individually to each ad component,
  and a single `impression_id` may have different values of `blocker_inferred` for different components.
  The impression-level field `ad_blocker_inferred` is `true` if
  any ad component has `blocker_inferred = true`.
- Ad blocker use can only be inferred when ads are loaded
  (which is a minority of all SERP impressions).
  If ads are not loaded, `ad_blocker_inferred` will report `false`,
  but really, there is not enough information to make a determination.
- The array-valued fields will contain empty arrays rather than `NULL`s
  when there are no corresponding entries.
  For example, if a SERP impression has neither impressions nor engagements for ad components,
  `ad_components` will be `[]`.

### Example queries

Number of engaged and abandoned SERP impressions:

```sql
SELECT
  IF(abandon_reason IS NOT NULL, 'engaged', 'abandoned') AS session_type,
  COUNT(*) AS num_serp
FROM
  `mozdata.firefox_desktop.serp_events`
GROUP BY
  1
```

Number of SERP impressions with ads loaded:

```sql
SELECT
  num_ads_loaded > 0 AS has_ads_loaded,
  COUNT(*) AS num_serp
FROM
  `mozdata.firefox_desktop.serp_events`
GROUP BY
  1
```

Number of SERP impression-level ad impressions and clicks

```sql
SELECT
  COUNT(*) as num_with_ad_impression,
  COUNTIF(num_ad_clicks > 0) as num_with_ad_click,
FROM
  `mozdata.firefox_desktop.serp_events`
WHERE
  num_ads_visible > 0
```

Proportion of loaded ads that are visible, by search engine & component:

```sql
SELECT
  search_engine,
  component,
  SAFE_DIVIDE(SUM(num_visible), SUM(num_loaded)) as prop_visible
FROM
  `mozdata.firefox_desktop.serp_events`, UNNEST(ad_components)
GROUP BY
  1,
  2
ORDER BY
  1,
  2
```

Number of SERP impressions with ads loaded and an ad blocker in use:

```sql
SELECT
  ad_blocker_inferred,
  COUNT(*) as num_serp
FROM
  `mozdata.firefox_desktop.serp_events`
WHERE
  num_ads_loaded > 0
GROUP BY
  1
```

Per-component ad impression and click-through rates, among sessions with ads showing:

```sql
SELECT
  component,
  SAFE_DIVIDE(SUM(num_visible), COUNT(DISTINCT impression_id)) AS ad_imp_rate,
  -- only count clicks when ads are visible
  SAFE_DIVIDE(
    COUNT(DISTINCT IF(num_clicks > 0, impression_id, NULL)),
    COUNT(DISTINCT impression_id)
  ) AS ad_ctr
FROM
  `mozdata.firefox_desktop.serp_events`, UNNEST(ad_components)
WHERE
  num_visible > 0
GROUP BY
  1
```

Abandonment reason distribution:

```sql
SELECT
  abandon_reason,
  COUNT(*) AS num_serp
FROM
  `mozdata.firefox_desktop.serp_events`
WHERE
  abandon_reason IS NOT NULL
GROUP BY
  1
```

Number of SERP impressions with a shopping tab visible:

```sql
SELECT
  EXISTS(
    SELECT * FROM UNNEST(non_ad_impressions) AS x
    WHERE x.component = 'shopping_tab' AND x.num_elements_loaded  > 0
  ) AS has_shopping_tab,
  COUNT(*) AS num_serp
FROM
  `mozdata.firefox_desktop.serp_events`
GROUP BY
  1
```

### Column descriptions

The `v2` table has 1 row per SERP impression, each representing a single page load of a SERP.
Most columns contain impression-level properties.
There are also 3 array-valued columns listing impressions and engagements by component.

| Column                                       | Description                                                                                                                                                                                                                                                  |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `impression_id`                              | UUID identifying SERP page loads. Use `COUNT(DISTINCT impression_id)` to count unique SERP impressions when `CROSS JOIN UNNEST`ing the array-valued columns.                                                                                                 |
| `ping_seq`                                   | `ping_info.seq` from the events ping. Use together with `event_timestamp` for event sequencing.                                                                                                                                                              |
| `event_timestamp`                            | Glean event timestamp for the `serp.impression` event corresponding to the SERP page load.                                                                                                                                                                   |
| `is_shopping_page`                           | `true` when the SERP is a shopping page, resulting from clicking on the "Shopping" tab; `false` otherwise.                                                                                                                                                   |
| `is_private`                                 | `true` when the SERP was loaded while in Private Browsing Mode; `false` otherwise.                                                                                                                                                                           |
| `is_signed_in`                               | `true` when the SERP was loaded while signed into a search provider account; `false` otherwise.                                                                                                                                                              |
| `search_engine`                              | `google`, `bing`, `duckduckgo`, `ecosia` (only these support SERP events currently).                                                                                                                                                                         |
| `sap_source`                                 | How the user arrived at the SERP [e.g. `urlbar`, `follow_on_from_refine_on_SERP`]. There are a number of cases where this will be `unknown`, e.g. clicking on a link that opens a new SERP, or clicking on a history result containing a SERP URL.           |
| `is_tagged`                                  | Whether the search is tagged (`true`) or organic (`false`).                                                                                                                                                                                                  |
| `abandon_reason`                             | Why the SERP is deemed abandoned: `tab_close`, `window_close`, `navigation`, or `null` if not abandoned.                                                                                                                                                     |
| `ad_components`                              | Array with 1 entry for each ad component which had either an impression or engagement, `[]` if none.                                                                                                                                                         |
| `ad_components.component`                    | SERP display component containing ad links [e.g. `ad_link`, `ad_carousel`].                                                                                                                                                                                  |
| `ad_components.num_loaded`                   | Number of ads loaded in the component. They may or may not be visible on the page, depending on ad blocking and the display properties of the component.                                                                                                     |
| `ad_components.num_visible`                  | Number of ads visible to the user in the component.                                                                                                                                                                                                          |
| `ad_components.num_blocked`                  | Number of ads blocked by an ad blocker in the component.                                                                                                                                                                                                     |
| `ad_components.num_notshowing`               | Number of ads in the component which are loaded but not visible, and not blocked by an ad blocker. For example, ads in the carousel that will be shown on clicking the "Expand" button.                                                                      |
| `ad_components.num_clicks`                   | Number of clicks on ad links in the component.                                                                                                                                                                                                               |
| `ad_components.num_other_engagements`        | Number of engagements in the component which are not ad clicks. E.g. clicking "Expand" for the carousel.                                                                                                                                                     |
| `ad_components.blocker_inferred`             | `true` if all loaded ads are blocked, in which case we infer an ad blocker is in use in the component; `false` otherwise. Note that the same SERP impression can have `blocker_inferred = true` for some ad components and `false` for others.               |
| `non_ad_engagements`                         | Array with 1 entry for each non-ad component (which had an engagement) and engagement action, `[]` if none.                                                                                                                                                  |
| `non_ad_engagements.component`               | SERP display component not containing ad links [e.g. `non_ads_link`, `shopping_tab`].                                                                                                                                                                        |
| `non_ad_engagements.action`                  | Engagement action taken in the component.                                                                                                                                                                                                                    |
| `non_ad_engagements.num_engagements`         | Number of engagements of that action type taken in the component.                                                                                                                                                                                            |
| `non_ad_impressions`                         | Array with 1 entry for each non-ad component which had an impression, `[]` if none.                                                                                                                                                                          |
| `non_ad_impressions.component`               | SERP display component not containing ad links [e.g. `shopping_tab`, `refined_search_buttons`].                                                                                                                                                              |
| `non_ad_impressions.num_elements_loaded`     | Number of instrumented elements loaded in the component. They may or may not be visible on the page, depending on ad blocking and the display properties of the component. For many non-ad components this will be either 0 or 1.                            |
| `non_ad_impressions.num_elements_visible`    | Number of instrumented elements visible to the user in the component.                                                                                                                                                                                        |
| `non_ad_impressions.num_elements_blocked`    | Number of instrumented elements blocked by an ad blocker in the component.                                                                                                                                                                                   |
| `non_ad_impressions.num_elements_notshowing` | Number of instrumented elements in the component which are loaded but not visible, and not blocked by an ad blocker.                                                                                                                                         |
| `num_ad_clicks`                              | Total number of clicks on links in ad components for the SERP page load.                                                                                                                                                                                     |
| `num_non_ad_link_clicks`                     | Total number of clicks on organic result links (`non_ads_link` target) for the SERP page load.                                                                                                                                                               |
| `num_other_engagements`                      | Total number of engagements for the SERP page load which are neither ad clicks nor organic link clicks. These include `expanded` actions on the `ad_carousel` component, as well as clicks or other engagement actions on non-ad components.                 |
| `num_ads_loaded`                             | Total number of ads loaded in ad components for the SERP page load. They may or may not be visible on the page, depending on ad blocking and the display properties of the page.                                                                             |
| `num_ads_visible`                            | Total number of ads visible to the user in ad components for the SERP page load.                                                                                                                                                                             |
| `num_ads_blocked`                            | Total number of ads blocked by an ad blocker in ad components for the SERP page load.                                                                                                                                                                        |
| `num_ads_notshowing`                         | Total number of ads which are loaded but not visible, and not blocked by an ad blocker, for the SERP page load. For example, ads in the carousel that will be shown on clicking "Expand" button. Use this to count "ads that are available but not visible". |
| `ad_blocker_inferred`                        | `true` if all loaded ads are blocked in at least one ad component, in which case we infer an ad blocker is in use on the SERP; `false` otherwise.                                                                                                            |

### Scheduling

This dataset is scheduled on Airflow and updated daily.

### Schema

The data is partitioned by `submission_date`.

### Code reference

The derived table is
[generated](https://github.com/mozilla/bigquery-etl/blob/main/sql_generators/serp_events_v2/__init__.py)
from a templated query defined under
[`bigquery_etl/sql_generators`](https://github.com/mozilla/bigquery-etl/blob/main/sql_generators/serp_events_v2/templates/desktop_query.sql)
and accessible via its
[view](https://github.com/mozilla/bigquery-etl/blob/main/sql_generators/serp_events_v2/templates/view.sql).

<!-- prettier-ignore -->
[^1]: This limit of 2 days was chosen as a trade-off between data completeness and lag time.
A previous analysis showed that, even if we allow events for an impression ID to span up to 7 days,
99.5% of impression IDs only have events spanning 1 or 2 consecutive days.
