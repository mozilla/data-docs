# Introduction to Operational Monitoring

Operational monitoring is a general term that refers to monitoring the health of software.

However, Mozilla's internal Operational Monitoring tooling supports a couple of specific use cases:

1. Monitoring build over build. This is typically for Nightly where one build may contain changes that a previous build doesn't and we want to see if those changes affected certain metrics.
2. Monitoring by submission date over time. This is helpful for a rollout in Release for example, where we want to make sure there are no performance or stability regressions over time as a new build rolls out.

The monitoring dashboards produced for these use cases are available in [Looker](https://mozilla.cloud.looker.com/folders/494).

Access to the Looker Operational Monitoring dashboards is currently limited to Mozilla employees and designated contributors. For more information, see [gaining access](../concepts/gaining_access.md).

## How to use Operational Monitoring

An operational monitoring project is defined using a project definition JSON file in combination with 2 other JSON files.

In order to create a new project to be monitored:

1. A new `<project_name>.json` file must be added to the `operational_monitoring` GCS bucket at `gs://operational_monitoring/projects`. This bucket is currently inside the GCP project `emtwo-252813`.
2. `probes.json` and `dimensions.json` must exist at `gs://operational_monitoring`.

Once a project is defined, a dashboard will be generated for it within the next 24 hours on the next ETL run.

Examples of each file can be found below:

#### `dimensions.json`

Each key in `dimensions.json` is the name of a dimension that will appear as a dropdown in the generated dashboards and can be referenced in the `<project_name>.json` file below.

```
{
  "cores_count": {
    "source": ["mozdata.telemetry.main_nightly"],
    "sql": "environment.system.cpu.cores"
  },
  "os": {
    "source": ["mozdata.telemetry.main_nightly", "mozdata.telemetry.crash"],
    "sql": "normalized_os"
  }
  ...
}
```

For each dimension, the following fields exist:

- `source`: The BigQuery table name to be queried.
- `sql`: The SQL used in the `select` clause for this probe.

#### `probes.json`

Each key in `probes.json` is the name of a probe that will be used in the generated dashboards and can be referenced in the `<project_name>.json` file below.

```
{
  "CONTENT_SHUTDOWN_CRASHES": {
    "source": "mozdata.telemetry.crash",
    "category": "stability",
    "type": "scalar",
    "sql": "IF(REGEXP_CONTAINS(payload.process_type, 'content') AND REGEXP_CONTAINS(payload.metadata.ipc_channel_error, 'ShutDownKill'), 1, 0)"
  },
  "CONTENT_PROCESS_COUNT": {
    "source": "mozdata.telemetry.main_nightly",
    "category": "performance",
    "type": "histogram",
    "sql": "payload.histograms.content_process_count"
  },
 ...
}
```

For each probe, the following fields exist:

- `source`: The BigQuery table name to be queried.
- `category`: This can be any string value. It's currently not being used but in the future, this could be used to visually group different probes by category.
- `type`: This is used to determine the method of aggregation to be applied.
- `sql`: The SQL used in the `select` clause for this probe.

#### `<project_name>.json`

Each project file has an associated Looker dashboard that is generated. Each item under `probes` will be displayed as one tile/graph in the dashboard.

```
{
  "name": "Fission Release Rollout",
  "slug": "bug-1732206-rollout-fission-release-rollout-release-94-95",
  "channel": "release",
  "boolean_pref": "environment.settings.fission_enabled",
  "xaxis": "submission_date",
  "start_date": "2021-11-09",
  "analysis": [
    {
      "source": "mozdata.telemetry.main_1pct",
      "dimensions": ["cores_count", "os"],
      "probes": [
        "CONTENT_PROCESS_COUNT",
      ]
    }, {
      "source": "mozdata.telemetry.crash",
      "dimensions": ["cores_count", "os"],
      "probes": [
        "CONTENT_SHUTDOWN_CRASHES",
      ]
    }
  ]
}
```

- `name`: Name that will be used as the generated Looker dashboard title.
- `slug`: The slug associated with the rollout that is being monitored.
- `channel`: `release`, `beta`, or `nightly`. The channel the rollout is running in.
- `boolean_pref`: A SQL snippet that results in a boolean representing whether a user is included in the rollout or not (note: if this is not included, the slug is used to check instead).
- `xaxis`: `submission_date` or `build_id`. specifies the type of monitoring desired as described above.
- `start_date`: `yyyy-mm-dd`, specifies the oldest submission date or build id to be processed (where build id is cast to date). If not set, defaults to the previous 30 days.
- `analysis`: An array of objects with the fields `source`, `dimensions`, and `probes` where each object represents data that will be pulled out from a different source.
  - `source`: The BigQuery table name to be queried.
  - `dimensions`: The dimensions of interest, referenced from `dimensions.json`.
  - `probes`: The probes of interest, referenced from `probes.json`

## Going Deeper

To get a deeper understanding of what happens under the hood, please see the [developer documentation](https://github.com/mozilla/bigquery-etl/blob/main/bigquery_etl/operational_monitoring/README.md).

## Getting Help

If you have further questions, please reach out on the #GLAM slack channel.
