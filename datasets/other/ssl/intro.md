The public SSL dataset publishes the percentage of pageloads Firefox users have performed
that were conducted over SSL. This dataset is used to produce graphs like
[Let's Encrypt's](https://letsencrypt.org/stats/) to determine SSL adoption on the Web
over time.

#### Content

The public SSL dataset is a table where each row is a distinct set of dimensions, with their
associated SSL statistics. The dimensions are `submission_date`, `os`, and `country`. The
statistics are `reporting_ratio`, `normalized_pageloads`, and `ratio`.

#### Background and Caveats

* We're using normalized values in `normalized_pageloads` to obscure absolute pageload counts.
* This is across the entirety of release, not per-version, because we're looking at Web health,
not Firefox user health.
* This is hopefully just a temporary dataset to stopgap release aggregates going away
until we can come up with a better way to publicly publish datasets.

#### Accessing the Data

For details on accessing the data, please look at
[bug 1414839](https://bugzilla.mozilla.org/show_bug.cgi?id=1414839).
