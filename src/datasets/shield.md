# Analyzing data from SHIELD studies

This article introduces the datasets that are useful for analyzing SHIELD studies.
After reading this article,
you should understand how to answer questions about
study enrollment,
identify telemetry from clients enrolled in an experiment,
and locate telemetry from add-on studies.

## Table of contents

<!-- toc -->

## Dashboards

The [Shield Studies Viewer] and [Experimenter] dashboards
are other places to find lists of live experiments.

[Shield Studies Viewer]: BROKEN:https://strategy-and-insights.mozilla.com/shield-studies/index.html
[Experimenter]: https://experimenter.services.mozilla.com/

## Experiment slugs

Each experiment is associated with a slug,
which is the label used to identify the experiment to Normandy clients.
The slug is also used to identify the experiment in most telemetry.
The slug for pref-flip experiments is defined in the recipe by a field named `slug`;
the slug for add-on experiments is defined in the recipe by a field named `name`.

You can determine the slug for a particular experiment by consulting
[this summary table](https://metrics.mozilla.com/~sguha/report/normandy_recipes.html)
or the list of active recipes at
https://normandy.cdn.mozilla.net/api/v1/recipe/signed/.

## Tables

These tables are accessible from BigQuery and Databricks.

### `experiments` column

[`main_summary`](batch_view/main_summary/reference.md),
[`clients_daily`](batch_view/clients_daily/reference.md),
and some other tables
include a `experiments` column
which is a mapping from experiment slug to branch.

You can collect rows from enrolled clients using query syntax like:

```sql
SELECT
  ... some fields ...,
  udf.get_key(experiments, 'some-experiment-slug-12345') AS branch
FROM
  telemetry.clients_daily
WHERE
  udf.get_key(experiments, 'some-experiment-slug-12345') IS NOT NULL
```

### `experiments`

The `experiments` table is a subset of rows from `main_summary`
reflecting pings from clients that are currently enrolled in an experiment.
The `experiments` table has additional string-type
`experiment_id` and `experiment_branch` columns,
and is partitioned by `experiment_id`, which makes it efficient to query.

Experiments deployed to large fractions of the release channel
may have the `isHighVolume` flag set in the Normandy recipe;
those experiments will not be aggregated into the `experiments` table.

Please note that the `experiments` table cannot be used
for calculating retention for periods extending beyond
the end of the experiment.
Once a client is unenrolled from an experiment,
subsequent pings will not be captured by the `experiments` table.

### `events`

The [`events` table](batch_view/events/reference.md) includes
Normandy enrollment and unenrollment events
for both pref-flip and add-on studies.

Normandy events have event category `normandy`.
The event value will contain the experiment slug.

The event schema is described
[in the Firefox source tree](https://hg.mozilla.org/mozilla-central/file/tip/toolkit/components/normandy/lib/TelemetryEvents.jsm).

The `events` table is updated daily.

### `telemetry.shield_study_addon`

The `telemetry.shield_study_addon` table contains SHIELD telemetry from add-on experiments,
i.e. key-value pairs sent with the
`browser.study.sendTelemetry()` method from the
[SHIELD study add-on utilities](https://github.com/mozilla/shield-studies-addon-utils/)
library.

The `study_name` attribute of the `payload` column will contain the identifier
registered with the SHIELD add-on utilities.
This is set by the add-on; sometimes it takes the value of
`applications.gecko.id` from the add-on's `manifest.json`.
This is often not the same as the Normandy slug.

The schema for shield-study-addon pings is described in the
[`mozilla-pipeline-schemas` repository](https://github.com/mozilla-services/mozilla-pipeline-schemas/tree/master/schemas/telemetry/shield-study-addon).

The key-value pairs are present in `data` attribute of the `payload` column.

The `telemetry.shield_study_addon` table contains only full days of data.
If you need access to data with lower latency, you can use the "live" table
`telemetry_live.shield_study_addon_v4` which should have latency significantly
less than 1 hour.

### `telemetry.shield_study`

The `telemetry.shield_study` dataset includes
enrollment and unenrollment events for add-on experiments only,
sent by the [SHIELD study add-on utilities](https://github.com/mozilla/shield-studies-addon-utils/).

The `study_name` attribute of the `payload` column will contain the identifier
registered with the SHIELD add-on utilities.
This is set by the add-on; sometimes it takes the value of
`applications.gecko.id` from the add-on's `manifest.json`.
This is often not the same as the Normandy slug.

Normandy also emits its own enrollment and unenrollment events for these studies,
which are available in the `events` table.

The `telemetry.shield_study` table contains only full days of data.
If you need access to data with lower latency, you can use the "live" table
`telemetry_live.shield_study_v4` which should have latency significantly
less than 1 hour.
