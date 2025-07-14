# Connecting Sheets and External Data to BigQuery

Google Sheets and other external data sources can be connected to our Data Warehouse and made available as tables via [bigquery-etl](https://github.com/mozilla/bigquery-etl). Updates made to the connected data source will be instantly available in the BigQuery table. The created tables can be [made available in Looker](https://github.com/mozilla/lookml-generator/blob/main/custom-namespaces.yaml) and restricted in access using [Data Access Workgroups](https://mozilla-hub.atlassian.net/wiki/spaces/SRE/pages/27924789/Data+Access+Workgroups).

## Connecting Sheets

To connect a Google Sheet to BigQuery, the following steps need to be followed:

1. Clone the [bigquery-etl](https://github.com/mozilla/bigquery-etl) repository locally. Setting up the `bqetl` CLI tooling is optional, all the steps here can be done manually.
2. Create a new destination table configuration in the project and dataset the table should be created in BigQuery:
   - If the spreadsheet should be accessible through the table `moz-fx-data-shared-prod.telemetry_derived.insightful_spreadsheet_v1` then create a new folder `insightful_spreadsheet_v1` under `sql/moz-fx-data-shared-prod/telemetry_derived`.
3. Create a `metadata.yaml` file.
   - For `insightful_spreadsheet_v1` the file would need be created under `sql/moz-fx-data-shared-prod/telemetry_derived/insightful_spreadsheet_v1/metadata.yaml`
4. Open the `metadata.yaml` file and specify the configuration similar to the following:

```yaml
friendly_name: Insightful Spreadsheet
description: >
  A description of what the data represents
owners:
  - example@mozilla.com
external_data:
  format: google_sheets
  source_uris:
    - https://docs.google.com/spreadsheets/d/Avakdiasl341kdasdf # URL to the spreadsheet
  options:
    skip_leading_rows: 1 # number of rows that should be skipped, e.g if there are header rows
workgroup_access: # the workgroup_access is optional, used for restricting data access
  - role: roles/bigquery.dataViewer
    members:
      - workgroup:secret/gp
```

- It is possible to provide multiple URLs to spreadsheets. These spreadsheets need to have the same structure (same columns and types) and will be combined (aka `UNION`ed) in the BigQuery table.
- `workgroup_access` is optional and does not need to be specified for data accessible by Mozilla employees. It only needs to be specified if a subset of people, belonging to a specific workgroup, should have access

5. Create a `schema.yaml` file.
   - For `insightful_spreadsheet_v1` the file would need be created under `sql/moz-fx-data-shared-prod/telemetry_derived/insightful_spreadsheet_v1/schema.yaml`
6. Open the `schema.yaml` file and specify the structure of the spreadsheet (aka schema) similar to the following:

```yaml
fields:
  - mode: NULLABLE
    name: first_column_name # this will be the column name in the BigQuery table for the first spreadsheet column
    type: STRING # this will be the data type used for this column in BigQuery
  - mode: NULLABLE
    name: second_column_name
    type: DATE
  - mode: NULLABLE
    name: third_column_name
    type: FLOAT64
```

7. Go to the spreadsheet, click on "Share" and add the following service account as _Editor_: `jenkins-node-default@moz-fx-data-terraform-admin.iam.gserviceaccount.com`
   - This is necessary to ensure the correct access permissions get applied to the spreadsheet
8. Open a pull-request against [bigquery-etl](https://github.com/mozilla/bigquery-etl) and tag someone for review.
   - Due to the permissions required, it is not possible to build and QA this table before it is deployed after merging.
9. Once the PR has been reviewed and merged, the table will be available the next day in BigQuery.
   - If the table should be made available immediately, then go to the [`bqetl_artifact_deployment` Airflow DAG](https://workflow.telemetry.mozilla.org/dags/bqetl_artifact_deployment/grid) and clear the `publish_new_tables` task. This might need to be done by a data engineer or someone who has permissions to trigger and clear tasks in Airflow. The table will be available as soon as the task finishes.

For confidential data it is generally recommended to add these configurations to [private-bigquery-etl](https://github.com/mozilla/private-bigquery-etl). The process and configurations are the same, the only difference is the repository which is not publicly accessible.
