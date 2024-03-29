The `client_count_daily` dataset is useful for estimating user counts over a few
[pre-defined dimensions][client_count_daily_view.sh].

The `client_count_daily` dataset is similar to the deprecated
[`client_count` dataset](/datasets/batch_view/client_count/reference.md)
except that is aggregated by submission date and not activity date.

#### Content

This dataset includes columns for a dozen factors and an HLL variable.
The `hll` column contains a
[HyperLogLog](https://en.wikipedia.org/wiki/HyperLogLog)
variable, which is an approximation to the exact count.
The factor columns include **submission** date and the dimensions listed
[here][client_count_daily_view.sh].
Each row represents one combinations of the factor columns.

#### Background and Caveats

It's important to understand that the `hll` column is **not a standard count**.
The `hll` variable avoids double-counting users when aggregating over multiple days.
The HyperLogLog variable is a far more efficient way to count distinct elements of a set,
but comes with some complexity.
To find the cardinality of an HLL use `cardinality(cast(hll AS HLL))`.
To find the union of two HLL's over different dates, use `merge(cast(hll AS HLL))`.
The [Firefox ER Reporting Query (`STMO#81`)](https://sql.telemetry.mozilla.org/queries/81/source#129)
is a good example to review.
Finally, Roberto has a relevant write-up
[here](https://ravitillo.wordpress.com/2016/04/12/measuring-product-engagment-at-scale/).

#### Accessing the Data

The data is available in STMO.
Take a look at [`STMO#81`](https://sql.telemetry.mozilla.org/queries/81/source#129).

#### Further Reading

[client_count_daily_view.sh]: https://github.com/mozilla/telemetry-airflow/blob/adfce4a30895faa607ccf586b292b61ad68d8f75/jobs/client_count_daily_view.sh
