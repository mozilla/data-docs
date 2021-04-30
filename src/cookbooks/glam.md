# Introduction to GLAM

GLAM was built to help Mozillians answer their data questions without needing data analysis or coding skills. GLAM contains a visualization layer meant to answer most “easy” questions about how a probe/metric has changed over build ids and releases.

## The differences between GLAM, GUD, and TMO

There are 3 different telemetry visualization dashboards currently being maintained at Mozilla:

- **[Mozilla Growth & Usage Dashboard (GUD)](https://gud.telemetry.mozilla.org/)** is focused on a relatively small number of high level, derived product metrics about user engagement (e.g. MAU, DAU, retention, etc.)

- **[Glean Aggregated Metrics Dashboard (GLAM)](https://glam.telemetry.mozilla.org/)** is focused on a diverse and plentiful set of probes and data points that engineers capture in code and transmit back from Firefox and other Mozilla products.

- **[The Telemetry Measurement Dashboard (TMO)](https://telemetry.mozilla.org/)** is the predecessor to GLAM (see above) and is still lightly maintained until we are sure that GLAM covers all of its use cases.

## How to use GLAM

You can visit GLAM at [glam.telemetry.mozilla.org](https://glam.telemetry.mozilla.org). As of this writing, Mozilla LDAP credentials are required to access it.

### Front page

![](../assets/GLAM_screenshots/front-page.png)

The front page includes 2 main sections: the search bar and the random probe explorer. Fuzzy tech search is impemented to let users search not only by the probe title, but also by the full description.

GLAM is currently serving data for Firefox Desktop and Firefox for Android.

### Individual probe/metric page

Clicking on a probe/metric name takes you to the individual explorer, where most of the analysis happens. As this page is packed with data, we make sure that it's self-documented as much as possible: every button, surface, menu item, is tooltipped with description and links.

![](../assets/GLAM_screenshots/probe-page.png)

**(1)** The left column shows metadata about the probe/metric: what kind, what channels it's active in, a description, associated bugs with its implementation. As our goal is to make GLAM a self-educating tool, we try to provide as much information as available, and link out to other resources where applicable ([Glean Dictionary](https://dictionary.telemetry.mozilla.org/), Looker, etc.)

**(2)** For convenience, we provide 2 utility features:

- `View SQL Query`: if you want to dig more deeply into the data than the GLAM UI allows, “View SQL Query” parses SQL that can be copied and then pasted into our [STMO Redash instance](https://sql.telemetry.mozilla.org/).
- `Export to JSON`: exports JSON data to be used in Jupyter notebook or similar services.

**(3)** `Time Horizon` lets users choose how much data they want to investigate: week, month, quarter, or all (note that we only keep data from the last 3 versions.)

**(4)** A set of dimensions (qualitative attributes of data) to subset on

**(5)** Probe/metric distribution and percentiles over time:

- `Percentiles` shows the percentitles of the probe over time. To perform analysis, set a reference point by clicking on a target date, then hover along the graph to see the recorded differences. See attached tooltips on the page for more instruction.
- The `compare` violin plot shows the comparison between 2 (vertical) normal distributions
- `Summary` table provides the exact numeric values of the percentiles of the median changes between Build IDs.

**(6)** shows the volume of clients with each given Build ID

## References

### Going deeper

If you have a question that can't be easily answered by the GLAM GUI, you can access the raw GLAM datasets using [`sql.telemetry.mozilla.org`]`(sql.telemetry.mozilla.org).

### Getting help

If you have further questions, please reach out on the #glam slack channel.
