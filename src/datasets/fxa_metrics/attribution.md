# Attribution of Firefox Accounts

## Table of Contents
<!-- toc -->

## Introduction

Users can create or login to an account through an increasingly large number of relying services and entrypoints. This article describes how we attribute authentications to their point of origin, and documents some of the most frequently trafficked entrypoints (it would not be feasible to list them all, but we will try to update this document when there are substantial changes).

## Types of Attribution
We can attribute accounts to the **service** that they sign up for, as well as the **entrypoint** that they use to begin the authentication flow. Each service typically has many entrypoints; sync, for example, has web-based entrypoints and browser-based entrypoints (see below).

### Service Attribution
There is a variable called `service` that we use to (1) attribute users to the relying services of FxA that they have authenticated with and (2) attribute individual events to the services they are associated with. **Except in the case of sync**, `service` is a mapping from the oauth `client_id` of the relying service/product to a human readable string. Note that this mapping is currently maintained by hand, and is done after the events have been logged by the server. Currently, mapping to the human-readable `service` variable is only done for amplitude metrics, where it is treated as a user property. There is also a `service` variable in the `activity_events` and `flow_metadata` re:dash tables (FxA Activity Metrics data source), however it only contains the opaque oauth `client_id`, not the human-readable string. A table of some of the most common oauth `client_id`s along with their corresponding `service` mapping is shown below. This is not a complete list.

|`service`|oauth `client_id`|Description|
|---|---|---|
|`lockbox`|`e7ce535d93522896`|Lockwise App for Android|
|`lockbox`|`98adfa37698f255b`|Lockwise App for iOS|
|`fenix`|`a2270f727f45f648`|Sync implementation for Fenix|
|`fx-monitor`|`802d56ef2a9af9fa`|Firefox Monitor ([website](https://monitor.firefox.com))|
|`send`|`1f30e32975ae5112`|Firefox Send ([website](https://send.firefox.com/))|
|`send`|`20f7931c9054d833`|Firefox Send (android app)|
|`pocket-mobile`|`7377719276ad44ee`|Pocket Mobile App|
|`pocket-web`|`749818d3f2e7857f`|Pocket Website|
|`firefox-addons`|`3a1f53aabe17ba32`|`addons.mozilla.org`|
|`amo-web`|`a4907de5fa9d78fc`|`addons.mozilla.org` (still unsure how this differs from `firefox-addons`)|
|`screenshots`|`5e75409a5a3f096d`|Firefox Screenshots ([website](https://screenshots.firefox.com/), no longer supported)|
|`notes`|`a3dbd8c5a6fd93e2`|Firefox Notes (desktop extension)|
|`notes`|`7f368c6886429f19`|Firefox Notes (android app)|
|`fxa-content`|`ea3ca969f8c6bb0d`|Oauth ID used when a user is signing in with cached credentials (i.e. does not have to re-enter username/password) and when the user is logging into the FxA settings page.|
|`mozilla-email-preferences`|`c40f32fd2938f0b6`|Oauth ID used when a user is signing in to modify their marketing email preferences (e.g., to opt-out.)|

In amplitude, there is also a `fxa_services_used` user property which maintains an array of all the services a user has authenticated with.

Some amplitude charts segmenting by service can be found [here](https://analytics.amplitude.com/mozilla-corp/notebook/detelo9).

### Funnel Attribution (entrypoint and utm parameters)
We can also attribute users to where they began the authentication process, be it from a website or an application. Attribution is done through query parameters appended to links that point at `accounts.firefox.com` (which hosts the actual authentication process). These parameters are logged along with with any metrics events that the user generates during the authentication flow. The table below lists the query parameters that are currently in use, along with the values associated with some of the most common funnels. Note that only `entrypoint` is typically logged for flows beginning within the browser. Web-based entrypoints are listed first, followed by entrypoints that are found within the browser chrome itself.

See the [Metrics for Relying Parties](https://mozilla.github.io/ecosystem-platform/docs/relying-parties/metrics-for-relying-parties) documentation for more implementational detail on utm/entrypoint parameters.

|`entrypoint`|utm parameters|Description & Notes|
|---|---|---|
|`activity-stream-firstrun`|**`utm_source`** = `activity-stream`, **`utm_campaign`** = `firstrun`, **`utm_medium`** = `referral` or `email`|The [about:welcome](about:welcome) page that is shown to new profiles on browser `firstrun`. `utm_term` is sometimes used to track variations for experiments.|
|`firstrun` (not supported for current versions)|**`utm_source`** = `firstrun`|This is the old version of the `firstrun` page that was hosted on the web as part of mozilla.org ([example](https://www.mozilla.org/en-US/firefox/62.0/firstrun/)). Starting with Firefox version 62, it was replaced by an in-browser version (see row above). Although it is not used for newer versions, it is still hosted for the sake of e.g. profiles coming through the dark funnel on older versions.|
|`mozilla.org-whatsnewXX`|**`utm_source`** = `whatsnewXX`, **`utm_campaign`** = `fxa-embedded-form`, **`utm_content`** = `whatsnew`, **`utm_medium`** = `referral` or `email` |Where `XX` = the browser version, e.g. 67 ([example](https://www.mozilla.org/en-US/firefox/67.0.1/whatsnew/)). The "what's new" page that is shown to users after they upgrade browser versions. Important notes: **(1)** Users who are signed into a Firefox account have a different experience than those that are signed out. Signed-in users typically see a promotion of FxA-relying services, while signed-out users see a Call to Action to create an account. **(2)** The attribution parameters for this page were standardized starting on version 66. **Previous values for entrypoint** include `whatsnew` and `mozilla.org-wnp64` - these values should be used when doing historical analysis of versions prior to 66.|
|`new-install-page` (current), `firefox-new` (previously)|varies (can contain values passed through by referrals)|[example](https://www.mozilla.org/en-US/firefox/new/). The "install Firefox" page. This page doesn't always promote FxA and it will often only promote it to a certain % of traffic or to certain segments.|
|`fxa-discoverability-native`|NA|The in-browser toolbar icon. This was introduced with version 67.0|
|`menupanel`|NA|The in-browser account item in the "hamburger" menu on desktop (three-line menu in the upper right corner) as well as the sync/FxA menu item on android and iOS.|
|`preferences`|NA|The "sign into sync" button found in the sync section in desktop preferences.|
|`synced-tabs`|NA|The "sign into sync" button found in synced-tabs section under the library menu.|
|`sendtab`|NA|The "sign into sync" button found in the "send tab to device" menu accessible by right-clicking on a tab.|
|`lockbox-addon`|NA|The "sign into sync" button found within the the Lockwise desktop extension. This is likely to change once Lockwise becomes fully integrated into the browser.|

Example amplitude charts: [registrations by `entrypoint`](https://analytics.amplitude.com/mozilla-corp/chart/1ush8xd), [logins by `entrypoint`](https://analytics.amplitude.com/mozilla-corp/chart/y8t2k1z), [registrations by `utm_source`](https://analytics.amplitude.com/mozilla-corp/chart/jjbkusl).
