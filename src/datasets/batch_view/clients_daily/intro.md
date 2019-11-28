The `clients_daily` table is intended as the first stop for asking questions
about how people use Firefox. It should be easy to answer simple questions.
Each row in the table is a (`client_id`, `submission_date`) and contains a
number of aggregates about that day's activity.

#### Contents

Many questions about Firefox take the form "What did clients with
characteristics X, Y, and Z do during the period S to E?" The
`clients_daily` table is aimed at answer those questions.

#### Accessing the Data

The `clients_daily` table is accessible through re:dash using the
`Telemetry (BigQuery)` data source.

Here's an [example query](https://sql.telemetry.mozilla.org/queries/23746#61771).
