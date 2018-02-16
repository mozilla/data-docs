The `error_aggregates` table represents counts of errors counted from main and crash
pings, aggregated every 5 minutes.

#### Contents

The `error_aggregates` table contains counts of raw counts of various error measures,
aggregated across each unique set of dimensions (for example: channel, operating system).
You can get an aggregated count for any particular set of dimensions by summing using SQL.

#### Accessing the data

You can access the data via re:dash. Choose `Athena` and then select the
`telemetry.error_aggregates` table. Here's an [example query](https://sql.telemetry.mozilla.org/queries/4769/source).

#### Further Reading

The code responsible for generating this dataset is [here](https://github.com/mozilla/telemetry-streaming/blob/master/src/main/scala/com/mozilla/telemetry/streaming/ErrorAggregator.scala).