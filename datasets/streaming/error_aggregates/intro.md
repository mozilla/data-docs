The `error_aggregates` table represents counts of errors counted from main and crash
pings, aggregated every 5 minutes. It is the dataset backing the main [mission
control](https://data-missioncontrol.dev.mozaws.net/) view, but may also be queried
independently.

#### Contents

The `error_aggregates` table contains counts of various error measures (for
example: crashes, "the slow script dialog showing"), aggregated across each
unique set of dimensions (for example: channel, operating system) every 5
minutes. You can get an aggregated count for any particular set of dimensions
by summing using SQL.

#### Accessing the data

You can access the data via re:dash. Choose `Athena` and then select the
`telemetry.error_aggregates` table.

#### Further Reading

The code responsible for generating this dataset is [here](https://github.com/mozilla/telemetry-streaming/blob/master/src/main/scala/com/mozilla/telemetry/streaming/ErrorAggregator.scala).