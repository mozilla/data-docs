# Newtab Interactions

## Introduction

The `telemetry.newtab_interactions` dataset is useful for analyzing data on the New Tab on Firefox Desktop.  It contains a single source for user interactions with the New Tab and allows analysis to be done at either a client or visit level.  This table contains data from the Glean ["newtab" ping](https://dictionary.telemetry.mozilla.org/apps/firefox_desktop/pings/newtab). 

## Content 

This dataset can contain more than one row for each  `submission_date`, `client_id` and `visit_id`.  Each unique tab opened is defined as a unique New Tab `visit_id`.  We recommend aggregating by `client_id`, `submission_date` and `visit_id`. 

The `client_id` is the Glean client identifier, there is also the `legacy_telemetry_client_id` which can be used to join this data to non-Glean data tables. 

## Background and Caveats

### Scheduling:  

"newtab" pings can be sent for one of two reasons. 
`component_init`: The newtab component init'd, and the newtab and homepage settings have been categorized. This is mostly to ensure we hear at least once from clients configured to not show a newtab UI.
`newtab_session_end`: The newtab visit ended. Could be by navigation, being closed, etc. 

This dataset does not have a long history. The newtab ping went live in Fall 2022 and therefore we do not have data prior to that launch.  Any historical analysis will not be possible until we collect more data. 

Currently, telemetry is not yet instrumented for organic topsites tiles. This work is in progress and will be added to the dataset soon.  For now, all total topsites metrics (impression, clicks) only include sponsored topsites data. 

Some of the preference settings enabling features like Pocket and Topsites can be set to `enabled` in regions where these features are not available. In these cases, it is best to filter by country to only include regions where these features are available. In Looker, there are pre-set country groups for Topsites Available and Pocket Available to make this easier. 

## Data Reference 

### Field Descriptions 

#### Environment Specific: 

`newtab_visit_id`:  the unique id for that New Tab visit
`client_id` - Glean client id 
`legacy_telemetry_client_id`: The client_id according to Telemetry. Might not always have a value due to being too early for it to have loaded
`newtab_visit_started_at`: the timestamp when the tab was opened
`newtab_visit_ended_at`: the timestamp when the tab was closed
`experiments`: field to tag any active experiments the user is in 
`pocket_is_signed_in`: boolean flag indicating if the user is signed into pocket
`pocket_enabled` - boolean flag indicating whether the user has pocket enabled in settings. This can be enabled even in countries where Pocket is not available, so it is useful to add a country filter when using this. 
`pocket_sponsored_stories_enabled`: boolean indicating whether the setting to show Sponsored Stories in the New Tab is enabled. This can be enabled even in countries where Pocket is not available, so it is useful to add a country filter when using this. 
`pocket_sponsored_stories_enabled`:  boolean flag indicating whether Pocket sponsored stories are enabled in settings. This can be enabled even in countries where Pocket is not available, so it is useful to add a country filter when using this.
`topsites_enabled`: boolean flag for whether the client has topsites enabled in settings. This can be enabled even if topsites are not available in that country.
`newtab_homepage_category`: the current setting of the homepage URL. Classified into categories using `SiteClassifier`.
`newtab_newtab_category`: the current setting of the new tab URL.  Classified into categories using `SiteClassifier`.
`newtab_open_source`: describes the situation when the tab was opened. One of “about:Welcome”, “about:Home” or “about:NewTab” to reflect whether the tab is the first for a new profile/new Firefox install, the first in a new window or a new tab in an existing session window.
`newtab_search_enabled`: boolean indicating whether the setting to enable search on New Tab is enabled 
`is_new_profile`: flag indicating if the profile is new, pulled from the `unified_metrics` table
`activity_segment`: flag indicating which activity segment the client falls into on this day, pulled from the `unified_metrics` table

#### Search Specific: 

`search_engine`: the search engine for this search
`search_access_point`: the access point where the search originated. For New Tab, this is always the New Tab search bar (handoff searches). 
`searches`: count of searches
`tagged_search_ad_clicks`: count of ad clicks that resulted from tagged New Tab searches
`tagged_search_ad_impressions`: count of search engine results pages with ads which resulted from New Tab searches. This does not count the number of ads seen, but the number of pages seen which displayed ads. 
`follow_on_search_ad_clicks`: count of ad clicks which resulted from a follow on search from a search that originated on the New Tab. 
`follow_on_search_ad_impressions`: search engine results pages with ads which resulted from follow on searches from searches which originated on the New Tab. This does not count the number of ads seen, but the number of pages seen which displayed ads. 

#### Pocket Specific: 

`pocket_impressions`: count of total impressions on Pocket tiles, including both organic and sponsored. Each tile displayed contributes to this count.
`sponsored_pocket_impressions`: the count of sponsored Pocket impressions
`organic_pocket_impressions`: the count of organic Pocket impressions
`pocket_clicks`: count of total Pocket clicks, including both organic and sponsored. 
`sponsored_pocket_clicks`: the count of sponsored Pocket clicks
`organic_pocket_clicks`: the count of organic pocket clicks
`pocket_saves`: count of times “save to pocket” was selected on all tiles
`sponsored_pocket_saves`: count of times “save to pocket” was selected on sponsored tiles
`organic_pocket_saves`: count of times “save to pocket” was selected on organic tiles
`pocket_topic_click`: count of clicks on “Popular Topics” 
`pocket_story_position`: the tile position 

#### Topsites Specific:

`topsites_impressions`: count of impressions on topsites tiles. Currently this is only instrumented for sponsored topsites and does not include non-sponsored topsites. 
`sponsored_topsite_impressions`: count of impressions on sponsored topsites tiles. Each tile displayed contributes to this count. 
`topsites_clicks`: count of clicks on topsites tiles. Currently this is only instrumented for sponsored topsites and does not include non-sponsored topsites. 
`sponsored_topsite_clicks`: count of clicks on sponsored topsites tiles

## Scheduling

This dataset is updated daily via the telemetry-airflow infrastructure. 

## Schema

The data is partitioned by `submission_date`. 

## Code Reference 

This dataset is generated by bigquery-etl. Refer to this repository for information on how to run or augment this dataset. 
