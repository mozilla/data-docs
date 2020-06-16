# Optimizing BigQuery Queries

When writing a query using [STMO](https://sql.telemetry.mozilla.org) or the BigQuery console, you can improve performance and reduce costs by learning how data is stored, how databases function, and what you can change about a query to take advantage of the storage structure and the data function.

[Queries are charged by data scanned at \$5 per terabyte (TB)](https://cloud.google.com/bigquery/pricing#on_demand_pricing) so each 200 gigabytes of data scanned will cost \$1: on tables with hundreds of TBs of data (like the [main ping table](../../datasets/pings.md#main-ping) or [`clients_daily`](../../datasets/batch_view/clients_daily/reference.md)), costs **can add up very quickly**.

## Table of Contents

<!-- toc -->

## TL;DR: What to implement for quick improvements

- Filter on a partitioned column such as `submission_timestamp` or `submission_date` (_even_ if you have a `LIMIT`: see [optimization caveats](#optimization-caveats))
- Use a sample of the data that is based on the `sample_id` field. This can be helpful for initial development even if you later run the query using the entire
  population (without sampling).
  - Tables that include a `sample_id` field will usually have that as one of the clustering fields and you can efficiently scan random samples of users by specifying `WHERE sample_id = 0` (1% sample), `WHERE sample_id < 10` (10% sample), etc. This can be especially helpful with `main_summary`, `clients_daily`, and `clients_last_seen` which are very large tables and are all clustered on `sample_id`.
- Many datasets also cluster on `normalized_channel`, corresponding to the channel of the product. If you are working with data that has different channels (for example, Firefox desktop), limit your initial query to a channel with a limited population like Nightly (in the case of Firefox desktop, do this by adding `WHERE normalized_channel='nightly'` to your query)
- Select only the columns that you want (**Don't** use `SELECT *`)
  - If you are experimenting with data or exploring data, use one of the [data preview options](https://cloud.google.com/bigquery/docs/best-practices-costs#preview-data) instead of `SELECT *`.
- Use [approximate algorithms](https://cloud.google.com/bigquery/docs/reference/standard-sql/approximate_aggregate_functions): e.g., `approx_count_distinct(...)` instead of `COUNT(DISTINCT ...)`
  - See [approximate aggregation functions](https://cloud.google.com/bigquery/docs/reference/standard-sql/functions-and-operators#approximate-aggregate-functions) in the standard SQL reference.
- Reference the data size prediction ("This query will process X bytes") in STMO and the BigQuery UI to help gauge the efficiency of your queries. You should see this number go down as you limit the range of `submission_date`s or include fewer fields in your `SELECT` statement.
- If using JOIN, trim the data to-be-joined before the query performs a JOIN. If you reduce data early in the processing cycle, shuffling and other complex operations only execute on the data that you need.
  - Use sub queries with filters or intermediate tables or views as a way of decreasing sides of a join, prior to the join itself.
- Do not treat WITH clauses as prepared statements
  - WITH clauses are used primarily for readability because they are not materialized: if a query appears in more than one WITH clause, it executes in each clause. Do not rely on them to optimize your query!

## Optimization Caveats

- For clustered tables, the data size prediction won't take into account benefits from `LIMIT`s and `WHERE` clauses on clustering fields, so you'll need to compare to the actual "Data Scanned" after the query is run.
- Applying a `LIMIT` clause to a `SELECT *` query might not affect the amount of data read, depending on the table structure.
  - Many of our tables are configured to use _clustering_ in which case a `LIMIT` clause does effectively limit the amount of data that needs to be scanned. To check whether your `LIMIT` and `WHERE` clauses are actually improving performance, you should see a lower value reported for actual "Data Scanned" by a query compared to the prediction ("This query will process X bytes") in STMO or the BigQuery UI.

## Some Explanations

### What are these databases?

The primary data storage mechanism used at Mozilla, BigQuery, is not a traditional relational database like PostgreSQL or MySQL. Instead it is a _distributed SQL engine_ where data is stored separately from computational resources used to retrieve it.

Multiple machines work together to get the result of your query. Because there is more than one system, you need to pay particular attention to _Data Shuffles_: when all systems have to send data to all other systems.

For example, consider the following query, which lists the number of rows that are present for each
`client_id`:

```
SELECT client_id, COUNT(*)
FROM telemetry.main
GROUP BY client_id
```

During the execution of this query, the BigQuery cluster performs the following steps:

1. Each system reads a different piece of the data and parses the `client_id` for
   each row. Internally, it then computes the number of rows seen for each `client_id`,
   _but only for the data that it read_.
1. Each system is then assigned a set of `client_id`s to aggregate. For example, the first
   system may be given instructions to get the count of `client1`. It then has to send a request to every other system for the total seen for `client1`. It can then aggregate the total.
1. If every `client_id` has been aggregated, each system reports to the coordinator
   the `client_id`s that it was responsible for, as well as the count of rows seen by each.
   The coordinator is responsible for returning the result of the query to the client,
   which in this example is STMO.

A similar process occurs on data joins, where different systems are instructed to join on
different keys. In that case, data from both tables needs to be shuffled to every system.

#### Key takeaways

- Use `LIMIT` for query prototyping to dramatically reduce the volume of data scanned
  as well as speeding up processing.
- Use approximate algorithms. Then less data needs to be shuffled because
  probabilistic data structures can be used instead of the raw data itself.
- Specify large tables first in a `JOIN` operation. In this case, small tables can be sent to
  every system to eliminate one data shuffle operation. Note that Spark supports a `broadcast`
  command explicitly.

### How is the data stored?

The data is stored in columnar format.

#### Traditional Row Stores

Consider a typical CSV file, which represents an example of a row store.

```
name,age,height
"Ted",27,6.0
"Emmanuel",45,5.9
"Cadence",5,3.5
```

When this data is stored to disk, you can read an entire record in consecutive order. For example, if
the first `"` is stored at block 1 on disk, then a sequential scan from 1 assigns the first row of
data: `"ted",27,6.0`. Keep scanning and you get `\n"Emm`... and so on.

You can use the following query that you can execute very quickly:

```
SELECT *
FROM people
WHERE name == 'Ted'
```

The database can just scan the first row of data. However, the following is more difficult:

```
SELECT name
FROM people
```

Now the database has to read _all_ of the rows and then select the `name` column, which results in a lot
more overhead.

#### Columnar Stores

Columnar turns the data sideways. For example, you can make a columnar version of the above data
and still store it in CSV format:

```
name,"Ted","Emmanuel","Cadence"
age,27,45,5
height,6.0,5.9,3.5
```

Now let's consider how we can query the data when it's stored this way:

```
SELECT *
FROM people
WHERE name == "ted"
```

In this case, all the data must be read because the
`(name, age, height)` is not stored together.

Here's another query:

```
SELECT name
FROM people
```

In this case, only the "name" row needs to be read. All the other lines of the
file can be skipped.

#### Data partitions

You can improve performance even further by taking advantage of partitions. These are entire files of data that share a value for a column. For example, if everyone in the `people` table lived in `DE`, then you can add that to the filename: `/country=DE/people.csv`.

From there, a query engine would have to know how to read that path and understand that
all of these people share a country. You can query as follows:

```
SELECT *
FROM people
WHERE country == 'US'
```

In this case, the query engine no longer even has to read the file. It could just look at the path and realize that there is nothing of interest.

Tables are usually partitioned based on dates; e.g., `submission_date` or `DATE(submission_timestamp)`.

#### Data Ordering (clustering)

Another way to improve query performance is to select a subset of data on a field that the data is ordered by. In BigQuery, this is called "clustering". A clustered field is one which is sorted in the underlying data.

For example, if we wanted to get all of ages greater than age 40 in our table above, we might query like this:
`SELECT age FROM people WHERE age > 45`

Then we would scan all of the `age` field, starting from `27`, then `45`, then `5`.

However, if we sort the data on that field, our table would look like this:
\```
name,"Cadence","Ted","Emmanuel"
age,5,27,45
height,3.5,6.0,5.9
\```

Since data is stored on different files, we could ignore any `age` files that don't have data less than 40. So if Cadence and Ted's ages were in one file, and Emmanuel's in the next, we could skip reading that first file entirely. In that way, we can sometimes drastically reduce the amount of data we're reading.
#### Key takeaways

- Limit queries to a few columns that you need to reduce the volume of data that must be read
- Filter the partitions to reduce the volume of data that you need
- Filter on clustered fields
