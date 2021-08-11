# Using the Glean Dictionary

The Glean Dictionary is a web-based tool that allows you to look up information on all the metrics[^1] defined in applications built using [Glean], Mozilla's next-generation Telemetry SDK.
Like Glean itself, it is built using lessons learned in the implementation of what came before (the [probe dictionary] in this case).
In particular, the Glean Dictionary is designed to be more accessible to those without deep knowledge of instrumentation and/or data platform internals.

## How to use

You can visit the Glean Dictionary at [`dictionary.telemetry.mozilla.org`](https://dictionary.telemetry.mozilla.org/).
As its content is generated entirely from publicly available source code, there is no access control.

From the top level, you can select an application you want to view the metrics for.
After doing so, you can search for metrics by name (e.g.: `addons.enabled_addons`), type (e.g.: `string_list`), or tags (e.g. `WebExtensions`).

After selecting a metric, you can get more information on it including a reference to its definition in the source code as well as information on how to get the data submitted by this probe in some of our data tools like [STMO], [Looker], and [GLAM].

## Common Questions

### How can I go from a metric to querying it in BigQuery?

Underneath the metric definition, look for the section marked "access". This should tell you the BigQuery table where the data for the metric is stored, along with the column name needed to access it.

For several examples of this along with a more complete explanation, see [Accessing Glean Data].

[^1]: Note that Glean refers to "probes" (in the old-school Firefox parlance) as "metrics".

[glean]: ../../concepts/glean/glean.md
[probe dictionary]: ./probe_dictionary.md
[stmo]: ../../introduction/tools.md#sqltelemetrymozillaorg-stmo
[looker]: ../../introduction/tools.md#looker
[glam]: ../../introduction/tools.md#glean-aggregated-metrics-dashboard-glam
[accessing glean data]: ../accessing_glean_data.md
