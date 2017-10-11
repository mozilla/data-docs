The `clients_daily` table is intended as the first stop for asking questions
about how people use Firefox. It should be easy to answer simple questions.
Each row in the table is a (`client_id`, `activity_date`) and contains a
number of aggregates about that day's activity.

#### Contents

Many questions about Firefox take the form "What did clients with
characteristics X, Y, and Z do during the period S to E?" The
`clients_daily` table is aimed at answer those questions.

#### Background and Caveats
The rows in the table are based on **activity date** rather than
**submission date**, so there is a somewhat higher
[processing delay](concepts/analysis_gotchas.html#delays) than for
some other datasets. It is expected that the latest "day" available
in this table is more than one day ago.

#### Accessing the Data

The data is stored as a parquet table in S3 at the following address.
```
s3://telemetry-parquet/clients_daily/v5/
```

The `clients_daily` table is accessible through re:dash using the `Athena`
data source. It is also available via the `Presto` data source, though
`Athena` should be preferred for performance and stability reasons.

Here's an [example query](https://sql.telemetry.mozilla.org/queries/23746#61771).

#### Further Reading

The code responsible for generating this dataset is
[here](https://github.com/mozilla/python_mozetl/tree/master/mozetl/clientsdaily).
