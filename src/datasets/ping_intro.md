We receive data from our users via **pings**.
There are several types of pings,
each containing different measurements and sent for different purposes.
To review a complete list of ping types and their schemata, see
[this section of the Mozilla Source Tree Docs][sourcedocs].

Many pings are also described by a JSONSchema specification which can be found in [this repository][jschemas].

#### Background and Caveats

The large majority of analyses can be completed using only the
[main ping][main_ping].
This ping includes histograms, scalars, events, and other performance and diagnostic data.

Few analyses actually rely directly on the raw ping data.
Instead, we provide **derived datasets** which are processed versions of these data,
made to be:
* Easier and faster to query
* Organized to make the data easier to analyze
* Cleaned of erroneous or misleading data

Before analyzing raw ping data,
**check to make sure there isn't already a derived dataset** made for your purpose.
If you do need to work with raw ping data, be aware that loading the data can take a while.
Try to limit the size of your data by controlling the date range, etc.

#### Accessing the Data

You can access raw ping data from an [ATMO cluster][atmo] using the [Dataset API][dataset].
Raw ping data are not available in [re:dash][stmo].

#### Further Reading

You can find [the complete ping documentation][sourcedocs].
To augment our data collection, see [Collecting New Data][addprobe] and the
[Data Collection Policy][datacollection].

[sourcedocs]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/index.html
[jschemas]: https://github.com/mozilla-services/mozilla-pipeline-schemas/tree/master/schemas/telemetry
[main_ping]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/main-ping.html
[atmo]: https://analysis.telemetry.mozilla.org/
[stmo]: https://sql.telemetry.mozilla.org/
[dataset]: https://python-moztelemetry.readthedocs.io/en/stable/api.html#module-moztelemetry.dataset
[addprobe]: https://developer.mozilla.org/en-US/docs/Mozilla/Performance/Adding_a_new_Telemetry_probe
[datacollection]: https://wiki.mozilla.org/Firefox/Data_Collection
