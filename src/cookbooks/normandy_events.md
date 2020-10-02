# Working with Normandy events

A common request is to count the number of users who have
enrolled or unenrolled from a SHIELD experiment.

The [`events` table](../datasets/batch_view/events/reference.md)
includes Normandy enrollment and unenrollment events
for both pref-flip and add-on studies.
Note that the events table is updated nightly.

Normandy events have `event_category` `normandy`.
The `event_string_value` will contain the experiment slug (for pref-flip experiments)
or name (for add-on experiments).

Normandy events are described in detail in the
[Firefox source tree docs][normandy-doc].

Note that addon studies do not have branch information in the events table,
since addons, not Normandy, are responsible for branch assignment.
For studies built with the obsolete [add-on utilities][`addon-utils`],
branch assignments are published to the
[shield_study] dataset.

## Counting pref-flip enrollment events by branch

The `event_map_values` column of enroll events contains a `branch` key,
describing which branch the user enrolled in.

To fetch a count of events by branch in BigQuery SQL:

```sql
SELECT
  submission_date,
  udf.get_key(event_map_values, 'branch') AS branch,
  COUNT(*) AS n
FROM telemetry.events
WHERE
  event_category = 'normandy'
  AND event_method = 'enroll'
  AND event_string_value = '{{experiment_slug}}'
  AND submission_date >= '{{experiment_start}}'
GROUP BY 1, 2
ORDER BY 1, 2
```

## Counting pref-flip unenrollment events by branch

The `event_map_values` column of unenroll events includes a `reason` key.
Reasons are described in the [Normandy docs][normandy-doc].
Normal unenroll events at the termination of a study will occur for the reason `recipe-not-seen`.

To fetch a count of events by reason and branch:

```sql
SELECT
  submission_date,
  udf.get_key(event_map_values, 'branch') AS branch,
  udf.get_key(event_map_values, 'reason') AS reason,
  COUNT(*) AS n
FROM telemetry.events
WHERE
  event_category = 'normandy'
  AND event_method = 'unenroll'
  AND event_string_value = '{{experiment_slug}}'
  AND submission_date >= '{{experiment_start}}'
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3
```

[normandy-doc]: https://firefox-source-docs.mozilla.org/toolkit/components/normandy/normandy/data-collection.html#enrollment
[shield_study]: ../datasets/shield.md#telemetryshield_study
[`addon-utils`]: https://github.com/mozilla/shield-studies-addon-utils
