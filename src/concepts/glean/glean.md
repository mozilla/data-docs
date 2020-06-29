# Glean

For Mozilla, getting reliable data from our products is critical to inform our decision making. Glean is our new product analytics & telemetry solution that provides a consistent experience and behavior across all of our products.

The list of supported platforms and implementations is [available in the Glean SDK Book](https://mozilla.github.io/glean/book/dev/core/internal/implementations.html).

> Note that this is different from Telemetry for Firefox Desktop ([library](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/index.html), [datasets](../choosing_a_dataset.md)), although it provides similar capabilities.

Contents:

<!-- toc -->

# Overview

![drawing](../../assets/Glean_overview.jpg)

The **Glean SDK** performs measurements and sends data from our products.
It provides a set of **[metric types](https://mozilla.github.io/glean/book/user/metrics)** for individual measurements that are carefully designed to avoid common pitfalls with measurement.
Metrics are then rolled up into **[pings](https://mozilla.github.io/glean/book/user/pings)** to send over the network.
There are a number of built-in pings that are sent on predefined schedules, but it also possible to send custom pings at any desired cadence.

The **Data Platform** validates and stores these pings in database tables.
A fault tolerant design allows data to be retained in the event of problems such as traffic spikes or invalid data.
Derived and cleaned data can also be automatically created at this stage.

The **Analysis Tools** are used to query and visualize the data.
Because Glean knows more about the individual data, such as its type and the ranges of acceptable values, it can in many cases provide the most appropriate visualization automatically.

<!-- TODO: Link to GLAM -->

# The Glean design principles

**Provide a consistent base of telemetry**

  A baseline of analysis is important for all our products, from counting active users to retention and session times. This is supported out-of-the-box by the SDK, and funnels directly into visualization tools like the [Growth and Usage Dashboard (GUD)](https://growth-stage.bespoke.nonprod.dataops.mozgcp.net/).

  Metrics that are common to all products, such as the operating system and architecture, are provided automatically in a consistent way.

  Any issues found with these base metrics only need be fixed in Glean to benefit all SDK-using products.

**Encourage specificity**

  Rather than just treating metrics as generic data points, Glean wants to know as much as possible about the things being measured.
  From this information, it can:

  - Provide a well-designed API to perform specific types of measurements, which is consistent and avoids common pitfalls
  - Reject invalid data, and report them as errors
  - Store the data in a consistent way, rather than custom, ad hoc data structures
  - Provide the most appropriate visualization and analysis automatically

**Follow [lean data practices](https://leandatapractices.com/)**

  The Glean system enforces that all measurements received [data review](https://wiki.mozilla.org/Firefox/Data_Collection), and it is impossible to collect measurements that haven't been declared.
  It also makes it easy to limit data collection to only what's necessary:

  - Enforced expiration dates for every metric
  - Some metric types can automatically limit resolution
  - It's easy to send data that isn't associated with the client id

  Glean also supports data transparency by automatically generating documentation for all of the metrics sent by an application.

**Provide a self-serve experience**

  Adding new metric is designed to be as easy as possible.
  Simply by adding a few lines of configuration, everything to make them work across the entire suite of tools happens automatically.
  This includes previously manual and error-prone steps such as updating the ping payload and database schemas.

# How to use Glean

* [Integrate the Glean SDK / library](https://mozilla.github.io/glean/book/user/adding-glean-to-your-project.html) into your product.
* [File a data engineering bug](https://bugzilla.mozilla.org/enter_bug.cgi?assigned_to=nobody%40mozilla.org&bug_ignored=0&bug_severity=--&bug_status=NEW&bug_type=task&cf_fx_iteration=---&cf_fx_points=---&comment=Application%20friendly%20name%3A%20my_app_name%0D%0AApplication%20ID%3A%20org.mozilla.my_app_id%0D%0AGit%20Repository%20URL%3A%20https%3A%2F%2Fgithub.com%2Fmozilla%2Fmy_app_name%0D%0ALocations%20of%20%60metrics.yaml%60%20files%20%28can%20be%20many%29%3A%0D%0A%20%20-%20src%2Fmetrics.yaml%0D%0ALocations%20of%20%60probes.yaml%60%20files%20%28can%20be%20many%29%3A%0D%0A%20-%20src%2Fprobes.yaml%0D%0ADependencies%2A%3A%0D%0A%20-%20org.mozilla.components%3Aservice-glean%0D%0A%0D%0A%0D%0A%2A%20Dependencies%20can%20be%20found%20%5Bin%20the%20Glean%20repositories%5D%28https%3A%2F%2Fprobeinfo.telemetry.mozilla.org%2Fglean%2Frepositories%29.%20Each%20dependency%20must%20be%20listed%20explicitly.%20For%20example%2C%20the%20default%20Glean%20probes%20will%20only%20be%20included%20if%20glean%20itself%20is%20a%20dependency.%0D%0A%0D%0AIf%20you%20need%20new%20dependencies%2C%20please%20file%20new%20bugs%20for%20them%2C%20separately%20from%20this%20one.%20For%20any%20questions%2C%20ask%20in%20the%20%23glean%20channel.&component=General&contenttypemethod=list&contenttypeselection=text%2Fplain&defined_groups=1&filed_via=standard_form&flag_type-4=X&flag_type-607=X&flag_type-800=X&flag_type-803=X&flag_type-936=X&form_name=enter_bug&maketemplate=Remember%20values%20as%20bookmarkable%20template&needinfo_from=fbertsch%40mozilla.com%2C%20&op_sys=Unspecified&priority=--&product=Data%20Platform%20and%20Tools&rep_platform=Unspecified&short_desc=Enable%20new%20Glean%20App%20my_app_name&target_milestone=---&version=unspecified) to enable your products application id.
* [Use Redash](https://sql.telemetry.mozilla.org/) to write SQL queries & build dashboards using your products datasets, e.g.:
  * `org_mozilla_fenix.baseline`
  * `org_mozilla_fenix.events`
  * `org_mozilla_fenix.metrics`
  * There is [more documentation about accessing Glean data](accessing_glean_data.md).

* _(Work in progress)_ Use events and [Amplitude](https://sso.mozilla.com/amplitude) for product analytics.
* [Use Databricks](https://sso.mozilla.com/databricks) for deep-dive analysis.
* For experimentation, you can use [Android experiments library](https://github.com/mozilla-mobile/android-components/blob/master/components/service/experiments/README.md), which integrates with Glean.

# Contact

*   `#glean` & `#fx-metrics` on slack
*   [#glean:mozilla.org](https://chat.mozilla.org/#/room/#glean:mozilla.org) on matrix
*   [`glean-team@mozilla.com`](mailto:glean-team@mozilla.com) to reach out
*   [`fx-data-dev@mozilla.com`](mailto:fx-data-dev@mozilla.com) for announcements etc.

# References

* The [Glean SDK](https://github.com/mozilla/glean/) implementation.
* [Reporting issues & bugs for the Glean SDK](https://bugzilla.mozilla.org/enter_bug.cgi?product=Data%20Platform%20and%20Tools&component=Glean%3A%20SDK).
* Datasets documentation (TBD)
* [Glean Debug pings viewer](https://debug-ping-preview.firebaseapp.com/)
