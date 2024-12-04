# bigquery-etl and Bigeye

Monitors can be defined alongside derived datasets in bigquery-etl. Monitoring in Bigeye for a specific table can be enabled by adding `monitoring` metadata to the `metadata.yaml` file:

```yaml
friendly_name: Some Table [warn]
monitoring:
  enabled: true # Enables monitoring for the table in Bigeye and deploys freshness and volume metrics
  collection: Test # An existing collection these monitors should be part of in Bigeye
```

Enabling monitoring for a table automatically deploys freshness and volume metrics for this table.

Bigeye monitors are triggered automatically via Airflow for queries that have `monitoring` set to `enabled: true`. The checks are executed after the ETL run for the table has been completed.

To indicate whether a failing check should block any downstream Airflow tasks, a `[warn]` or `[fail]` can be added to the name of the Bigeye metric. By default, all metrics that do not have either of those tags specified are considered as `[warn]`. These metrics won't be blocking any downstream Airflow tasks when checks fail, but any failing check will appear in the Bigeye dashboard. Metrics that have `[fail]` specified in their names will block the execution of downstream Airflow tasks in the event of a check failing.

## Bigconfig

Additional and custom monitors can be defined in a [Bigconfig](https://docs.bigeye.com/docs/bigconfig#example-template) `bigconfig.yml` file that is stored in the same directory as the table query. Bigconfig allows users to deploy other pre-defined monitors, such as row counts or null checks on a table or column level.

## Custom SQL Rules

> > This is a temporary workaround until custom SQL rules are supported in Bigconfig, which is currently being worked on.

Custom SQL rules can be configured in a separate `bigeye_custom_rules.sql` file alongside the query. This file can contain various rules:

```sql
-- {
--   "name": "Fenix releases version format",
--   "alert_conditions": "value",
--   "range": {
--     "min": 0,
--     "max": 1
--   },
--   "collections": ["Test"],
--   "owner": "",
--   "schedule": "Default Schedule - 13:00 UTC"
-- }
SELECT
  ROUND((COUNTIF(NOT REGEXP_CONTAINS(version, r"^[0-9]+\..+$"))) / COUNT(*) * 100, 2) AS perc
FROM
  `{{ project_id }}.{{ dataset_id }}.{{ table_name }}`;

-- {
--   "name": "Fenix releases product check",
--   "alert_conditions": "value",
--   "range": {
--     "min": 0,
--     "max": 1
--   },
--   "collections": ["Test"],
--   "owner": "",
--   "schedule": "Default Schedule - 13:00 UTC"
-- }
SELECT
  ROUND((COUNTIF(product != "fenix")) / COUNT(*) * 100, 2) AS perc
FROM
  `{{ project_id }}.{{ dataset_id }}.{{ table_name }}`;
```

The SQL comment before the rule SQL has to be a JSON object that contains the configuration parameters for this rule:

- `name`: the name of the SQL rule. Specify `[warn]` or `[fail]` to indicate whether a rule failure should block downstream Airflow tasks
- `alert_conditions`: one of `value` (alerts based on the returned value) or `count` (alerts based on whether the query returns rows)
- `collections`: list of collections this rule should be a part of
- `owner`: email address of the rule owner
- `schedule`: optional schedule of when this rule should be triggered. The rule will also get triggered as part of Airflow
- `range`: optional range of allowed values when `"alert_conditions": "value"`

## Deployment

To generate a `bigconfig.yml` file with the default metrics when monitoring is enabled run: `bqetl monitoring update [PATH]`.
The created file can be manually edited. For tables that do not have a `bigconfig.yml` checked into the repository, the file will get generated automatically before deployment to Bigeye. Files only need to be checked in if there are some customizations.

The deployment of Bigconfig files runs automatically as part of the [artifact deployment process](../../concepts/pipeline/artifact_deployment.md), after tables and views have been deployed.
