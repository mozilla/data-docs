# Choosing a Mobile Product Dataset

## Products Overview

Before you perform an analysis, it is important to identify the products that you want to include. You can select any of the following Mozilla's mobile products:

| Product Name            | App Name            | OS      | Notes                       |
| ----------------------- | ------------------- | ------- | --------------------------- |
| Firefox Android         | `Fennec`            | Android |                             |
| Firefox iOS             | `Fennec`            | iOS     |                             |
| Focus Android           | `Focus`             | Android | Privacy browser             |
| Focus iOS               | `Focus`             | iOS     | Privacy browser             |
| Klar                    | `Klar`              | Android | German Focus release        |
| Firefox for Fire TV     | `FirefoxForFireTV`  | Android |                             |
| Firefox for Echo Show   | `FirefoxConnect`    | Android |                             |
| Firefox Lite            | `Zerda`             | Android | Formerly Rocket (See below) |
| Fenix (Firefox Preview) | `org_mozilla_fenix` | Android | Uses Glean (see below)      |

Firefox Lite was formerly known as Rocket. It is only available in certain countries in Asia Pacific. For more information on Firefox Lite data, see the [telemetry documentation][fxlite].

Focus is known as the privacy-focused mobile browser that blocks trackers by default. It does not store a browsing history.

Klar is the known release name for Focus in Germany.

For more information on how telemetry is sent for iOS apps, see the [telemetry documentation][ios].

Some telemetry is also sent by FirefoxReality and some non-Mozilla forks of our
browsers. It is recommended that you filter on App Name to make sure that you are looking at only the app for which you want to analyze data.

[fxlite]: https://github.com/mozilla-tw/FirefoxLite/blob/master/docs/telemetry.md
[ios]: https://github.com/mozilla-mobile/telemetry-ios

## Raw Pings

Mobile data is structured differently when compared to desktop data. Instead of sending a `main` ping, mobile has provides the following key types of pings:

- `core`
- `events`

The core ping is sent once for each session. It includes a much smaller set of
metrics than the main ping because of network and data size constraints. All mobile apps send the core ping. For more information on the core ping, see the telemetry documentation [here][core_ping].

Event pings are not sent for all products. They are sent by Focus Android, Focus iOS, Klar, Firefox for FireTV, Firefox for Echo Show, and Firefox Lite.
Event pings are sent more frequently than core pings, at most once per 10 minute interval.
If a ping records 10,000 events, it is sent immediately unless it is within 10 minutes of the last event ping sent: in this case some data may be lost. For more information about the event ping, see the [telemetry documentation][event_ping].

Fennec (Firefox Android) does not send event pings. Instead, it includes a
`saved_session` ping with the same format as `main` pings. However, it is only
available for users who have installed a pre-release and a few users who have installed a release. In both cases, they must have opted into signing up for telemetry collection.
Data from this collection must be treated with caution because it is based on a biased
population and therefore should not be used to make conclusions about Fennec users.

For more information on the implementation of the event pings and to view event
descriptions for [Focus], [Firefox for FireTV], or [Firefox for Echo Show], see the following documentation:

[core_ping]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/core-ping.html
[event_ping]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/event-ping.html
[focus]: https://github.com/mozilla-mobile/focus-android/blob/master/docs/Telemetry.md
[firefox for firetv]: https://github.com/mozilla-mobile/firefox-tv/blob/master/docs/telemetry.md
[firefox for echo show]: https://github.com/mozilla-mobile/firefox-echo-show/blob/master/docs/telemetry.md

### Core Ping Derived Datasets

#### `telemetry.core`

For most analyses of mobile data, you need to use the `telemetry.core` table. It includes data for all the non-desktop Firefox applications that send core pings.

You need to filter on `app_name` and `os` because Firefox iOS and Firefox Android
have the same `app_name`. It is recommended that you always filter on `app_name`, `os`, app version (found as `metadata_app_version`) and release channel (it is located under metadata as `metadata.normalized_channel`).

Versioned tables are available for core ping storage for historical reference, but a table without a version suffix always represents an up-to-date table. It is recommended that you use the unversioned table, so you can be sure your analysis is based on up-to-date information.

The `seq` field indicates the order in which pings are sent. A record includes `seq = 1`, which represents the first ping that is received for a client id. It can be used as a proxy to identify new users.

### Event Ping Derived Datasets

There are two tables for mobile event data: `telemetry.focus_event` and `telemetry.mobile_event`.

As the name suggests, one table includes the event pings from Focus (iOS, Android
and Klar). The other table includes the event data for other apps. Both tables use the same format and columns.

#### `telemetry.mobile_events`

The `telemetry.mobile_events` table includes event data for Firefox for Fire TV, Firefox for Echo Show, and Firefox Lite. A metadata column with a list of metrics is also included.

Like when querying `telemetry.core`, multiple applications are included in each table. It is recommended that you filter at least `app_name` and `os`. Be sure that no `app_version` field is included in these tables: if you want to filter or join a specific version, you must have already identified the corresponding `metadata.app_build_id`(s) for the `app_version` by contacting the engineering team that has created the app.

A few other applications also send event data to this table, including Lockbox and FirefoxReality. For more information about the event data that is sent from these applications, see their documentation.

#### `telemetry.focus_events`

The `telemetry.focus_events` table includes event data for Focus Android, Focus iOS, and Klar.

Like when querying `telemetry.core`, multiple apps are included in each table. It is recommended that you filter on at least `app_name` and `os`. Be sure that no `app_version` field is included in these tables. If you want to filter or join a specific version, you must have already identified the corresponding `app_build_id`(s) for the `app_version` by contacting the engineering team that has created the app.

A few other applications send data to this table. However, it is recommended that you use
this table only for analysis of event data from Focus and its related apps.

### Notes

Each app uses a unique set of release channels. Most apps include a `nightly`, `beta`, `release`, and an `other` channel. Each channel is used during various stages of development: generally users sign up to test a pre-release version (anything other than `release`). In Focus Android, the `beta` channel uses the same APK in the Google Play Store as the `release` channel. However, beta users get access to this version earlier than users who receive the final release.

As soon as the `release` version is published, beta users work with the same version
of the app as users who have received the final released version. Both versions of the software become indistinguishable from each other unless you perform a query that flags them by `client_id`. Beta releases have `normalized_channel` tagged as `release`. If you want to filter for beta users, you can only identify the beta users by checking for a higher version number than the version number and date that have been assigned to the official release.

### Glean

Most of Mozilla's newer mobile apps, including Fenix, have been adapted to use _Glean_, the new telemetry SDK. Glean now sends `baseline`, `metrics`, and `events` pings instead of `core` and `event` pings. For more information, see the [Glean Overview](./glean/glean.md).
