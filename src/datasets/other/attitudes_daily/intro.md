The `attitudes_daily` table is a Telemetry instantiation of user responses to the [Daily Attitudes Survey (DAS)](https://qsurvey.mozilla.com/collab/daily-attitude-survey) over time.
It is joined to `clients_daily` using `client_id` and `submission_date`.

#### Contents

Most Firefox surveys are point-in-time without longitudinal insights.
The DAS is completed by ~300 Firefox users every day, allowing us to measure long term attitudinal trends combined with users' corresponding Telemetry attributes.

#### Accessing the Data

The `attitudes_daily` table is accessible through STMO using the
`Telemetry (BigQuery)` data source.
The full table name is `moz-fx-data-shared-prod.telemetry.attitudes_daily`.

Here's an [example query](https://sql.telemetry.mozilla.org/queries/63937/source#163424).
