# Accessing BigQuery

## Table of Contents
<!-- toc -->

## Interfaces

You can access BigQuery datasets and tables by selecting any of the following methods:

- [re:dash](./querying.md#from-redash)
- [GCP BigQuery Console](./querying.md#gcp-bigquery-console)
    - For advanced use cases including managing query outputs, table management. Requires GCP access to be granted by Data Operations.
- [GCP BigQuery API Access](./querying.md#gcp-bigquery-api-access)
    - For advanced use cases including automated workloads, ETL, [BigQuery Storage API](https://cloud.google.com/bigquery/docs/reference/storage/). Requires GCP access to be granted by Data Operations.
    - Allows access to BigQuery via [`bq` command-line tool](https://cloud.google.com/bigquery/docs/bq-command-line-tool)
- [Spark](./querying.md#from-spark)
    - [Databricks](./querying.md#on-databricks)
    - [Dataproc](./querying.md#on-dataproc)
- [Colaboratory](./querying.md#from-colaboratory)

Note that with the exception of Redash, all methods require access to be provisioned (see the next section).

## Access Request

For access to BigQuery when using the GCP Console and API, [file a bug](https://bugzilla.mozilla.org/enter_bug.cgi?assigned_to=jthomas%40mozilla.com&bug_file_loc=https%3A%2F%2Fmana.mozilla.org%2Fwiki%2Fx%2FiIPeB&bug_ignored=0&bug_severity=normal&bug_status=NEW&bug_type=task&cf_fx_iteration=---&cf_fx_points=---&comment=Please%20grant%20me%20access%20to%20the%20BigQuery%20GCP%20console%20and%20API%20Access.%20I%20work%20on%20%3Cteam%3E.%0D%0A%0D%0AMy%20mozilla.com%20ldap%20login%20is%20%3Cyour%20ldap%20login%3E%40mozilla.com.&component=Operations&contenttypemethod=list&contenttypeselection=text%2Fplain&defined_groups=1&flag_type-4=X&flag_type-607=X&flag_type-800=X&flag_type-803=X&flag_type-936=X&form_name=enter_bug&maketemplate=Remember%20values%20as%20bookmarkable%20template&op_sys=Unspecified&priority=--&product=Data%20Platform%20and%20Tools&qa_contact=jthomas%40mozilla.com&rep_platform=Unspecified&short_desc=BigQuery%20GCP%20Console%20and%20API%20Access%20for%20%3Cyour%20ldap%20login%3E%40mozilla.com&target_milestone=---&version=unspecified). As part of this request we will add you to the appropriate Google Groups and provision a GCP Service Account.

## From re:dash

All Mozilla users can access BigQuery using [re:dash](https://sql.telemetry.mozilla.org/) through the following Data Sources:
- `Telemetry (BigQuery)`
- `Telemetry Search (BigQuery)`
    - This group is restricted to users in the re:dash `search` group.

Access via re:dash is read-only. You cannot create views or tables using re:dash.

## GCP BigQuery Console

- File a [bug](#access-request) with Data Operations for access to GCP Console.
- Visit [GCP BigQuery Console](https://console.cloud.google.com/bigquery)
- Switch to the project provided to you during your access request e.g `moz-fx-data-bq-<team-name>`

See [Using the BigQuery web UI in the GCP Console](https://cloud.google.com/bigquery/docs/bigquery-web-ui) for more details.

## GCP BigQuery API Access

- File a [bug](#access-request) with Data Operations for access to GCP BigQuery API Access.

You can locate a list of supported BigQuery client libraries [here](https://cloud.google.com/bigquery/docs/reference/libraries).

Detailed REST reference can be found [here](https://cloud.google.com/bigquery/docs/reference/rest/).

## From `bq` Command-line Tool

- Install the [GCP SDK](https://cloud.google.com/sdk/)
- Authorize `gcloud` with either your user account or provisioned service account. See documentation [here](https://cloud.google.com/sdk/docs/authorizing).
    - `gcloud auth login`
- Set your google project to your team project
    - `gcloud config set project moz-fx-data-bq-<team-name>`
    - project name will be provided for you when your account is provisioned.

### `bq` Examples
List tables and views in a BigQuery dataset
``` bash
bq ls moz-fx-data-derived-datasets:telemetry
```
Query a table or view
 ``` bash
 bq query --nouse_legacy_sql 'select count(*) from `moz-fx-data-derived-datasets.telemetry.main` where submission_date = "2019-08-22" LIMIT 10'
 ```

Additional examples and documentation can be found [here](https://cloud.google.com/bigquery/docs/bq-command-line-tool).

### From client SDKs

Client SDKs for various programming languages do not access credentials the
same way as the `gcloud` and `bq` command-line tools. The client SDKs
generally assume that the machine is configured with a service account and
will look for JSON-based credentials in several well-known locations rather
than looking for user credentials.

If you have service account credentials, you can point client SDKs at them
by setting:

```
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/creds.json
```

If you do not have appropriate service account credentials, but your GCP user
account has sufficient access, you can have your user credentials mimic a
service account by running:

```
gcloud auth application-default login
```

Once you've followed the browser flow to grant access, you should be able to,
for example, access BigQuery from Python:

```
pip install google-cloud-bigquery
python -c 'from google.cloud import bigquery; print([d.dataset_id for d in bigquery.Client().list_datasets()])'
```

## From Spark
We recommend the [Storage API Connector](https://github.com/GoogleCloudPlatform/spark-bigquery-connector) for accessing
BigQuery tables in Spark as it is the most modern and actively developed connector. It works well with the BigQuery
client library which is useful if you need to run arbitrary SQL queries (see example Databricks notebook) and load their
results into Spark.

### On Databricks
The `shared_serverless_python3` cluster is configured with shared default GCP credentials that are automatically picked
up by BigQuery client libraries. It also has the Storage API Connector library added as seen in the example
[Python notebook](https://dbc-caf9527b-e073.cloud.databricks.com/#notebook/141939).

### On Dataproc
Dataproc is Google's managed Spark cluster service. Accessing BigQuery from there will be faster than from Databricks
because it does not involve cross-cloud data transfers.

You can spin up a Dataproc cluster with Jupyter using the following command. Insert your values for `cluster-name`, `bucket-name`, and `project-id` there. Your notebooks are stored in Cloud Storage under `gs://bucket-name/notebooks/jupyter`:
```bash
gcloud beta dataproc clusters create cluster-name \
    --optional-components=ANACONDA,JUPYTER \
    --image-version=1.4 \
    --enable-component-gateway \
    --properties=^#^spark:spark.jars=gs://spark-lib/bigquery/spark-bigquery-latest.jar \
    --num-workers=3 \
    --max-idle=3h \
    --bucket bucket-name \
    --region=us-west1 \
    --project project-id
```

Jupyter URL can be retrieved with the following command:
```bash
gcloud beta dataproc clusters describe cluster-name --region=us-west1 --project project-id | grep Jupyter
```

After you've finished your work, it's a good practice to delete your cluster:
```bash
gcloud beta dataproc clusters delete cluster-name --region=us-west1 --project project-id --quiet
```

## From Colaboratory
[Colaboratory](https://colab.research.google.com) is Jupyter notebook environment, managed by Google and running in the cloud. Notebooks are stored in Google Drive and can be shared in a similar way to Google Docs.

Colaboratory can be used to easily access BigQuery and perform interactive analyses. See [`Telemetry Hello World` notebook](https://colab.research.google.com/drive/1uXmrPnqzDATiCVH2RNJKD8obIZuofFHx).

Note: this is very similar to [API Access](#gcp-bigquery-api-access), so you will need access to your team's GCP project - file a request as described [above](#access-request).
