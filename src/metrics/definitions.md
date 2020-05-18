# Metric Definitions

These sections provide the lists of our standardized metrics, usage criteria, and slicing dimensions.

* A `usage criterion` defines what qualifies as usage.  It generally specifies a product and what specific use of that product qualifies as active.  For example, “Any Fenix Activity” measures activity for all Fenix profiles that have sent a `baseline` ping.  Similarly, “Opened DevTools” means that we measure activity for all desktop Firefox profiles that have sent a telemetry ping indicating that DevTools was opened.  We are working towards developing a standard usage criteria for each product, which operationalizes the idea that the product was "used".  It is important to understand that some metrics (such as MAU) are defined in terms of a usage criterion.

* A `dimension` allows slicing to a subset of profiles according to characteristics of those profiles.  Some dimensions include: country, channel, OS, etc.  A `slice` is a set of particular values within dimensions, for example, “country is US” is one `slice` and “country is either US or DE and channel is release” is another.

* A `metric` is any quantity that we can calculate using our data and that, to some degree, measures some quantity of interest. 
