# Metric Definitions

It is important to understand that metrics are often defined in terms of a usage criteria.

* A `usage criterion` defines what a metric is measuring.  It generally specifies a product and what specific use of that product qualifies as active.  For example, “Any Fenix Activity” measures activity for all Fenix profiles that send a telemetry pings.  Similarly, “Opened DevTools” means that we measure activity for all Firefox profiles that send a telemetry ping indicating that DevTools was opened.

* A `dimension` allows slicing to a subset of profiles according to characteristics of those profiles.  Available dimensions include: country, channel, OS, etc.  A slice is a set of particular values within dimensions, for example, “country is US” is one slice and “country is either US or DE and channel is release” is another.

* A `metric` summarizes activity for a particular day.  It is defined in terms of a `usage criterion` and `slice`.  For example, the `DAU` metric will tell you how many profiles met the `usage criterion` within the `slice` or, more concretely, might tell you how many profiles had any Firefox Desktop activity within Canada.
