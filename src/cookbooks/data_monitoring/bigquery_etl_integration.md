# bigquery-etl and Bigeye

Monitors can be defined alongside derived datasets in bigquery-etl. Monitoring in Bigeye for a specific table can be enabled by adding `monitoring` metadata to the `metadata.yaml` file:

```yaml
friendly_name: Some Table
monitoring:
  enabled: true # Enables monitoring for the table in Bigeye and deploys freshness and volume metrics
  collection: Test # An existing collection these monitors should be part of in Bigeye
```

Enabling monitoring for a table automatically deploys freshness and volume metrics for this table.

## Bigconfig

Additional and custom monitors can be defined in a [Bigconfig](https://docs.bigeye.com/docs/bigconfig#example-template) `bigconfig.yml` file that is stored in the same directory as the table query. Bigconfig allows users to deploy other pre-defined monitors, such as row counts or null checks on a table or column level.

## Deployment

To generate a `bigconfig.yml` file with the default metrics when monitoring is enabled run: `bqetl monitoring update [PATH]`.
The created file can be manually edited. For tables that do not have a `bigconfig.yml` checked into the repository, the file will get generated automatically before deployment to Bigeye. Files only need to be checked in if there are some customizations.

To manually deploy a Bigconfig file run: `bqetl monitoring deploy [PATH]`. The environment variable `BIGEYE_API_KEY` needs to be set to a valid API token that can be [created in Bigeye](https://docs.bigeye.com/docs/using-api-keys).

The deployment of Bigconfig files also runs automatically as part of the [artifact deployment process](../../concepts/pipeline/artifact_deployment.md), after tables and views have been deployed.
