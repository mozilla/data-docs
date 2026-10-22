# Collecting New Data

## Guidelines

For information about what sorts of data may be collected,
and for information on getting a data collection request reviewed,
please read the [Data Collection Guidelines.][data_collection]
The data review request and review templates are now maintained as the source of truth in the
[mozilla/data-review GitHub repository](https://github.com/mozilla/data-review).

## Mechanics

Glean is the standard telemetry platform required for all new Mozilla products. See
[Adding Glean to your project](https://mozilla.github.io/glean/book/user/adding-glean-to-your-project.html)
for the mechanics of instrumenting new data collection with Glean.

Legacy Telemetry APIs are deprecated for new instrumentation; for background on the
legacy mechanism, see
[Adding a new Telemetry probe](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/start/adding-a-new-probe.html) (deprecated).

For non-Telemetry data collection, we have a mechanism for streamlining
ingestion of structured (JSON) data that utilizes the same underlying
infrastructure. See [this cookbook](../cookbooks/new_ping.md) for details on using it.

[data_collection]: https://wiki.mozilla.org/Firefox/Data_Collection
