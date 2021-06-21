# Data and experiments

## Nimbus

Nimbus is Firefox's cross-platform experimentation tool.

You can learn more about Nimbus at <https://experimenter.info>.

[Jetstream](../datasets/jetstream.md) analyzes Nimbus experiments. Results appear in [Experimenter](https://experimenter.services.mozilla.com).

Nimbus experiments are [represented in telemetry](../datasets/experiment_telemetry.md) the same way Normandy experiments are.

## Normandy

Normandy is an experimentation platform for Firefox desktop.

[Jetstream](../datasets/jetstream.md) also analyzes Normandy experiments, although the results do not appear in the experiment console.

Normandy experiments are [represented in telemetry](../datasets/experiment_telemetry.md) the same way Nimbus experiments are.

## Heartbeat

[Heartbeat](../datasets/heartbeat.md) is a survey mechanism controlled with Normandy.

## Monitoring

We publish [aggregate datasets for experiment monitoring](../datasets/experiment_monitoring.md) to BigQuery.

## Experiment-specific telemetry

Sometimes experiments deploy custom telemetry that is not well-documented elsewhere.
We maintain [a list](../datasets/dynamic_telemetry.md) of these datasets.
