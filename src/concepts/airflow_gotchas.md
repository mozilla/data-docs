# Airflow Gotcha's

Airflow is an integral part of our data platform. ETL processes, forecasts and various analyses are scheduled and monitored through Airflow. Our Airflow instance is hosted at [`workflow.telemetry.mozilla.org`](https://workflow.telemetry.mozilla.org/home) (WTMO).

## DAGs are automatically generated for the most part

Airflow DAGs for our ETL processes get automatically generated as part of [bigquery-etl](https://github.com/mozilla/bigquery-etl). The process for scheduling queries is to specify a DAG as part of its metadata. How to schedule queries is described in detail this [guide to creating a derived dataset](https://mozilla.github.io/bigquery-etl/cookbooks/creating_a_derived_dataset/). Generated DAGs are prefixed with `bqetl_`.

Some DAGs, for example for custom machine learning tasks or to schedule running custom tools, need to be defined manually. These DAGs need to be created in the [telemetry-airflow](https://github.com/mozilla/telemetry-airflow/tree/main/dags) repository.

A separate script syncs generated bigquery-etl DAGs every 10 minutes to our Airflow instance. DAGs that live in telemetry-airflow get deployed via CircleCI whenever a change is pushed to `main`.

## New DAGs need to be unpaused manually

After adding a new DAG either through bigquery-etl or telemetry-airflow, it will take about 10 minutes until the new DAG gets deployed. After deployment, the DAG is by default disabled. It is necessary to manually _unpause_ the DAG on [WTMO](https://workflow.telemetry.mozilla.org/home)

## External task dependencies are managed via `ExternalTaskSensor`s

Tasks are distributed across different Airflow DAGs. Usually, each DAG contains tasks that are closely related to a specific use case or for generating a set of related datasets. In many cases, tasks depend on other tasks that are running as part of a different DAG. For example, a lot of tasks depend on the [`copy_deduplicate_main_ping`](https://github.com/mozilla/telemetry-airflow/blob/0ba2b5631f079fa90fe07467021fab0f9cfc7366/dags/copy_deduplicate.py#L116) task.

External upstream dependencies are expressed using [`ExternalTaskSensor`s](https://airflow.apache.org/docs/apache-airflow/1.10.3/_api/airflow/sensors/external_task_sensor/index.html). These sensors ensure that the external upstream task is finished before the job that depends on that upstream task is executed. These sensors are usually defined like:

```python
wait_for_bq_events = ExternalTaskSensor(
    task_id="wait_for_bq_events",       # name of this wait task as it will appear in the UI
    external_dag_id="copy_deduplicate", # name of the external DAG
    external_task_id="bq_main_events",  # name of the external task
    execution_delta=timedelta(hours=3), # delta based on differences in schedule between upstream DAG and current DAG
    mode="reschedule",                  # use mode "reschedule" to unblock slots while waiting on upstream task to finish
    allowed_states=ALLOWED_STATES,      # pre-defined success states
    failed_states=FAILED_STATES,        # pre-defined failure states
    pool="DATA_ENG_EXTERNALTASKSENSOR", # this slot pool is used for task sensors
    email_on_retry=False,
    dag=dag,
)

some_local_task.set_upstream(wait_for_bq_events)
```

It is important to note that the `execution_delta` needs to be set correctly depending on the time difference between the upstream DAG schedule and the schedule of the downstream DAG. If the `execution_delta` is not set correctly, downstream tasks will wait indefinitely without ever getting executed.

While upstream dependencies are automatically determined between generated DAGs in bigquery-etl, if there are dependencies between DAGs in telemetry-airflow and bigquery-etl, then these dependencies need to be either added manually to the DAG definition or to the scheduling metadata of the scheduled query.

## Downstream dependencies are managed via `ExternalTaskMarker`s

[`ExternalTaskMarker`s](https://airflow.apache.org/docs/apache-airflow-providers-standard/stable/sensors/external_task_sensor.html#externaltaskmarker) are used to indicate all downstream dependencies to a task. Whenever the task is cleared with _Downstream Recursive_ selected, then all downstream tasks will get cleared automatically. This is extremely useful when running backfill of Airflow tasks. When clearing the tasks, a pop-up will show all the downstream tasks that will get cleared. In case a task should be cleared without its downstream dependencies running as well, deselect the _Downstream Recursive_ option.

`ExternalTaskMarker`s are generally wrapped into a `TaskGroup` and defined like:

```python
with TaskGroup('copy_deduplicate_all_external') as copy_deduplicate_all_external:
    ExternalTaskMarker(
        task_id="bhr_collection__wait_for_bhr_ping",    # name of task marker task
        external_dag_id="bhr_collection",               # external downstream DAG
        external_task_id="wait_for_bhr_ping",           # external downstream task ID
        execution_date="{{ execution_date.replace(hour=5, minute=0).isoformat() }}",    # execution date calculated based on time differences in task schedules
    )
```

Upstream dependencies are automatically determined between generated DAGs in bigquery-etl. If there are dependencies between DAGs in telemetry-airflow and bigquery-etl, then these dependencies need to be either added manually to the DAG definition or to the scheduling metadata of the scheduled query.

## The DAG schedules are selected based on schedules of upstream dependencies

The `schedule_interval` of a DAG should be set to a time that ensures that all upstream dependencies have likely finished before tasks in the DAG get executed. Airflow will send an email notification every time a task needs to be rescheduled due to upstream dependencies not having finished. To reduce the amount of notifications and avoid delays due to rescheduled tasks, the `schedule_interval` should be set based on when upstream tasks have finished.

## DAG will be scheduled for one `schedule_interval` after the `start_date`

The DAG will not run at the first available time after the `start_date` per its configured scheduled, but rather will wait for the `scheduled_interval` time to elapse after the `start_date`. For example, if the `schedule_interval` specifies a daily run, then the run starting on `2023-04-18` will trigger after `2023-04-18 23:59`. See the [Airflow docs](https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/dag-run.html#data-interval) for more info.

## Airflow triage

To detect broken or stuck tasks, we set up an [Airflow triage process](https://mana.mozilla.org/wiki/display/DATA/Airflow+Triage+Process) that notifies tasks owners of problems with their Airflow tasks. Generally, DAGs are checked for failures or stuck tasks on a daily basis and problems are reported on [Bugzilla](https://bugzilla.mozilla.org/buglist.cgi?query_format=advanced&bug_status=UNCONFIRMED&bug_status=NEW&bug_status=ASSIGNED&bug_status=REOPENED&bug_status=RESOLVED&bug_status=VERIFIED&bug_status=CLOSED&status_whiteboard=%5Bairflow-triage%5D%20&classification=Client%20Software&classification=Developer%20Infrastructure&classification=Components&classification=Server%20Software&classification=Other&resolution=---&resolution=FIXED&resolution=INVALID&resolution=WONTFIX&resolution=INACTIVE&resolution=DUPLICATE&resolution=WORKSFORME&resolution=INCOMPLETE&resolution=SUPPORT&resolution=EXPIRED&resolution=MOVED&status_whiteboard_type=allwordssubstr&list_id=16121716).

In case of a failure and after merging the solution to the problem, clear the logs for the failing task to allow the DAG to run again.

## Testing Airflow DAGs

A guide on how to set up Airflow locally and test Airflow DAGs is available [here](https://github.com/mozilla/telemetry-airflow#testing).
