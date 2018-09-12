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

[Firefox Test Tube](https://firefox-test-tube.herokuapp.com/)
shows live enrollment activity and a selection of browser activity metrics
for active pref-flip (and some add-on)[^1] experiments.

The
[Shield Studies Viewer](https://strategy-and-insights.mozilla.com/shield-studies/index.html)
and
[Experimenter](https://experimenter.services.mozilla.com/)
are other places to find lists of live experiments.

## Experiment slugs

Each experiment is associated with a slug,
which is the label used to identify the experiment to Normandy clients.
The slug is also used to identify the experiment in most telemetry.
The slug for pref-flip experiments is defined in the recipe by a field named `slug`;
the slug for add-on experiments is defined in the recipe by a field named `name`.

You can determine the slug for a particular experiment by consulting
[this summary table](https://metrics.mozilla.com/~sguha/report/normandy_recipes.html),
[Test Tube](https://firefox-test-tube.herokuapp.com/) (which may be missing add-on studies)[^1],
or the list of active recipes at
https://normandy.cdn.mozilla.net/api/v1/recipe/signed/.

## Tables

These tables should be accessible from ATMO, Databricks, Presto, and Athena.

### `experiments` column

[`main_summary`](batch_view/main_summary/reference.md),
[`clients_daily`](batch_view/clients_daily/reference.md),
[`crash_summary`](batch_view/crash_summary/reference.md),
and some other tables
include a `experiments` column
which is a mapping from experiment stub to branch.

You can collect rows from enrolled clients using query syntax like:

```sql
SELECT
  *,
  experiments['some-experiment-stub-12345'] AS branch
FROM clients_daily
WHERE experiments['some-experiment-stub-12345'] IS NOT NULL
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
Normandy enrollment and unenrollment events.

Normandy events have event category `normandy`.
The event value will contain the experiment slug.

The event schema is described
[in the Firefox source tree](https://hg.mozilla.org/mozilla-central/file/tip/toolkit/components/normandy/lib/TelemetryEvents.jsm).

The `events` table is updated daily.

### `telemetry_shield_study_addon_parquet`

The `telemetry_shield_study_addon_parquet` table contains SHIELD telemetry from add-on experiments,
i.e. key-value pairs sent with the
`browser.study.sendTelemetry()` method from the
[SHIELD study add-on utilities](https://github.com/mozilla/shield-studies-addon-utils/)
library.

The schema for shield-study-addon pings is described in the
[`mozilla-pipeline-schemas` repository](https://github.com/mozilla-services/mozilla-pipeline-schemas/tree/dev/schemas/telemetry/shield-study-addon).

The key-value pairs are present in `data` attribute of the `payload` column.

The `telemetry_shield_study_addon_parquet` table is produced by direct-to-parquet;
data latency should be less than 1 hour.

### `telemetry_shield_study_parquet`

Telemetry from Normandy itself, containing enrollment and unenrollment events.
These events also appear in the `events` table.

The `telemetry_shield_study_parquet` table is produced by direct-to-parquet;
data latency should be less than 1 hour.

## Raw ping sources

### `telemetry-cohorts`

The `telemetry-cohorts` dataset contains a subset of pings
from clients enrolled in experiments,
accessible as a
[Dataset](https://python-moztelemetry.readthedocs.io/en/stable/api.html#dataset),
and partitioned by `experimentId` and `docType`.

Experiments deployed to large fractions of the release channel
may have the `isHighVolume` flag set in the Normandy recipe;
those experiments will not be aggregated into the `telemetry-cohorts` source.

To learn which branch clients are enrolled in,
reference the `environment.experiments` field.

[^1] Add-on experiments are displayed in Test Tube
when the `name` given in the Normandy recipe matches the `applications.gecko.id`
listed in the add-on's `manifest.json`.
This is often not the case.
