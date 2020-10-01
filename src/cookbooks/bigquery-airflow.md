# Scheduling BigQuery Queries in Airflow

Queries in [`bigquery-etl`](https://github.com/mozilla/bigquery-etl) can be scheduled in
[Airflow](https://github.com/mozilla/telemetry-airflow) to be run regularly with the results written to a table.

<!-- toc -->

## In bigquery-etl

In the [`bigquery-etl`](https://github.com/mozilla/bigquery-etl) project, queries are written in `/sql`.
The directory structure is based on the destination table: `/sql/{project_id}/{dataset_id}/{table_name}`.
For example, [`/sql/moz-fx-data-shared-prod/telemetry_derived/core_clients_last_seen_v1/query.sql`](https://github.com/mozilla/bigquery-etl/blob/master/sql/moz-fx-data-shared-prod/telemetry_derived/core_clients_last_seen_v1/query.sql)
is a query that will write results to the `core_clients_last_seen_v1` table in the `telemetry_derived` dataset.

If we want to create a new table of just `client_id`'s each day called `client_ids` in the `example` dataset
in the `moz-fx-data-shared-prod` project, we should create `/sql/moz-fx-data-shared-prod/example/client_ids/query.sql`:

```sql
SELECT
  DISTINCT(client_id),
  submission_date
FROM
    telemetry_derived.main_summary_v4
WHERE
  submission_date = @submission_date
```

`@submission_date` is a parameter that will be filled in by Airflow.

To schedule your query, create a `/sql/moz-fx-data-shared-prod/example/client_ids/metadata.yaml` file with the following content:

```yaml
friendly_name: Client IDs
description: Unique client IDs, partitioned by day.
owners:
  - example@mozilla.com
labels:
  application: firefox
  incremental: true # incremental queries add data to existing tables
scheduling:
  dag_name: bqetl_client_ids
```

The `scheduling` section schedules the query as a task that is part of the `bqetl_clients_ids` DAG. Make sure that
the `bqetl_clients_ids` DAG is actually defined in `dags.yaml` and has the right scheduling interval, for example:

```yaml
bqetl_clients_ids: # name of the DAG; must start with bqetl_
  schedule_interval: 0 2 * * * # query schedule; every day at 2am
  default_args:
    owner: example@mozilla.com
    start_date: "2020-04-05" # YYYY-MM-DD
    email: ["example@mozilla.com"]
    retries: 2 # number of retries if the query execution fails
    retry_delay: 30m
```

In this example, the `bqetl_clients_ids` DAG and the created query will be executed on a daily basis at 02:00 UTC.

Run `./script/generate_airflow_dags` to generate the Airflow DAG or generate the DAG using the [`bqetl` CLI](https://github.com/mozilla/bigquery-etl#the-bqetl-cli):
`bqetl dag generate bqetl_clients_ids`. Task dependencies that are defined in bigquery-etl and
dependencies to stable tables are determined automatically. Generated DAGs are written to the `dags/` directory and
will be automatically detected and scheduled by Airflow once the changes are committed to master in `bigquery-etl`.

## Other considerations

- The Airflow task will overwrite the destination table partition
  - Destination table should be partitioned by `submission_date`
  - `date_partition_parameter` can be set to `null` to overwrite the whole table in the `scheduling` section
    of the `metadata.yaml` file
