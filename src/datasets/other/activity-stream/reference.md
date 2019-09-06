# What is Activity Stream? 

Activity Stream is the Firefox module which manages the in product content pages for Firefox: 
* `about:home`
* `about:newtab`
* `about:welcome`
	- [starting with Firefox 62](https://bugzilla.mozilla.org/show_bug.cgi?id=1448918)

The Activity Stream team has implemented data collection in and around these pages. This data has some overlap with the standard Firefox Telemetry system, however it is a custom system, designed and maintained by that team. 

For specific questions about this data, reach out to the `#fx-messaging-system` Slack channel directly. 

## Activity Stream Pings

This data is measured in various custom pings that are sent via [PingCentre](https://github.com/mozilla/ping-centre) (different from [Pingsender](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/internals/pingsender.html)). 

* [Activity Stream Pings: `data_events.md`](https://github.com/mozilla/activity-stream/blob/master/docs/v2-system-addon/data_events.md)
* [Activity Stream Pings: `data_dictionary.md`](https://github.com/mozilla/activity-stream/blob/master/docs/v2-system-addon/data_dictionary.md)
* [Activity Stream Pings: Firefox Source Tree Documentation](https://firefox-source-docs.mozilla.org/browser/components/newtab/docs/v2-system-addon/data_dictionary.html)

## Accessing Activity Stream Data

The various Activity Stream pings are stored in tables stored in the `Tiles` Redshift database, maintained by the Activity Stream team. 

This database can be accessed via [re:dash](https://sql.telemetry.mozilla.org/), or in Databricks via a [workaround provided by the Data Operations team](https://dbc-caf9527b-e073.cloud.databricks.com/#notebook/155100/command/155102), tracked in this [bug](https://bugzilla.mozilla.org/show_bug.cgi?id=1272388#c16). 



## Gotchas and Caveats

Since this data collection isn't collected or maintained through our standard Telemetry API, there are a number of "gotchas" to keep in mind when working on this data. 

* **Ping send conditions**: Activity Stream pings have different send conditions, both from Telemetry pings as well as from each other. [AS Health Pings](https://github.com/mozilla/activity-stream/blob/master/docs/v2-system-addon/data_events.md#health-ping), for example, get sent by all profiles with Telemetry enabled, upon startup of each Firefox session. In contrast, [AS Session Pings](https://github.com/mozilla/activity-stream/blob/master/docs/v2-system-addon/data_events.md#session-end-pings) only get sent by profiles that entered an Activity Stream session, at the end of that session, regardless of how long that session is. Compare this to `main` pings, which get sent by all Telemetry enabled profiles upon subsession end (browser shutdown, environment change, or local midnight cutoff). 

	Due to these inconsistencies, using data from different sources can be tricky. For example, if we wanted to know how much of DAU (from `main` pings) had a custom `about:home` page (available in AS Health Pings), joining on `client_id` and a date field would only provide information on profiles that started the session on that same day (active profiles on multi-day sessions would be excluded). 

* **Population covered**: In addition to the usual considerations when looking at a measurement (in what version of Firefox did this measurement start getting collected? In what channels is it enabled in? etc.), when working with this data, there are additional Activity Stream specific conditions to consider when deciding "who is eligible to send this ping?"

	For example, Pocket recommendations are only enabled in the US, CA, and DE countries, for profiles that are on en-US, en-CA, and DE locales. Furthermore, users can set their `about:home` and `about:newtab` page to non-Activity Stream pages. This information can be important when deciding denominators for certain metrics. 

* **Different ping types in the same table**: The tables in the `Tiles` database can contain multiple types of pings. For example, the `assa_events_daily` table contains both [AS Page Takeover pings](https://github.com/mozilla/activity-stream/blob/master/docs/v2-system-addon/data_events.md#page-takeover-ping) as well as [AS User Event pings](https://github.com/mozilla/activity-stream/blob/master/docs/v2-system-addon/data_events.md#user-event-pings). 

* **Inconsistent fields**: In some tables, the same field can have different meanings for different records. 

	For example, in the `assa_router_events_daily` table, the `impression_id` field corresponds to the standard Telemetry `client_id` field for [Snippets impressions](https://github.com/mozilla/activity-stream/blob/master/docs/v2-system-addon/data_events.md#snippets-impression), [CFR impressions for pre-release and shield experiments](https://github.com/mozilla/activity-stream/blob/master/docs/v2-system-addon/data_events.md#cfr-impression-for-all-the-prerelease-channels-and-shield-experiment), and [onboarding impressions](https://github.com/mozilla/activity-stream/blob/master/docs/v2-system-addon/data_events.md#onboarding-impression). However, for [CFR impressions for release](https://github.com/mozilla/activity-stream/blob/master/docs/v2-system-addon/data_events.md#cfr-impression-for-the-release-channel), this field is a separate, impression identifier. 

* **Passing Experiment Tags**: If a profile is enrolled in a Normandy experiment, the experiment slug for that profile is only passed to the Activity Stream data if it contains the string "activity-stream". 

	In other words, Activity Stream will not tag data as belonging to an experiment if it is missing "activity-stream" in the slug, even if it is indeed enrolled in an experiment. 

* **Data field formats**: The format for some of the data that is shared with standard Telemetry can differ. 

	For example, experiment slugs in standard Telemetry is formatted as an array of maps (one for each experiment the profile is enrolled in) 

	`[{'experiment1_name':'branch_name'}, {'experiment2_name':'branch_name'}]`

	However, in the Activity Stream telemetry, experiment slugs are reported in a string, using `;` as a separater between experiments and `:` as a separator between experiment name and branch name. 

	`'experiment1_name:branch_name;experiment2_name:branch_name'`

* **Null handling**: Some fields in the Activity Stream data encode nulls with a `'N/A'` string or a `-1` value. 

* **Changes in ping behaviors**: These pings continue to undergo development and the behavior as well as possible values for a given ping seem to change over time. For example, older versions of the event pings for clicking on a Topsite do not seem to report `card_types` and `icon_types`, while newer versions do. Caution is advised. 

* **Pocket data**: Data related to Pocket interaction and usage in the `about:home` and `about:newtab` pages get sent to Pocket via this data collection and pipeline. However, due to privacy reasons, that data is sanitized and `client_id` is randomized. So while it is possible to ask, "how many Topsites and Highlights did a given profile click on in a given day?", we cannot answer that question for Pocket tiles. 


## Examples

#### Sessions per `client_id`

Note: only includes `client_ids` that completed an Activity Stream session that day. 

```
SELECT
	client_id, 
	date, 
	count(DISTINCT session_id) as num_sessions
FROM
	assa_sessions_daily_by_client_id
WHERE
	date = '20190601' 
GROUP BY 
	1
```


#### Topsite clicks and Highlights clicks

```
SELECT
	client_id, 
	date, 
	session_id,
	page, 
	source, 
	action_position, 
	shield_id
FROM
	assa_events_daily
WHERE
	source in ('TOP_SITES', 'HIGHLIGHTS')
	AND event = 'CLICK'
	AND date = '20190601' 
```

#### Snippet impressions, blocks, clicks, and dismissals

Note: Which snippet message a record corresponds to can be identified by the `message_id` (check with Marketing for snippet recipes published). 

```
SELECT 
    impression_id AS client_id, 
    date, 
    source,
    event,
    message_id, 
    value,
    shield_id
FROM 
	assa_router_events_daily
WHERE 
	source = 'snippets_user_event'
  	AND date = '20190601'
```







