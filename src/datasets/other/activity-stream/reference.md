# Activity Stream Datasets

This article describes the various BigQuery tables Mozilla uses to store Activity Stream data, along with some examples of how to access them.

## Table of Contents

<!-- toc -->

## What is Activity Stream?

Activity Stream is the Firefox module which manages the in product content pages for Firefox:

- `about:home`
- `about:newtab`
- `about:welcome`
  - [starting with Firefox 62](https://bugzilla.mozilla.org/show_bug.cgi?id=1448918)
- `Snippets`
- `CFR`
- `Onboarding`
- `What's new panel`
- `Moments pages`

The Activity Stream team has implemented data collection in and around these pages. This data has some overlap with the standard Firefox Telemetry system, however it is a custom system, designed and maintained by that team.

For specific questions about this data, reach out to the `#fx-messaging-system` Slack channel directly.

## Activity Stream Pings

This data is measured in various custom pings that are sent via [PingCentre](https://searchfox.org/mozilla-central/source/browser/modules/PingCentre.jsm) (different from [Pingsender](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/internals/pingsender.html)).

- [Activity Stream Pings: `data_events.md`](https://firefox-source-docs.mozilla.org/browser/components/newtab/docs/v2-system-addon/data_events.html)
- [Activity Stream Pings: `data_dictionary.md`](https://firefox-source-docs.mozilla.org/browser/components/newtab/docs/v2-system-addon/data_dictionary.html)

## Accessing Activity Stream Data

Activity Stream pings are stored in BigQuery (like other Firefox Telemetry). There are two datasets: `activity_stream` and `messaging_system`.

#### `activity_stream`

The `activity_stream` dataset contains the following tables:

- `events` stores user interactions with the `about:home` and `about:newtab` pages
- `sessions` stores sessions of `about:home` and `about:newtab` pages
- `impression_stats` stores impression/click/block events for the Pocket recommendations on the `about:home` and `about:newtab` pages
- `spoc_fills` stores "Pocket Sponsored" recommendation related pings

#### `messaging_system`

The `messaging_system` dataset contains the following tables:

- `cfr` stores metrics on user interactions with the CFR (Contextual Feature Recommendation) system
- `moments` stores "Moments Pages" related pings
- `onboarding` stores metrics on user interactions with onboarding features
- `snippets` stores impression/click/dismissal metrics for Firefox Snippets
- `whats_new_panel` stores "What's New Panel" related pings
- `undesired_events` stores system health related events

## Gotchas and Caveats

Since this data collection isn't collected or maintained through our standard Telemetry API, there are a number of "gotchas" to keep in mind when working on this data:

- **Ping send conditions**: Activity Stream pings have different send conditions, both from Telemetry pings as well as from each other. For example, [AS Session Pings](https://firefox-source-docs.mozilla.org/browser/components/newtab/docs/v2-system-addon/data_events.html#session-end-pings) get sent by profiles that entered an Activity Stream session, at the end of that session, regardless of how long that session is. Compare this to `main` pings, which get sent by all Telemetry enabled profiles upon subsession end (browser shutdown, environment change, or local midnight cutoff).

  Due to these inconsistencies, using data from different sources can be tricky. For example, if we wanted to know how much of DAU (from `main` pings) had a custom `about:home` page (available in AS Health Pings), joining on `client_id` and a date field would only provide information on profiles that started the session on that same day (active profiles on multi-day sessions would be excluded).

- **Population covered**: In addition to the usual considerations when looking at a measurement (in what version of Firefox did this measurement start getting collected? In what channels is it enabled in? etc.), when working with this data, there are additional Activity Stream specific conditions to consider when deciding "who is eligible to send this ping?"

  For example, Pocket recommendations are only enabled in the US, CA, UK, and DE countries, for profiles that are on en-US, en-CA, en-GB, and de locales. Furthermore, users can set their `about:home` and `about:newtab` page to non-Activity Stream pages. This information can be important when deciding denominators for certain metrics.

- **Different ping types in the same table**: The tables in the `activity_stream` namespace can contain multiple types of pings. For example, the `events` table contains both [AS Page Takeover pings](https://firefox-source-docs.mozilla.org/browser/components/newtab/docs/v2-system-addon/data_events.html#page-takeover-ping) as well as [AS User Event pings](https://firefox-source-docs.mozilla.org/browser/components/newtab/docs/v2-system-addon/data_events.html#user-event-pings).

- **Null handling**: Some fields in the Activity Stream data encode nulls with a `'N/A'` string or a `-1` value.

- **Changes in ping behaviors**: These pings continue to undergo development and the behavior as well as possible values for a given ping seem to change over time. For example, older versions of the event pings for clicking on a Topsite do not seem to report `card_types` and `icon_types`, while newer versions do. Caution is advised.

- **Pocket data**: Data related to Pocket interaction and usage in the `about:home` and `about:newtab` pages get sent to Pocket via this data collection and pipeline. However, due to privacy reasons, the `client_id` is omitted in the ping whenever the Pocket recommendation identifiers are included, instead it reports with another user unique identifier `impression_id`. Though all the Pocket user interactions, such as clicks, dismisses, and save to pocket are still reported as the regular events with the `client_id` as long as they don't contain the Pocket recommendation identifiers.

## Examples

### Sessions per `client_id`

Note: only includes `client_ids` that completed an Activity Stream session that day.

```sql
SELECT
    client_id,
    DATE(submission_timestamp) AS date,
    count(DISTINCT session_id) as num_sessions
FROM
    `moz-fx-data-shared-prod.activity_stream.sessions`
WHERE
    DATE(submission_timestamp) = '20200601'
GROUP BY
    1
```

### Topsite clicks and Highlights clicks

```sql
SELECT
    client_id,
    DATE(submission_timestamp) AS date,
    session_id,
    page,
    source,
    action_position,
    experiments
FROM
    `moz-fx-data-shared-prod.activity_stream.events`
WHERE
    source in ('TOP_SITES', 'HIGHLIGHTS')
    AND event = 'CLICK'
    DATE(submission_timestamp) = '20200601'
```

### Snippet impressions, blocks, clicks, and dismissals

Note: Which snippet message a record corresponds to can be identified by the `message_id` (check with Marketing for snippet recipes published).

```sql
SELECT
    client_id,
    DATE(submission_timestamp) AS date,
    event,
    message_id,
    event_context,
    experiments
FROM
    `moz-fx-data-shared-prod.messaging_system.snippets`
WHERE
    DATE(submission_timestamp) = '20200601'
```
