The `heavy_users` table provides information about whether a given client_id is
considered a "heavy user" on each day (using submission date).

#### Contents

The `heavy_users` table contains one row per client-day, where day is
`submission_date`. A client has a row for a specific `submission_date` if
they were active at all in the 28 day window ending on that `submission_date`.

A user is a "heavy user" as of day N if, for the 28 day period ending
on day N, the sum of their active_ticks is in the 90th percentile (or
above) of all clients during that period. For more analysis on this,
and a discussion of new profiles, see
[this link](https://metrics.mozilla.com/protected/sguha/heavy/heavycutoffs5.html).

#### Background and Caveats

1. Data starts at 20170801. There is technically data in the table before
   this, but the `heavy_user` column is `NULL` for those dates because it
   needed to bootstrap the first 28 day window.
2. Because it is top the 10% of clients for each 28 day period, more
   than 10% of clients active on a given `submission_date` will be
   considered heavy users. If you join with another data source
   (`main_summary`, for example), you may see a larger proportion of heavy
   users than expected.
3. Each day has a separate, but related, set of heavy users. Initial
   investigations show that approximately 97.5% of heavy users as of a
   certain day are still considered heavy users as of the next day.
4. There is no "fixing" or weighting of new profiles - days before the
   profile was created are counted as zero `active_ticks`. Analyses may
   need to use the included `profile_creation_date` field to take this
   into account.

#### Accessing the Data

The data is available both via sql.t.m.o and Spark.

In Spark:

```python
spark.read.parquet("s3://telemetry-parquet/heavy_users/v1")
```

In SQL:

```sql
SELECT * FROM heavy_users LIMIT 3
```

#### Further Reading

The code responsible for generating this dataset is
[here](https://github.com/mozilla/telemetry-batch-view/blob/master/src/main/scala/com/mozilla/telemetry/views/HeavyUsersView.scala)
