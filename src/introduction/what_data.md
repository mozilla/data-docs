# What Data does Mozilla Collect?

The data Mozilla collects can roughly be categorized into three categories: product telemetry, usage logs and website telemetry.

## Product Telemetry

Most of our products, including Firefox, are instrumented to send small JSON packets called "pings" when telemetry is enabled.
Pings include some combination of environment data (e.g., information about operating system and hardware), measurements (e.g., for Firefox, information about the maximum number of open tabs and time spent running in JavaScript garbage collections), and events (indications that something has happened).

Inside Firefox, most Telemetry is collected via a module called "Telemetry".
The details of our ping formats is extensively documented in the Firefox Source Docs under [Toolkit/Telemetry].

In newer products like Firefox for Android, instrumentation is handled by the [Glean SDK], whose design was inspired from what Mozilla learned from the implementation of the Telemetry module and has many benefits.
At some point in the near future, Mozilla plans to replace the Telemetry module with the Glean SDK.
For more information, see [Firefox on Glean (FOG)].

[glean sdk]: ../concepts/glean/glean.md
[toolkit/telemetry]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/index.html
[firefox on glean (fog)]: https://firefox-source-docs.mozilla.org/toolkit/components/glean/index.html

When submissions from our clients hit our end points, ping data is aggregated into ping datasets.
On a daily basis, these ping-level datasets are rolled into derived datasets which are easier to reason about and faster to query.
You can learn more about this in [Guiding Principles for Data Infrastructure].

Both the ping and derived datasets are viewable using tools like GLAM and Looker.
For more information, see [Tools for Data Analysis].

[tools for data analysis]: ./tools.md
[guiding principles for data infrastructure]: ../tools/guiding_principles.md

## Usage Logs

Some of our products, like [Firefox Sync], produce logs on the server when they are used.
As with product telemetry, this data can be helpful for understanding how our products are used (for example, in the case of Firefox sync we can get an idea of how regularly our users use this service)
We strip this data of user identifiers and summarize them into derived datasets which can be queried with either BigQuery or Looker.

[firefox sync]: https://www.mozilla.org/firefox/sync/

## Website Telemetry

Mozilla uses tools like Google Analytics to measure interactions on our web sites like [mozilla.org].
To facilitate comparative analysis with product and usage telemetry, we export much of this data into our BigQuery Data Warehouse, so that it can be queried via Looker and other tools.

[mozilla.org]: https://mozilla.org
