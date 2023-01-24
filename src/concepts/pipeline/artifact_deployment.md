# BigQuery Artifact Deployment

Artifacts that get deployed automatically, usually during nightly Airflow runs, to BigQuery include:

- user-defined functions
- datasets
- tables
- views

## Dataset Deployment

Terraform will deploy datasets defined in [bigquery-etl](https://github.com/mozilla/bigquery-etl) and [private-bigquery-etl](https://github.com/mozilla/private-bigquery-etl) and datasets that are configured via [cloudops-infra](https://github.com/mozilla-services/cloudops-infra/blob/master/projects/data-shared/tf/prod/envs/prod/bigquery-new/namespaces.auto.tfvars.json). The dataset deployment is triggered via Jenkins whenever bigquery-etl publishes a new container or after schema deployment.

## User-defined Function (UDF) Deployment

There are two categories of user-defined functions:

- UDFs for internal use only: These UDFs are published to the `udf` and `udf_js` datasets in the `moz-fx-data-shared-prod` project and managed via [bigquery-etl](https://github.com/mozilla/bigquery-etl/tree/main/sql/moz-fx-data-shared-prod/udf)
- public UDFs that can be used even outside of Mozilla projects: These UDFs are published to the `mozfun` project and managed via [bigquery-etl](https://github.com/mozilla/bigquery-etl/tree/main/sql/mozfun)

The UDF deploy is triggered through the `publish_public_udfs` and `publish_persistent_udfs` Airflow task in the [`bqetl_artifact_deployment`](https://workflow.telemetry.mozilla.org/tree?dag_id=bqetl_artifact_deployment) Airflow DAG which run nightly, but can be triggered manually by clearing the tasks.

## Table Deployment

Tables get deployed through the [`publish_new_tables` Airflow task](https://workflow.telemetry.mozilla.org/tree?dag_id=bqetl_artifact_deployment) which runs nightly. This task will run all SQL generators, generate schemas for each query and will deploy schemas for tables and apply any schema-compatible changes for existing tables. The task will fail if changes that are incompatible with existing schemas (such as removing fields or changing field types) are to be applied.

## View Deployment

View deployment runs after new tables have been published through the [`publish_views` Airflow task](https://workflow.telemetry.mozilla.org/tree?dag_id=bqetl_artifact_deployment). This task will run all SQL generators, which ensures that SQL for generated views will be available. Only views with either changes to their SQL definition, schema, metadata or newly created views will be deployed.

Views that have been defined in bigquery-etl will be tagged with a `managed` label. This label is used to automatically remove views from BigQuery that have been deleted in bigquery-etl. Having this label ensures that manually created views or views created through other tooling won't get deleted as part of this process.

Views get published to `moz-fx-data-shared-prod` and publicly-facing views get published to `mozdata`.
