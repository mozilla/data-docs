# Accessing Experiment Telemetry

This article introduces the datasets that are useful for analyzing studies in Firefox.
After reading this article, you should understand how to answer questions about
experiment enrollment, and identify telemetry from clients enrolled in an experiment.

## Table of contents

<!-- toc -->

## Dashboards

[Experimenter] is the place to find lists of live experiments.

[experimenter]: https://experimenter.services.mozilla.com/

## Experiment slugs

Each experiment is associated with a slug,
which is the label used to identify the experiment to Normandy clients.
The slug is also used to identify the experiment in most telemetry.
The slug for pref-flip experiments is defined in the recipe by a field named `slug`;
the slug for add-on experiments is defined in the recipe by a field named `name`.

You can find the slug associated with an experiment in Experimenter.

## Tables (Glean)

### `experiments` map (Glean)

Glean tables include a `ping_info` column with `experiments` mapping from
experiment slug to a struct containing information about the experiment,
including `branch`.

You can query for enrolled clients using a query like:

```sql
SELECT
  -- ... some fields ...,
  `mozfun.map.get_key`(ping_info.experiments, '{experiment_slug}').branch
FROM
  `moz-fx-data-shared-prod.firefox_desktop.metrics`
WHERE
  `mozfun.map.get_key`(ds.ping_info.experiments, '{experiment_slug}') IS NOT NULL
  AND DATE(m.submission_timestamp) BETWEEN '<start_date>' AND '<end_date>'
  AND normalized_channel = 'release'
  -- AND ...other filters...
```

## Tables (Legacy Telemetry)

As of January 2025, legacy telemetry is still used for enrollment and exposure
events. However, while Glean adoption is in progress, these docs remain for
the time being as reference.

### `experiments` map (ping tables)

Ping tables and some derived tables include an `experiments` column
which is a mapping from an experiment slug to a struct of information
about the client's state in an experiment in which they are enrolled.

The struct will include the fields `branch` and `enrollment_id`,
the latter of which is a unique identifier computed at the time of enrollment
to allow counting the number of physical clients that enroll,
even in the presence of `client_id` sharing.

You can collect rows from enrolled clients using syntax like:

```sql
SELECT
  ... some fields ...,
  mozfun.map.get_key(experiments, 'some-experiment-slug-12345').branch
FROM
  telemetry.main
WHERE
  mozfun.map.get_key(experiments, 'some-experiment-slug-12345') IS NOT NULL
```

### `experiments` column (some derived tables)

[`main_summary`](batch_view/main_summary/reference.md),
[`clients_daily`](batch_view/clients_daily/reference.md),
and some other tables
include a `experiments` column
which is a mapping from experiment slug to branch.

You can collect rows from enrolled clients using query syntax like:

```sql
SELECT
  ... some fields ...,
  mozfun.map.get_key(experiments, 'some-experiment-slug-12345') AS branch
FROM
  telemetry.clients_daily
WHERE
  mozfun.map.get_key(experiments, 'some-experiment-slug-12345') IS NOT NULL
```

### `events`

The [`events` table](batch_view/events/reference.md) includes
Normandy and Nimbus enrollment and unenrollment events
for all kinds of studies.

Normandy and Nimbus events both have event category `normandy`.
The event value will contain the experiment slug.

The event schema is described
[in the Firefox source tree](https://searchfox.org/firefox-main/source/toolkit/components/normandy/metrics.yaml).

The `events` table is updated daily.
