# Working with Normandy events

<div class="warning">
Normandy and SHIELD are older experimentation platforms
at Mozilla, but are no longer in use. However, Normandy
events are still in use (as of January 2025) by Jetstream
for computing enrollments and exposures. Note that this
will likely change in the near future because these events
have been ported to Glean and legacy telemetry is being
deprecated across the platform.

For more up to date information on events used by Nimbus,
see <https://experimenter.info/telemetry>.

</div>

The [`events` table](../datasets/batch_view/events/reference.md)
includes Normandy enrollment and unenrollment events
for both pref-flip and add-on studies.
Note that the events table is updated nightly.

Normandy events have `event_category` `normandy`.
The `event_string_value` will contain the experiment slug (for pref-flip experiments)
or name (for add-on experiments).

Normandy events are described in detail in the
[Firefox source tree docs][normandy-doc].

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
