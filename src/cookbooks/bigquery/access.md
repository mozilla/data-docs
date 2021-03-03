# Accessing BigQuery

There are many methods that you can use to access BigQuery: both interactive and programmatic. This document provides some basic information and pointers on how to get started with each.

It is worth pointing out that all internal access to BigQuery is logged and periodically audited by Data Engineering and Operations for cost and other purposes.

## Table of Contents

<!-- toc -->

## Interfaces

### STMO (`sql.telemetry.mozilla.org`)

> **⚠** Queries made from STMO are read-only: you cannot create views or tables.

All users with access to [STMO](../../tools/stmo.md) can access BigQuery using the following data sources:

- `Telemetry (BigQuery)`
- `Telemetry Search (BigQuery)`

### BigQuery Console

> **⚠** This method requires [BigQuery Access](#bigquery-access-request) to be provisioned.

The BigQuery console is similar to STMO, but allows write access to views and tables. Some
people also prefer its user interface, though note that results that you get from it can
only be shared with others who also have BigQuery access provisioned.

- Visit [GCP BigQuery Console `mozdata`](https://console.cloud.google.com/bigquery?project=mozdata)
- Use `mozdata` or switch to the project provided to you during your access request e.g `moz-fx-data-bq-<team-name>`
- Write and run your queries

Note that if you are trying to query telemetry datasets from a team-specific project,
you will need to explicitly specify
the project (`mozdata`) that the view lives in, since you're querying from a different one. For example:

```sql
SELECT
  client_id
FROM
  mozdata.telemetry.main
WHERE
  DATE(submission_timestamp) = '2020-04-20'
  AND sample_id = 42
  AND application.channel='nightly'
```

For more details, see [Google's Documentation on the GCP Console](https://cloud.google.com/bigquery/docs/bigquery-web-ui).

### Using the `bq` Command-Line Tool

> **⚠** This method requires [BigQuery Access](#bigquery-access-request) to be provisioned.

Steps to use:

- Install the [GCP SDK](https://cloud.google.com/sdk/)
- Authorize `gcloud` with either your user account or provisioned service account. See documentation [here](https://cloud.google.com/sdk/docs/authorizing).
  - `gcloud auth login`
- Set your google project to `mozdata`
  - `gcloud config set project mozdata`
- Set your google project to your team project if you were given one during your access request.
  - `gcloud config set project moz-fx-data-bq-<team-name>`

Once configured, you can now use the `bq` command-line client. The following example
lists the tables and views in a BigQuery dataset:

```bash
bq ls mozdata:telemetry
```

And here's another which gets the count of entries in `telemetry.main` on `2019-08-22` in the nightly channel:

```bash
bq query --nouse_legacy_sql 'select count(*) from mozdata.telemetry.main where submission_date = "2019-08-22" and normalized_channel="nightly"'
```

Additional examples and documentation can be found [in the BigQuery command-line reference](https://cloud.google.com/bigquery/docs/bq-command-line-tool).

### API Access

> **⚠** This method requires [BigQuery Access](#bigquery-access-request) to be provisioned.

For advanced use cases involving programmatic access -- including automated workloads, ETL, [BigQuery Storage API](https://cloud.google.com/bigquery/docs/reference/storage/).

You can locate a list of supported BigQuery client libraries [here](https://cloud.google.com/bigquery/docs/reference/libraries).

Although you typically want to use a client library, Google also provides a [detailed reference of their underlying REST API](https://cloud.google.com/bigquery/docs/reference/rest/).

#### Service Accounts

Client SDKs do not access credentials the same way as the `gcloud` and `bq`
command-line tools. The client SDKs generally assume that the machine is configured with
a service account and looks for JSON-based credentials in several well-known locations
rather than looking for user credentials.

If you have service account credentials, you can point client SDKs at them
by setting:

```bash
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/creds.json
```

If you do not have appropriate service account credentials, but your GCP user
account has sufficient access, you can have your user credentials mimic a
service account by running:

```bash
gcloud auth application-default login
```

Once you've followed the browser flow to grant access, you should be able to,
for example, access BigQuery from Python:

```bash
pip install google-cloud-bigquery
python -c 'from google.cloud import bigquery; print([d.dataset_id for d in bigquery.Client().list_datasets()])'
```

### Spark

[Apache Spark](https://spark.apache.org/) is a data processing engine designed to be fast and easy to use. There are several methods you can use to access BigQuery via Spark, depending on your needs. See [Custom Analysis with Spark](../../tools/spark.md) for more information and examples.

### Colaboratory

> **⚠** This method requires [BigQuery Access](#bigquery-access-request) to be provisioned.

[Colaboratory](https://colab.research.google.com) (Colab) is Jupyter notebook environment, managed by Google and running in the cloud. Notebooks are stored in Google Drive and can be shared in a similar way to Google Docs.

Colab can be used to easily access BigQuery and perform analyses. See the [`Telemetry Hello World` notebook](https://colab.research.google.com/drive/1uXmrPnqzDATiCVH2RNJKD8obIZuofFHx) for an interactive example. Under the hood, it uses the BigQuery API to read and write to BigQuery tables, so access needs to be explicitly provisioned.

### AI Platform Notebooks

> **⚠** This method requires [BigQuery Access](#bigquery-access-request) to be provisioned.

[AI Platform Notebooks](https://cloud.google.com/ai-platform/notebooks/docs) is a managed JupyterLab service running on GCP. It gives you full control over the machine where your notebooks are running - you can install your own libraries and choose machine size depending on your needs.

To start, go to [GCP console](https://console.cloud.google.com) and make sure you are in the correct project - most likely this will be your team project. Then navigate to the Notebooks page in the sidebar under AI Platform > Notebooks ([direct link](https://console.cloud.google.com/ai-platform/notebooks/list/instances)). There you can create new notebook server instances and connect to them (when your instance is ready, you'll see an `Open JupyterLab` button).

Please note that by default JupyterLab saves notebook files only locally, so they are lost if your instance is deleted. To make sure you don't lose your work, either push your files to a Git repository (via a pre-installed Git extension) or upload them to GCS (using `gsutil` command in a terminal session).

## BigQuery Access Request

For access to BigQuery when using the GCP Console and API, [file a bug](https://bugzilla.mozilla.org/enter_bug.cgi?assigned_to=jthomas%40mozilla.com&bug_file_loc=https%3A%2F%2Fmana.mozilla.org%2Fwiki%2Fx%2FiIPeB&bug_ignored=0&bug_severity=normal&bug_status=NEW&bug_type=task&cf_fx_iteration=---&cf_fx_points=---&comment=Please%20grant%20me%20access%20to%20the%20BigQuery%20GCP%20console%20and%20API%20Access.%20I%20work%20on%20%3Cteam%3E.%0D%0A%0D%0AMy%20mozilla.com%20ldap%20login%20is%20%3Cyour%20ldap%20login%3E%40mozilla.com.&component=Operations&contenttypemethod=list&contenttypeselection=text%2Fplain&defined_groups=1&flag_type-4=X&flag_type-607=X&flag_type-800=X&flag_type-803=X&flag_type-936=X&form_name=enter_bug&maketemplate=Remember%20values%20as%20bookmarkable%20template&op_sys=Unspecified&priority=--&product=Data%20Platform%20and%20Tools&qa_contact=jthomas%40mozilla.com&rep_platform=Unspecified&short_desc=BigQuery%20GCP%20Console%20and%20API%20Access%20for%20%3Cyour%20ldap%20login%3E%40mozilla.com&target_milestone=---&version=unspecified).
You will be added to the appropriate Google Groups to access the `mozdata` GCP project.
If you require access to AI Notebooks or Dataproc, please specify in the bug and a team project will be provisioned for you.
