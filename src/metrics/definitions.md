# Metric Definitions

These sections provide the lists of our standardized metrics, usage criteria, and slicing dimensions. All three are important to provide a holistic view of product usage and performance.

- A [`usage criterion`](./usage.md) tells us what has to happen for us to consider a product to have been used in a certain way and is needed to define metrics like MAU, which count users that use our products. For example, “Any Fenix Activity” measures activity for all Fenix profiles that have sent a `baseline` ping. Similarly, “Opened DevTools” means that we measure activity for all desktop Firefox profiles that have sent a telemetry ping indicating that DevTools was opened. We are working towards developing a standard usage criteria for each product, which operationalizes the idea that the product was "used".

- A [`dimension`](./dimensions.md) allows slicing to a subset of profiles according to characteristics of those profiles. Some dimensions include: country, channel, OS, etc. A `slice` is a set of particular values within dimensions, for example, “country is US” is one `slice` and “country is either US or DE and channel is release” is another.

- A [`metric`](./metrics.md) is any quantity that we can calculate using our data and that, to some degree, measures some quantity of interest.
