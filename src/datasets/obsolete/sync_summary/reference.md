# Sync Summary and Sync Flat Summary Reference

<!-- toc -->

# Introduction

{{#include ./intro.md}}

# Data Reference

## A note about user IDs

Unlike most other telemetry datasets, these do not contain the profile-level identifier `client_id`. Because you need to sign up for a [Firefox Account](https://www.mozilla.org/en-US/firefox/accounts/) in order to use sync, these datasets instead include an anonymised version of the user's Firefox Account user id `uid` and an anonymised version of their individual devices' `device_id`s. Put another way, each `uid` can have many associated `device_id`s.

**Q:** Why not include `client_id` in these datasets so that they can be joined on (e.g.) `main_summary`?

**A:** We've had a policy to keep main browser telemetry separate from sync and FxA telemetry. This is in part because FxA `uid`s are ultimately associated with email addresses in the FxA database, and thus a breach of that database in combination with access to telemetry could in theory de-anonymise client-side browser metrics.

## Which apps send sync telemetry? What about Fenix?

Currently, Firefox for desktop, Firefox for iOS and Firefox for Android (fennec) all have sync implemented, and they all send sync telemetry. Though there are some differences in the telemetry that each application sends, it all ends up in the `sync_summary` and `sync_flat_summary` datasets.

Starting with Fenix, however, sync telemetry will start to be sent through [glean](https://github.com/mozilla-mobile/android-components/tree/master/components/service/glean). This means that, in all likelihood, Fenix sync telemetry will initially be segregated from existing sync telemetry (one reason is that current sync telemetry is on AWS while glean pings are ingested to GCP).

## What's an engine?

Firefox syncs many different types of browser data and (generally speaking) each one of these data types are synced by their own engine. When the app triggers a "sync" each engine makes their own determination of what needs to be synced (if anything). Many syncs can happen in a day (dozens or more on desktop, usually less on mobile). Telemetry about each sync is logged, and each [sync ping](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/sync-ping.html) (sent once a day, and whenever the user logs in or out of sync) contains information about multiple syncs. The scala code responsible for creating the `sync_summary` dataset unpacks each sync ping into one row per sync. The resulting `engines` field is an array of "engine records": data about how each engine performed during that sync. `sync_flat_summary` further unpacking/exploding the `engines` field and creates a dataset that is one row per engine record.

Existing engines (`engine_name` in `sync_flat_summary`) are listed below with brief descriptions in cases where their name isn't transparent.

Note that not every device syncs each of these engines. They can be disabled individually and some are off by default.

- `addons`
- `addresses` mailing addresses e.g. for e-commerce; part of form autofill.
- `bookmarks`
- `clients` non-user-facing list of the sync account's associated devices
- `creditcards` this used to be nightly only but was recently removed entirely
- `extension-storage` WebExtension storage, in support of the `storage.sync` WebExtension API.
- `history` browsing history.
- `passwords`
- `forms` saved values in web forms
- `prefs` not all prefs are synced
- `tabs` note that this is not the same as the "send tab" feature, this is the engine that syncs the tabs you have open across your devices (used to populate the synced tabs sidebar). For data on the send-tab feature use the `sync_events` dataset.

## Example Queries

See [this dashboard](https://sql.telemetry.mozilla.org/dashboard/sync-leif-status-dashboard-wip) to get a general sense of what this dataset is typically used for.

Here's an example of a query that will calculate the failure and success rates for a subset of engines per day.

```sql
WITH
    counts AS (
        SELECT
          submission_date_s3 AS day,
          engine_name AS engine,
          COUNT(*) AS total,
          COUNT(CASE WHEN engine_status IS NOT NULL THEN true ELSE NULL END) AS count_errors,
          /* note that `engine_status` is null on sync success. */
          COUNT(CASE WHEN engine_status IS NULL THEN true ELSE NULL END) AS count_success
        FROM telemetry.sync_flat_summary
        WHERE engine_name IN ('bookmarks','history','tabs','addons','addresses','passwords','prefs')
        AND cast(submission_date_s3 AS integer) >= 20190101
        GROUP BY 1,2
        ORDER BY 1
    ),

    rates AS (
        SELECT
          day,
          engine,
          total,
          count_errors,
          count_success,
          CAST(count_errors AS double) / CAST(total AS double) * 100 AS error_rate,
          CAST(count_success AS double) / CAST(total AS double) * 100 AS success_rate
        FROM counts
        ORDER BY 1
    )

SELECT * FROM rates
```

## Sampling

Sadly, these datasets are not sampled. It should be possible to derive a `sample_id` on `uid`, however. Someone should do that because querying these datasets for long time horizons is very expensive.

## Scheduling

This dataset was updated daily, shortly after midnight UTC.
The job was scheduled on [Airflow](https://github.com/mozilla/telemetry-airflow).
The DAG was [here](https://github.com/mozilla/telemetry-airflow/blob/27d34a73db02131a39f469f3950c1da747bc8a95/dags/sync_view.py).

## Sync Summary Schema

```
root
 |-- app_build_id: string (nullable = true)
 |-- app_display_version: string (nullable = true)
 |-- app_name: string (nullable = true)
 |-- app_version: string (nullable = true)
 |-- app_channel: string (nullable = true)
 |-- uid: string
 |-- device_id: string (nullable = true)
 |-- when: integer
 |-- took: integer
 |-- why: string (nullable = true)
 |-- failure_reason: struct (nullable = true)
 |    |-- name: string
 |    |-- value: string (nullable = true)
 |-- status: struct (nullable = true)
 |    |-- sync: string (nullable = true)
 |    |-- status: string (nullable = true)
 |-- devices: array (nullable = true)
 |    |-- element: struct (containsNull = false)
 |    |    |-- id: string
 |    |    |-- os: string
 |    |    |-- version: string
 |-- engines: array (nullable = true)
 |    |-- element: struct (containsNull = false)
 |    |    |-- name: string
 |    |    |-- took: integer
 |    |    |-- status: string (nullable = true)
 |    |    |-- failure_reason: struct (nullable = true)
 |    |    |    |-- name: string
 |    |    |    |-- value: string (nullable = true)
 |    |    |-- incoming: struct (nullable = true)
 |    |    |    |-- applied: integer
 |    |    |    |-- failed: integer
 |    |    |    |-- new_failed: integer
 |    |    |    |-- reconciled: integer
 |    |    |-- outgoing: array (nullable = true)
 |    |    |    |-- element: struct (containsNull = false)
 |    |    |    |    |-- sent: integer
 |    |    |    |    |-- failed: integer
 |    |    |-- validation: struct (containsNull = false)
 |    |    |    |-- version: integer
 |    |    |    |-- checked: integer
 |    |    |    |-- took: integer
 |    |    |    |-- failure_reason: struct (nullable = true)
 |    |    |    |    |-- name: string
 |    |    |    |    |-- value: string (nullable = true)
 |    |    |    |-- problems: array (nullable = true)
 |    |    |    |    |-- element: struct (containsNull = false)
 |    |    |    |    |    |-- name: string
 |    |    |    |    |    |-- count: integer
```

## Sync Flat Summary Schema

```
root
|-- app_build_id: string (nullable = true)
|-- app_display_version: string (nullable = true)
|-- app_name: string (nullable = true)
|-- app_version: string (nullable = true)
|-- app_channel: string (nullable = true)
|-- os: string
|-- os_version: string
|-- os_locale: string
|-- uid: string
|-- device_id: string (nullable = true)
|-- when: integer
|-- took: integer
|-- failure_reason: struct (nullable = true)
|    |-- name: string
|    |-- value: string (nullable = true)
|-- status: struct (nullable = true)
|    |-- sync: string (nullable = true)
|    |-- status: string (nullable = true)
|-- why: string (nullable = true)
|-- devices: array (nullable = true)
|    |-- element: struct (containsNull = false)
|    |    |-- id: string
|    |    |-- os: string
|    |    |-- version: string
|-- sync_id: string
|-- sync_day: string
|-- engine_name: string
|-- engine_took: integer
|-- engine_status: string (nullable = true)
|-- engine_failure_reason: struct (nullable = true)
|    |-- name: string
|    |-- value: string (nullable = true)
|-- engine_incoming_applied: integer (nullable = true)
|-- engine_incoming_failed: integer (nullable = true)
|-- engine_incoming_new_failed: integer (nullable = true)
|-- engine_incoming_reconciled: integer (nullable = true)
|-- engine_outgoing_batch_count: integer (nullable = true)
|-- engine_outgoing_batch_total_sent: integer (nullable = true)
|-- engine_outgoing_batch_total_failed: integer (nullable = true)
|-- submission_date_s3: string
```
