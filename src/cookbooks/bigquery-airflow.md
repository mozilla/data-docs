# Scheduling BigQuery Queries in Airflow

Queries in [BigQuery-ETL](https://github.com/mozilla/bigquery-etl) can be scheduled in 
[Airflow](https://github.com/mozilla/telemetry-airflow) to be run regularly with the results written to a table.

<!-- toc -->

## In BigQuery-ETL

In the BigQuery-ETL project, queries are written in `/templates`.
The directory structure is based on the destination table: `/templates/{dataset_id}/{table_name}`.
For example, [`/templates/telemetry/core_clients_last_seen_raw_v1/query.sql`](https://github.com/mozilla/bigquery-etl/blob/master/templates/telemetry/core_clients_last_seen_raw_v1/query.sql)
is a query that will write results to the `core_clients_last_seen_raw_v1` table in the `telemetry` dataset.
This can be overridden in Airflow.

If we want to create a new table of just `client_id`'s each day called `client_ids` in the `example` dataset, 
we should create `/templates/example/client_ids/query.sql`:
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

After `/templates/example/client_ids/query.sql` is created, 
`/script/generate_sql` can be run to generate the associated query in `/sql/examples/client_ids/query.sql`
which is the query that will be run by the Airflow task.

Related tests are placed in `/tests/example/client_ids/{test_name}/` and run with `pytest`.  
Tests takes query parameters in `query_params.yaml`, 
a table to read from as newline delimited JSON `{table_name}.ndjson`, 
schema for the table to read from as JSON `{table_name}.schema.json`, 
and expected output as newline delimited JSON `expect.ndjson`.

For example, in `/tests/example/client_ids` we could have:

`query_params.yaml`:
```yaml
- name: submission_date
  type: DATE
  value: 2019-01-01
```

`telemetry_derived.main_summary_v4.schema.json`:
```json
[
  {
    "type": "DATE",
    "name": "submission_date",
    "mode": "REQUIRED"
  },
  {
    "type": "STRING",
    "name": "client_id",
    "mode": "NULLABLE"
  },
  ...
]
```

`telemetry_derived.main_summary_v4.ndjson`:
```json
{"submission_date":  "2019-01-01", "client_id": "a", ...}
{"submission_date":  "2019-01-01", "client_id": "b", ...}
{"submission_date":  "2019-01-01", "client_id": "b", ...}
{"submission_date":  "2019-01-02", "client_id": "c", ...}
```

`expect.ndjson`:
```json
{"client_id": "a", "submission_date":  "2019-01-01"}
{"client_id": "b", "submission_date":  "2019-01-01"}
```

Commit both changes in `templates/` and `/sql`. 
When a commit is made to master in BigQuery-ETL, the Docker image is pushed and available to Airflow.

## In telemetry-airflow

The next step is to create a DAG or add a task to an existing DAG that will run the query.  
In telemetry-airflow, BigQuery related functions are found in `/dags/utils/gcp.py`.
The function we are interested in is [`bigquery_etl_query`](https://github.com/mozilla/telemetry-airflow/blob/c103f3eee4ddc653316325d0ee0deab0bb35ee57/dags/utils/gcp.py#L390).

For our `client_ids` example, we could create a new DAG, `/dags/client_ids.py`:
```python
from airflow import models
from utils.gcp import bigquery_etl_query

default_args = {
    ...
}

dag_name = 'client_ids'

with models.DAG(dag_name, schedule_interval='0 1 * * *', default_args=default_args) as dag:
    client_ids = bigquery_etl_query(
        task_id='client_ids',
        destination_table='client_ids',
        dataset_id='example'
    )
```

By default, `bigquery_etl_query` will execute the query in `/sql/{dataset_id}/{destination_table}/query.sql` 
and write to the `derived-datasets` project but this can be changed via the function arguments.

This DAG will then execute `/sql/example/client_ids/query.sql` every day, 
writing results to the `client_ids` table in the `example` dataset in the `derived-datasets` project.

## Other considerations

- The Airflow task will overwrite the destination table partition
  - Destination table should be partitioned by `submission_date`
  - `date_partition_parameter` argument in `bigquery_etl_query` can be set to `None` to overwrite the whole table
- Airflow can be tested locally following instructions here: 
[https://github.com/mozilla/telemetry-airflow#testing-gke-jobs-including-bigquery-etl-changes](https://github.com/mozilla/telemetry-airflow#testing-gke-jobs-including-bigquery-etl-changes)
- It's possible to change the Docker image that Airflow uses to test changes to BigQuery-ETL before merging changes to master
  - Supply a value to the `docker_image` argument in `bigquery_etl_query`
