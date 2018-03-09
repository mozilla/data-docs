Mozilla Firefox Data Analysis Tools
-----------------------------------

This is a starting point for making sense of (and gaining access to) all of the
Firefox-related data analysis tools. There are a number of different tools
available, all with their own strengths, tailored to a variety of use cases and
skill sets.

#### [`sql.telemetry.mozilla.org`](stmo.md) (STMO)

The [`sql.telemetry.mozilla.org`](https://sql.telemetry.mozilla.org) (STMO) site
is an instance of the very fine [Re:dash](https://redash.io/) software, allowing
for SQL-based exploratory analysis and visualization / dashboard
construction. Requires (surprise!) familiarity with SQL, and for your data to
be explicitly exposed as an STMO data source. Bugs or feature requests can be
reported in our [issue tracker](https://github.com/mozilla/redash/issues).

#### [`analysis.telemetry.mozilla.org`](spark.md) (ATMO)

The
[`analysis.telemetry.mozilla.org`](https://https://analysis.telemetry.mozilla.org)
(ATMO) site can be used to launch and gain access to virtual machines running
Apache Spark clusters which have been pre-configured with access to the raw data
stored in our long term storage S3 buckets. Spark allows you to use
Python or Scala to perform arbitrary analysis and generate arbitrary
output. Once developed, ATMO can also be used to run recurring Spark jobs
for data transformation, processing, or reporting. Requires Python or Scala
programming skills and knowledge of various data APIs. Learn more by visiting
the [documentation](https://wiki.mozilla.org/Telemetry) or
[tutorials](spark.md).

#### [`telemetry.mozilla.org`](analysis_intro.md) (TMO)

Our [`telemetry.mozilla.org`](https://telemetry.mozilla.org) (TMO) site is the
'venerable standby' of Firefox telemetry analysis tools. It uses aggregate
telemetry data (as opposed to the collated data sets that are exposed to most
of the other tools) so it provides less latency than most but is unsuitable for
examining at the individual client level. It provides a powerful UI that allows
for sophisticated ad-hoc analysis without the need for any specialized
programming skills, but with so many options the UI can be a bit intimidating
for novice users.

#### [Distribution Viewer](distribution_viewer.md)

[Distribution Viewer](https://gauss.telemetry.mozilla.org) is a simple tool
that provides a set of [cumulative distribution
graphs](http://math.stackexchange.com/questions/52400/what-is-cdf-cumulative-distribution-function)
for a pre-specified selection of Firefox user metrics. These metrics are
extracted from a 1% sample of the `clientId`s from Firefox Telemetry. These plots
will allow you to understand how values of different metrics are spread out
among our population of users rather than just using a one number summary (such
as a mean or median). By viewing the entire distribution, you can get a sense
of the importance of behavior at the extremes as well as anomalies within the
population that might indicate interesting behavior. Very simple to use (no
programming required) and able to provide interesting insights, but not usually
suitable for ad-hoc analysis.

#### [Real Time / CEP](../cookbooks/realtime_analysis_plugin.md)

The "real time" or "complex event processing" (CEP)
[system](https://pipeline-cep.prod.mozaws.net/) is part of the ingestion
infrastructure that processes all of our Firefox telemetry data. It provides
extremely low latency access to the data as it's flowing through our ingestion
system on its way to long term storage. As a CEP system, it is unlike the rest
of our analysis tools in that it is up to the analyst to specify and maintain
state from the data that is flowing; it is non-trivial to revisit older data
that has already passed through the system. The CEP is very powerful, allowing
for sophisticated monitoring, alerting, reporting, and dashboarding. Developing
new analysis plugins requires knowledge of the Lua programming language,
relevant APIs, and a custom filter configuration syntax. Learn more about how
to do this in our [Creating a Real-time Analysis
Plugin](../cookbooks/realtime_analysis_plugin.md) article.
