The `error_aggregates_v2` table represents counts of errors counted from main and crash
pings, aggregated every 5 minutes. It is the dataset backing the main [mission
control](https://data-missioncontrol.dev.mozaws.net/) view, but may also be queried
independently.

#### Contents

The `error_aggregates_v2` table contains counts of various error measures (for
example: crashes, "the slow script dialog showing"), aggregated across each
unique set of dimensions (for example: channel, operating system) every 5
minutes. You can get an aggregated count for any particular set of dimensions
by summing using SQL.

##### Experiment unpacking

It's important to note that when this dataset is written, pings from clients participating in an experiment
are aggregated on the `experiment_id` and `experiment_branch` dimensions corresponding to what experiment and branch
they are participating in. However, they are also aggregated with the rest of the population where the values of
these dimensions are null.
Therefore care must be taken when writing aggregating queries over the whole population - in these cases one needs to
filter for `experiment_id is null` and `experiment_branch is null` in order to not double-count pings from experiments.

#### Accessing the data

You can access the data via STMO. Choose `Athena` and then select the
`telemetry.error_aggregates_v2` table.

#### Further Reading

The code responsible for generating this dataset is [here](https://github.com/mozilla/telemetry-streaming/blob/master/src/main/scala/com/mozilla/telemetry/streaming/ErrorAggregator.scala).
