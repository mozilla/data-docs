The [update ping](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/update-ping.html)
is sent from Firefox Desktop when a browser update is ready to be applied and after it was correctly applied.
It contains the build information and the update blob information, in addition to some information about the
user environment.

#### Contents

The table contains one row for each ping. Each column represents one field from the update ping payload, though only a subset of all fields are included.

#### Accessing the Data

Query the `telemetry.update` view in BigQuery as in the [example query in STMO](https://sql.telemetry.mozilla.org/queries/31267#table).
