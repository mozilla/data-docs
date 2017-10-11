The `retention` table provides client counts relevant to client retention at a
1-day granularity. The project is tracked in [Bug 1381840][original_bug]

### Contents

The `retention` table contains a set of attribute columns used to specify a
cohort of users and a set of metric columns to describe cohort activity. Each
row contains a permutation of attributes, an approximate set of clients in a
cohort, and the aggregate engagement metrics.

This table uses the HyperLogLog (HLL) sketch to create an approximate set of
clients in a cohort. HLL allows counting across overlapping cohorts in a single
pass while avoiding the problem of double counting. This data-structure has the
benefit of being compact and performant in the context of retention analysis,
at the expense of precision. For example, calculating a 7-day retention period
can be obtained by aggregating over a week of retention data using the union
operation. With SQL primitive, this requires a recomputation of COUNT DISTINCT
over `client_id`'s in the 7-day window.

#### Background and Caveats

1. The data starts at 2017-03-06, the [merge date where Nightly started to
   track Firefox 55 in Mozilla-Central][release_calendar]. However, there was
not a consistent view into the behavior of first session profiles until the
[`new_profile` ping][new_profile]. This means much of the data is inaccurate
before 2017-06-26.
2. This dataset uses 4-day reporting latency to aggregate at least 99% of the
   data in a given submission date. This figure is derived from the
[telemetry-health measurements on submission latency][telemetry-health], with
the discussion in [Bug 1407410][bug_1407410]. This latency metric was reduced
Firefox 55 with the introduction of the shutdown ping-sender mechanism.
3. Caution should be taken before adding new columns. Additional attribute
   columns will grow the number of rows exponentially.
4. The number of HLL bits chosen for this dataset is 13. This means the default
   size of the HLL object is 2^13 bits or 1KiB. This maintains about a 1% error
on average. See [this table from Algebird's HLL implementation][algebird] for
more details.


#### Accessing the Data

The data is primarily available through [Redash on STMO][stmo] via
the Presto source. This service has been configured to use predefined HLL
functions.

The column should first be cast to the HLL type. The scalar
`cardinality(<hll_column>)` function will approximate the number of unique
items per HLL object. The aggregate `merge(<hll_column>)` function will perform
the set union between all objects in a column.

Example: Cast the count column into the appropriate type.
```sql
SELECT cast(hll as HLL) as n_profiles_hll FROM retention
```

Count the number of clients seen over all attribute combinations.
```sql
SELECT cardinality(cast(hll as HLL)) FROM retention
```

Group-by and aggregate client counts over different release channels.
```sql
SELECT channel, cardinality(merge(cast(hll AS HLL))
FROM retention
GROUP BY channel
```

The HyperLogLog library wrappers are available for use outside of the
configured STMO environment, [`spark-hyperloglog`][s-hll] and
[`presto-hyperloglog`][p-hll].

Also see the [`client_count` dataset][client_count].


[original_bug]: https://bugzilla.mozilla.org/show_bug.cgi?id=1381840
[release_calendar]: https://wiki.mozilla.org/RapidRelease/Calendar
[new_profile]: ../new_profile/reference.md
[telemetry-health]: https://sql.telemetry.mozilla.org/dashboard/telemetry-health
[bug_1407410]: https://bugzilla.mozilla.org/show_bug.cgi?id=1407410
[algebird]: https://github.com/twitter/algebird/blob/develop/algebird-core/src/main/scala/com/twitter/algebird/HyperLogLog.scala#L230-L255
[stmo]: sql.telemetry.mozilla.org
[s-hll]: https://github.com/mozilla/spark-hyperloglog
[p-hll]: https://github.com/vitillo/presto-hyperloglog
[client_count]: ../client_count/reference.md

