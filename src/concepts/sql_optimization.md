# Optimize SQL Queries

After you write a query in [STMO](https://sql.telemetry.mozilla.org), you can improve performance by
learning how data is stored, how databases function, and what you can change about a query to
take advantage of the storage structure and the data function.

## TL;DR: What to implement for quick improvements

- Filter on a partitioned column† such as `submission_timestamp` or `submission_date` (_even_ if you have a `LIMIT`)
- Use a sample of the data that is based on the `sample_id` field. This can be helpful
  for initial development even if you later run the query using the entire
  population (without sampling).
- Select only the columns that you want (Don't use `SELECT *`)
- Use approximate algorithms: e.g., `approx_distinct(...)` instead of `COUNT(DISTINCT ...)`

† Most tables are partitioned on either the `submission_timestamp` or `submission_date` fields
  and _clustered_ on `normalized_channel` and `sample_id`;
  you can usually get query efficiency gains by filtering on any of those fields as discussed in
  another article about [BigQuery-specific Query Optimization](../cookbooks/bigquery/optimization.md).

## Some Explanations


### What are these databases?

The primary data storage mechanism used at Mozilla, BigQuery, is not a traditional relational database like PostgreSQL or MySQL. Instead it is a *distributed SQL engine* where data is stored separately from computational resources used to retrieve it.

#### How does this impact my queries?

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

#### Key takeaways

- Limit queries to a few columns that you need to reduce the volume of data that must be read
- Filter the partitions to reduce the volume of data that you need
