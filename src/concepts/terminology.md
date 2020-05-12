# Terminology

You may want to familiarize yourself with a few terms before you start reading the documentation.

* **Analyst**: Anyone who performs an analysis.
  This is more general than referring to a **data scientist**.
* **Ping**: A message that is sent to Mozilla's telemetry servers. Generally speaking, a ping is received from Firefox and includes information about the browser state, user actions, etc.
([more details](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/common-ping.html)). However, a ping can also be received from other Mozilla products or services
* **Dataset**: A set of data that include ping data, derived datasets, etc. It can also refer to a [BigQuery dataset](https://cloud.google.com/bigquery/docs/datasets-intro), which is a container for tables.
* **Derived Dataset**: A processed dataset, such as `main_summary` or the
  `clients_daily` dataset.
* **Session**: The time period that commences when a Firefox browser starts until the browser shuts down.
* **Subsession**: `Sessions` are split into `subsessions` when a 24-hour threshold is exceeded or an environment change occurs.
([more details](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/concepts/sessions.html?highlight=subsession))