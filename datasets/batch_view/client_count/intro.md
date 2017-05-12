The `client_count` dataset is useful for estimating user counts over a few 
[pre-defined dimensions](https://github.com/mozilla/telemetry-batch-view/blob/master/src/main/scala/com/mozilla/telemetry/views/ClientCountView.scala#L22).

#### Content

This dataset includes columns for a dozen factors and an HLL variable.
The `hll` column contains a
[HyperLogLog](https://en.wikipedia.org/wiki/HyperLogLog)
variable, which is an approximation to the exact count.
The factor columns include activity date and the dimensions listed
[here](https://github.com/mozilla/telemetry-batch-view/blob/master/src/main/scala/com/mozilla/telemetry/views/ClientCountView.scala#L22).
Each row represents one combinations of the factor columns.

#### Background and Caveats

It's important to understand that the `hll` column is **not a standard count**.
The `hll` variable avoids double-counting users when aggregating over multiple days.
The HyperLogLog variable is a far more efficient way to count distinct elements of a set,
but comes with some complexity.
To find the cardinality of an HLL use `cardinality(cast(hll AS HLL))`.
To find the union of two HLL's over different dates, use `merge(cast(hll AS HLL))`.
The [Firefox ER Reporting Query](https://sql.telemetry.mozilla.org/queries/81/source#129)
is a good example to review.
Finally, Roberto has a relevant writeup
[here](https://robertovitillo.com/2016/04/12/measuring-product-engagment-at-scale/).

#### Accessing the Data

The data is available in re:dash.
Take a look at this 
[example query](https://sql.telemetry.mozilla.org/queries/81/source#129).

I don't recommend accessing this data from ATMO.

#### Further Reading
