# hgpush

This dataset records facts about individual commits to the Firefox source tree
in the [`mozilla-central`](https://hg.mozilla.org/mozilla-central/) source
code repository.

# Data Reference

The dataset is accessible via [`STMO`](https://sql.telemetry.mozilla.org).
Use the `eng_workflow_hgpush_parquet_v1` table with the `Athena` data source.
(The `Presto` data source is also available, but much slower.)

## Field Types and Descriptions

See the [`hgpush` ping schema](https://github.com/mozilla-services/mozilla-pipeline-schemas/blob/master/schemas/eng-workflow/hgpush/hgpush.1.schema.json)
for a description of available fields.

Be careful to:

- Use the latest schema version. e.g. `v1`. Browse the [`hgpush` schema directory](https://github.com/mozilla-services/mozilla-pipeline-schemas/tree/master/schemas/eng-workflow/hgpush) in the GitHub repo to be sure.
- Change dataset field names from `camelCaseNames` to `under_score_names` in STMO. e.g. `reviewSystemUsed` in the ping schema becomes `review_system_used` in STMO.

## Example Queries

Select the number of commits with an 'unknown' review system in the last 7 days:

```sql
select
    count(1)
from
    eng_workflow_hgpush_parquet_v1
where
    review_system_used = 'unknown'
    and date_diff('day', from_unixtime(push_date), now()) < 7
```

# Code Reference

The dataset is populated via the [Commit Telemetry Service](https://github.com/mozilla-conduit/commit-telemetry-service).
