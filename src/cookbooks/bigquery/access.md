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
bq query --nouse_legacy_sql 'select count(*) from mozdata.telemetry.main where date(submission_timestamp) = "2019-08-22" and normalized_channel="nightly"'
```

Additional examples and documentation can be found [in the BigQuery command-line reference](https://cloud.google.com/bigquery/docs/bq-command-line-tool).

### API Access

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

[Colaboratory](https://colab.research.google.com) (Colab) is Jupyter notebook environment, managed by Google and running in the cloud. Notebooks are stored in Google Drive and can be shared in a similar way to Google Docs.

Colab can be used to easily access BigQuery and perform analyses. See the [`Telemetry Hello World` notebook](https://colab.research.google.com/drive/1uXmrPnqzDATiCVH2RNJKD8obIZuofFHx) for an interactive example. Under the hood, it uses the BigQuery API to read and write to BigQuery tables, so access needs to be explicitly provisioned.

### AI Platform Notebooks

[AI Platform Notebooks](https://cloud.google.com/ai-platform/notebooks/docs) is a managed JupyterLab service running on GCP. It gives you full control over the machine where your notebooks are running - you can install your own libraries and choose machine size depending on your needs.

To start, go to [GCP console](https://console.cloud.google.com) and make sure you are in the correct project - most likely this will be your team project. Then navigate to the Notebooks page in the sidebar under AI Platform > Notebooks ([direct link](https://console.cloud.google.com/ai-platform/notebooks/list/instances)). There you can create new notebook server instances and connect to them (when your instance is ready, you'll see an `Open JupyterLab` button).

Please note that by default JupyterLab saves notebook files only locally, so they are lost if your instance is deleted. To make sure you don't lose your work, either push your files to a Git repository (via a pre-installed Git extension) or upload them to GCS (using `gsutil` command in a terminal session).

#### Notebooks Access to workgroup-confidential Datasets

If you are a member of a restricted access workgroup, you can provision AI notebooks in the [`mozdata GCP project`](https://console.cloud.google.com/vertex-ai/workbench/list/instances?project=mozdata&supportedpurview=project) that can read workgroup-confidential data.

> **⚠** You must provision AI notebooks in `mozdata` using a nonstandard service account specific to your workgroup, see below.

When you create a notebook server, under "Advanced Options" / "Permissions", deselect "Use Compute Engine Default Service Account" and replace it with the service account associated with your workgroup. You may need to type this service account manually as it will not be available from a drop-down menu to all users. The ID of the service account matches the following pattern:

`WORKGROUP-SUBGROUP@mozdata.iam.gserviceaccount.com`

For example, if you are member of `workgroup:search-terms/aggregated`, use `search-terms-aggregated@mozdata.iam.gserviceaccount.com`.

This notebook server should have access to any restricted access datasets that are accessible to `workgroup:search-terms/aggregated`. Additionally, this notebooks server will not have write access to the standard `mozdata.analysis` dataset, but will instead have write access to a workgroup-specific dataset that looks like the following:

`mozdata.WORKGROUP_SUBGROUP_analysis`

In the example above this maps to `mozdata.search_terms_aggregated_analysis`.

## BigQuery Access Request

> **⚠**  Access to BigQuery via the `mozdata` GCP project is granted to Mozilla Staff by default; only file an access request if you need other specific access such as via a teams project

For access to BigQuery using projects other than `mozdata`, [file a bug (requires access to Mozilla Jira)](https://mozilla-hub.atlassian.net/secure/CreateIssueDetails!init.jspa?pid=10058&issuetype=10007&priority=3&customfield_10014=DSRE-87&summary=BigQuery%20GCP%20Console%20and%20API%20Access%20for%20YOUR_EMAIL_HERE&description=My%20request%20information%0A%3D%3D%3D%3D%3D%3D%3D%3D%0Amozilla.com%20ldap%20login%3A%0Ateam%3A%0Aaccess%20required%3A%20BigQuery%20GCP%20console%20and%20API%20Access%3B%20ENTER%20OTHER%20ACCESS%20REQUESTS%20HERE%0A%0APost%20request%0A%3D%3D%3D%3D%3D%3D%3D%3D%0ASee%20GCP%20console%20and%20other%20access%20methods%20docs%20here%3A%20https%3A%2F%2Fdocs.telemetry.mozilla.org%2Fcookbooks%2Fbigquery).
If you require access to AI Notebooks or Dataproc, please specify in the bug and a team project will be provisioned for you.
