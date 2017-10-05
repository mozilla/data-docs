The `heavy_users` table provides information about whether a given client_id is
considered a "heavy user" on each day (using submission date).

#### Contents

The `heavy_users` table contains one row per client-day, where day is
submission_date. A client has a row for a specific submission_date if
they were active at all in the 28 day window ending on that submission_date.

A user is a "heavy user" as of day N if, for the 28 day period ending
on day N, the sum of their active_ticks is in the 90th percentile (or
above) of all clients during that period. For more analysis on this,
and a discussion of new profiles, see
[this link](https://metrics.mozilla.com/protected/sguha/heavy/heavycutoffs5.html).

#### Background and Caveats

1. Data starts at 20170801. There is technically data in the table before this, but heavy_user is NULL for those dates because it needed to bootstrap the first 28 day window.
2. Because it is top 10% for each 28 day period, and single submission_date has more than 10% of clients be considered heavy_users. This is because heavy_users, on average, use Firefox on more days than non-heavy users.
3. Each day has a separate, but related, set of heavy_users. Initial investigations show that ~97.5% of heavy_user as of a certain day are still considered heavy_users as of the next day.

#### Accessing the Data

The data is available both via sql.t.m.o and Spark.

In Spark:
```python
spark.read.parquet("s3://telemetry-parquet/heavy_users/v1")
```

In SQL:
```sql
SELECT * FROM heavy_users
```

Example queries:

- [Join heavy_users with main_summary to get distribution of max_concurrent_tab_count for heavy vs. non-heavy users](https://sql.telemetry.mozilla.org/queries/47041/source#127382)
- [Join heavy_users with longitudinal to get crash rates for heavy vs. non-heavy users](https://sql.telemetry.mozilla.org/queries/47044/source#127385)

You'll note that it seems that heavy_users use more tabs, but crash less. These results probably require more investigation.

#### Further Reading

The code responsible for generating this dataset is
[here](https://github.com/mozilla/telemetry-batch-view/blob/master/src/main/scala/com/mozilla/telemetry/views/HeavyUsersView.scala)
