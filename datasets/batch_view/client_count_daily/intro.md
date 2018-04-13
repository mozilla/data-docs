The `client_count_daily` dataset is useful for estimating user counts over a few
[pre-defined dimensions](https://github.com/mozilla/telemetry-airflow/blob/master/jobs/client_count_daily_view.sh).

The `client_count_daily` dataset is similar to the deprecated
[`client_count` dataset](../client_count/reference.md)
except that is aggregated by submission date and not activity date.

#### Content

This dataset includes columns for a dozen factors and an HLL variable.
The `hll` column contains a
[HyperLogLog](https://en.wikipedia.org/wiki/HyperLogLog)
variable, which is an approximation to the exact count.
The factor columns include **submission** date and the dimensions listed
[here](https://github.com/mozilla/telemetry-airflow/blob/master/jobs/client_count_daily_view.sh).
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
Finally, Roberto has a relevant write-up
[here](https://robertovitillo.com/2016/04/12/measuring-product-engagment-at-scale/).

#### Accessing the Data

The data is available in Re:dash.
Take a look at this
[example query](https://sql.telemetry.mozilla.org/queries/81/source#129).

I don't recommend accessing this data from ATMO.

#### Further Reading
