# Choosing a Dataset - Mobile Edition

## Products Overview 

Before doing an analysis, it is important to know which products you want to include. Here is a quick overview of Mozilla's mobile products. 


| Product Name           | App Name           | OS      | Notes                            |
| ---------------------- | ------------------ | ------- | -------------------------------- |
| Firefox Android        | `Fennec`           | Android |                                  |
| Firefox iOS            | `Fennec`           | iOS     |                                  |
| Focus Android          | `Focus`            | Android | Privacy browser                  |
| Focus iOS              | `Focus`            | iOS     | Privacy browser                  |
| Klar                   | `Klar`             | Android | German Focus release             |
| Firefox for Fire TV    | `FirefoxForFireTV` | Android |                                  |
| Firefox for Echo Show  | `FirefoxConnect`   | Android |                                  |
| Firefox Lite           | `Zerda`            | Android | Formerly Rocket (See below)      |
| Fenix (Firefox Preview)| N/A                | Android | Uses Glean (see below)           |

Firefox Lite was formerly known as Rocket. It is only available in certain countries in Asia Pacific - for more information on Firefox Lite data please see the [telemetry documentation](https://github.com/mozilla-tw/FirefoxLite/blob/master/docs/telemetry.md). 

Focus is our privacy focused mobile browser which blocks trackers by default and does not store a browsing history. 

Klar is the release name for Focus in Germany. 

For more information on how telemetry is sent for iOS apps, see the [telemetry documentation](https://github.com/mozilla-mobile/telemetry-ios).  

Some telemetry is also sent by FirefoxReality and some non-Mozilla forks of our browsers.  It is best to filter on `metadata_app_name` to ensure you are looking at only the app you are trying to analyze data for. 


## Raw Pings 

Mobile data is structured differently than desktop. Instead of sending a main ping, mobile has two key types of pings - a core ping and an events ping. The core ping is sent once per session and contains a much smaller set of metrics than the main ping, due to network and data size constraints. All mobile apps send the core ping. For more information on the core ping, there is telemetry documentation [here](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/core-ping.html).  

Event pings are not sent for all products. Event pings are sent by Focus Android, Focus iOS, Klar, Firefox for FireTV, Firefox for Echo Show and Firefox Lite. Event pings are sent more often than core pings, at most once per 10 minute interval.  If the ping records 10,000 events it is sent immediately, unless it is within 10 minutes of the last event ping sent, in which case some data may be lost.  For more information on the event ping, there is telemetry documentation [here](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/event-ping.html).  

Fennec (Firefox Android) does not send event pings, but instead has a `saved_session` ping which has the same format as `main_summary` but is only available for pre-release users and select few release users who have opted in to telemetry collection.  Data from this must be treated with caution as it comes from a biased population and should not be used to make conclusions about Fennec users as a whole.  

For more information on the implementation of the event pings and to view event descriptions for [Focus](https://github.com/mozilla-mobile/focus-android/blob/master/docs/Telemetry.md), [Firefox for FireTV](https://github.com/mozilla-mobile/firefox-tv/blob/master/docs/telemetry.md) or [Firefox for Echo Show](https://github.com/mozilla-mobile/firefox-echo-show/blob/master/docs/telemetry.md) please see the linked documentation.


### Core Ping Derived Datasets

#### `telemetry_core_parquet`

For most analyses of mobile data, use the `telemetry_core_parquet` table. This table contains data for all the non-desktop Firefox applications which send core pings. 

Unlike main summary, you can query `telemetry_core_parquet directly`. Remember to filter on `app_name` and `os`, as Firefox iOS and Firefox Android have the same `app_name`. Best practice is to always filter on `app_name`, `os`, app version (found as `metadata_app_version`) and release channel (which can be found as under metadata as `metadata.normalized_channel`). 

There are versioned tables for `telemtry_core_parquet` but the table without a `_v#` suffix is the most up to date table and it is best to use this in your analysis. 

The metadata field contains a list of useful metrics. To access you can query `metadata.metric_name` for the `metric_name` of your choice.  Metrics included in metadata are: [`document_id`, `timestamp`, `date`, `geo_country`, `geo_city`, `app_build_id`, `normalized_channel`] as described [here](https://github.com/mozilla-services/mozilla-pipeline-schemas/blob/dev/schemas/telemetry/core/core.9.parquetmr.txt).  

The `seq` field indicates the order of the pings coming in. `seq` = 1 is the first ping we have received for that client id and can be used to proxy new users. 


#### Other Tables

Mobile has a `core_client_count` table which has a created date and unique client id for each new install. This does not fully replicate what `client_count_daily` does for Desktop but can be useful for some analyses. 

For other core ping derived tables see the documentation [here](https://wiki.mozilla.org/Mobile/Metrics/Redash).  These (with the exception of `mobile_clients`) are derived from the `saved_session` ping only available as an opt-in on Fennec release, so should be used with caution.


### Event Ping Derived Datasets 
 
There are multiple event tables for mobile data. The two main event tables are `telemetry_mobile_event_parquet` and `telemetry_focus_event_parquet`.  As the name suggests, the event pings from Focus (iOS, Android and Klar) get sent to `telemetry_focus_event_parquet` and the other apps send data to `telemetry_mobile_event_parquet`.  Both tables have the same format and columns. 


#### `telemetry_mobile_events_parquet`

This table contains event data for Firefox for Fire TV, Firefox for Echo Show and Firefox Lite. There is a metadata column containing a list of metrics including [].  

Like when querying `telemetry_core_parquet` there are multiple apps contained in each table, so it is best practice to filter on at lease`app_name` and `os`.  One thing to note is that there is no `app_version` field in these tables, so in order to filter or join on a specific version you must know the corresponding `metadata.app_build_id`(s) for that `app_version`.  This can be found by reaching out to the engineering team building the app. 

Some other applications also send event data to this table, including Lockbox and FirefoxReality.  For more information on the event data sent from these applications, see their documentation. 

 
#### `telemetry_focus_events_parquet`

This table contains event data for Focus Android, Focus iOS and Klar.

Like when querying `telemetry_core_parquet` there are multiple apps contained in each table, so it is best practice to filter on at lease`app_name` and `os`.  One thing to note is that there is no `app_version` field in these tables, so in order to filter or join on a specific version you must know the corresponding `app_build_id`(s) for that `app_version`.  This can be found by reaching out to the engineering team building the app. 

Some other applications send data to this table but it is preferred to use this only for analysis of event data from Focus and it's related apps. 

### Notes 

Each app has it's own set of release channels and each app implements them in it's own way.  Most have a `nightly`, `beta`, `release` and an `other` channel, used at various stages of development.  Users sign up to test pre-released versions of the app.  In Focus Android, the `beta` channel uses the same APK in the Google Play Store as the `release` channel, but beta users get access to this version earlier than the release population. Once the `release` version is published, Beta users will be on the same version of the app as Release users and will be indistinguishable (without a query going back and flagging them by `client_id`). Beta releases have their `normalized_channel` tagged `release` and the only way to filter to beta users is to check that they were on a higher version number before the official release date. 

There was an incident on Oct 25, 2018 where a chunk of `client_id`s on Firefox Android were reset to the same `client_id`.  For more information see the blameless post-mortem document [here](https://docs.google.com/document/d/1r1PDQnqhsrPkft0pB46v9uhXGxR_FzK4laKJLGttXdA) or [bug](https://bugzilla.mozilla.org/show_bug.cgi?id=1501329).  Because of this, some retention analyses spanning this time frame may be impacted.   

### Upcoming Changes

In future, Android apps will use Glean - the new mobile telemetry SDK. Plans are to integrate this new SDK starting with Project Fenix, then update the other existing apps to Glean starting the second half of 2019. Instead of `core` and `event` pings, Glean will send `baseline`, `metrics` and `events` pings. For more information on Glean visit their [GitHub page](https://github.com/mozilla-mobile/android-components/tree/master/components/service/glean/#contact) or #Glean on Slack.  




