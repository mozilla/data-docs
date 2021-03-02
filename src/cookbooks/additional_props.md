# Additional Properties

If some field is present in a valid received [ping](../concepts/terminology.md#ping),
but is not present in the ping's [schema](../concepts/terminology.md#schema),
it doesn't have its own column to be placed into during
[ingestion](../concepts/terminology.md#ingestion).
Instead, those fields remain as raw JSON and are placed in the
`additional_properties` column of the ping's table or view.

This can happen for a variety of usually-temporary problems like:

- The latest schema hasn't yet been deployed (see ["What does it mean when a schema deploy is blocked?"](../concepts/pipeline/schemas.md#what-does-it-mean-when-a-schema-deploy-is-blocked))
- [`mozilla-pipeline-schemas`](https://github.com/mozilla-services/mozilla-pipeline-schemas) was not updated after a change in the data which was submitted (this shouldn't happen with [Glean](../concepts/terminology.md#glean), but can happen with some legacy data, for example the [legacy Firefox Desktop telemetry environment](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/data/environment.html)).

Until the problem is fixed, any ingested pings with these
"unknown" data in them will place that data in the `additional_properties` column.
The rows of this dataset will always have these data in the
`additional_properties` column,
even after the dataset has been updated to add the column.

To access data that's been put into the `additional_properties` column,
you'll have to parse the JSON.
Be aware that when you access the `additional_properties` field, BigQuery has
to read the entire contents, even if you're extracting just a single field.
In the case of `main` pings, `additional_properties` can be quite large, leading
to expensive queries.

## Example

At the beginning of February 2021, schema deploys were delayed.
So to access the newly-added parent-process Firefox Desktop probes
`telemetry.generated_new_client_id`,
`telemetry.state_file_save_errors`, and
`telemetry.loaded_client_id_doesnt_match_pref`,
we needed to locate where they would be in the payload, and use
`JSON_EXTRACT_SCALAR` to extract the scalar
(in both a JSON and Telemetry sense of the word "scalar") values.

```sql
SELECT
    JSON_EXTRACT_SCALAR(additional_properties, "$.payload.processes.parent.scalars['telemetry.generated_new_client_id']") AS generated_new_client_id,
    JSON_EXTRACT_SCALAR(additional_properties, "$.payload.processes.parent.scalars['telemetry.state_file_save_errors']") AS state_file_save_errors,
    JSON_EXTRACT_SCALAR(additional_properties, "$.payload.processes.parent.scalars['telemetry.loaded_client_id_doesnt_match_pref']") AS loaded_client_id_doesnt_match_pref,
    payload.info.profile_subsession_counter AS profile_subsession_counter
FROM mozdata.telemetry.main_nightly
WHERE
    submission_timestamp > '2021-02-02'
    AND application.build_id >= '20210202095107' -- First nightly with measure 20210202095107
```
