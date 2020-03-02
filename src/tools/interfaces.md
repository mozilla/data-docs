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

#### [Databricks](https://dbc-caf9527b-e073.cloud.databricks.com/)

Offers notebook interface with shared, always-on, autoscaling cluster
(attaching your notebooks to `shared_serverless_python3` is the best way to start).
Convenient for quick data investigations. Users are advised to join the
[`databricks-discuss@mozilla.com`](https://groups.google.com/a/mozilla.com/forum/#!forum/databricks-discuss) group.

#### [`telemetry.mozilla.org`](../concepts/analysis_intro.md) (TMO)

Our [`telemetry.mozilla.org`](https://telemetry.mozilla.org) (TMO) site is the
'venerable standby' of Firefox telemetry analysis tools. It uses aggregate
telemetry data (as opposed to the collated data sets that are exposed to most
of the other tools) so it provides less latency than most but is unsuitable for
examining at the individual client level. It provides a powerful UI that allows
for sophisticated ad-hoc analysis without the need for any specialized
programming skills, but with so many options the UI can be a bit intimidating
for novice users.
