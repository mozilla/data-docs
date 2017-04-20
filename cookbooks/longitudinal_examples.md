### Introduction

The longitudinal dataset is a summary of main pings. If you're not sure which
dataset to use for your query, this is probably what you want. It differs from
the main_summary table in two important ways:

* The longitudinal dataset groups all data for a client-id in the same row.
  This makes it easy to report profile level metrics. Without this deduping,
  metrics would be weighted by the number of submissions instead of by clients.
* The dataset uses a 1% of all recent profiles, which will reduce query
  computation time and save resources. The sample of clients will be stable over
  time.

Accordingly, one should prefer using the Longitudinal dataset except in the
rare case where a 100% sample is strictly necessary.

As discussed in the [Longitudinal Data Set Example Notebook][1]:

    The longitudinal dataset is logically organized as a table where rows
    represent profiles and columns the various metrics (e.g. startup time). Each
    field of the table contains a list of values, one per Telemetry submission
    received for that profile. [...]

    The current version of the longitudinal dataset has been build with all
    main pings received from 1% of profiles across all channels with [...] up to
    180 days of data.

### Table structure

To get an overview of the longitudinal data table:

```sql
DESCRIBE longitudinal
```

That table has a row for each client, with columns for the different
parts of the ping. There are a lot of fields here, so I recommend
downloading the results as a CSV if you want to search through these
fields. Unfortunately, there's no way to filter the output of DESCRIBE
in Presto.

Because this table combines all rows for a given client id, most columns
contain either Arrays or Maps (described below). A few properties are
directly available to query on:

```sql
SELECT count(*) AS count
FROM longitudinal
WHERE os = 'Linux'
```

#### Arrays

Most properties are arrays, which contain one entry for each submission
from a given client (newest first). Note that indexing starts at 1:

```sql
SELECT reason[1] AS newest_reason
FROM longitudinal
WHERE os = 'Linux'
```

To expand arrays and maps and work on the data row-wise we can use
`UNNEST(array)`.

```sql
WITH lengths AS
  (SELECT os, greatest(-1, least(31, sl / (24*60*60))) AS days
   FROM longitudinal
   CROSS JOIN UNNEST(session_length, reason) AS t(sl, r)
   WHERE r = 'shutdown' OR r = 'aborted-session')
SELECT os, days, count(*) AS count
FROM lengths
GROUP BY days, os ORDER BY days ASC
```

However, it may be better to use a sample from the main_summary table
instead.

Links:

-   [Documentation on array
    functions](https://prestodb.io/docs/current/functions/array.html)
-   [`UNNEST`
    documentation](https://prestodb.io/docs/current/sql/select.html#unnest)

#### Maps

Some fields like `active_addons` or `user_prefs` are handled as maps, on
which you can use the `[]` operator and special functions:

```sql
WITH adp AS
  (SELECT active_addons[1]['{d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}']
            IS NOT null AS has_adblockplus
   FROM longitudinal)
SELECT has_adblockplus, count(*) AS count
FROM adp GROUP BY 1 ORDER BY 2 DESC
```

Links:

-   [Documentation on map
    functions](https://prestodb.io/docs/current/functions/map.html)

### Sampling

While composing queries, it can be helpful to work on small samples to
reduce query runtimes:

```sql
SELECT * FROM longitudinal LIMIT 1000 ...
```

There's no need to use other sampling methods, such as TABLESAMPLE, on
the longitudinal set. Rows are randomly ordered, so a LIMIT sample is
expected to be random.

### Example Queries

#### Blocklist URLs (extensions.blocklist.url)

```sql
SELECT bl, COUNT(bl)
FROM
  (SELECT element_at(settings, 1).user_prefs['extensions.blocklist.url'] AS bl
   FROM longitudinal)
GROUP BY bl
```

#### Blocklist enabled/disabled (extensions.blocklist.enabled) count:
```sql
SELECT bl, COUNT(bl)
FROM
  (SELECT element_at(settings, 1).blocklist_enabled AS bl
   FROM longitudinal)
GROUP BY bl
```

#### Parsing most recent submission_date

```sql
SELECT DATE_PARSE(submission_date[1], '%Y-%m-%dT00:00:00.000Z') as parsed_submission_date
FROM longitudinal
```

#### Limiting to most recent ping in the last 7 days

```sql
SELECT * FROM longitudinal
WHERE DATE_DIFF('day', DATE_PARSE(submission_date[1], '%Y-%m-%dT00:00:00.000Z'), current_date) < 7
```

#### Scalar measurement (how many users with more than 100 tabs)

```sql
WITH samples AS
 (SELECT
   client_id,
   normalized_channel as channel,
   mctc.value AS max_concurrent_tabs
  FROM longitudinal
  CROSS JOIN UNNEST(scalar_parent_browser_engagement_max_concurrent_tab_count) as t (mctc)
  WHERE
   scalar_parent_browser_engagement_max_concurrent_tab_count is not null and
   mctc.value is not null and
   normalized_channel = 'nightly')
SELECT approx_distinct(client_id) FROM samples WHERE max_concurrent_tabs > 100
```

### Using Views

If you find yourself copy/pasting SQL between different queries,
consider using a Presto VIEW to allow for code reuse. Views create
logical tables which you can reuse in other queries. For example, [this
view](https://sql.telemetry.mozilla.org/queries/776/source) defines some
important filters and derived variables which are then used in [this
downstream
query](https://sql.telemetry.mozilla.org/queries/777/source#1311).

You can define a view by prefixing your query with

```sql
CREATE OR REPLACE VIEW view_name AS ...
```

Be careful not to overwrite an existing view! Using a unique name is
important.

Find more information
[here](https://prestodb.io/docs/current/sql/create-view.html).

### Working offline

It's often useful to keep a local sample of the l10l data when
prototyping an analysis. The data is stored in
s3://telemetry-parquet/longitudinal/. Once you have AWS credentials you
can copy a shard of the parquet dataset to a local directory using `aws
cp [filename] .`

To request AWS credentials, see [this
page](https://mana.mozilla.org/wiki/display/SVCOPS/Requesting+A+Dev+IAM+account+from+Cloud+Operations).
To initiate your AWS config, try `aws configure`

### FAQ

#### I'm getting an error, "... cannot be resolved"

For some reason, re:dash has trouble parsing SQL strings with double
quotes. Try using single quotes instead.

### Other Resources

- [Presto Docs](https://prestodb.io/docs/current/sql.html)
- [Helpful FAQ covering
  perf/distribution](https://docs.treasuredata.com/articles/presto-query-faq)
- [Longitudinal schema
  definition](https://github.com/mozilla/telemetry-batch-view/blob/master/src/main/scala/com/mozilla/telemetry/views/Longitudinal.scala#L194)
- [Custom_dashboards_with_re:dash](https://wiki.mozilla.org/Custom_dashboards_with_re:dash)

[1]: https://github.com/mozilla/emr-bootstrap-spark/blob/master/examples/Longitudinal%20Dataset%20Tutorial.ipynb
