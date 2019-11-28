# Optimizing SQL Queries

After you write a query in [STMO](https://sql.telemetry.mozilla.org), you can make big steps to improve performance by
understanding how data is stored, what databases are doing under the covers, and what you can change about your query to
take advantage of those two pieces.

## TL;DR: What to do for quick improvements

- Filter on a partitioned column† (_even_ if you have a `LIMIT`)
- Use a sample of the data based on the `sample_id` field. This can be helpful
  for initial development, even if you later run the query using the entire
  population (without sampling).
- Select only the columns you want explicitly (Don't use `SELECT *`)
- Use approximate algorithms: e.g. `approx_distinct(...)` instead of `COUNT(DISTINCT ...)`

† Partitioned columns can be identified in the Schema Explorer in [re:dash](https://sql.telemetry.mozilla.org).
  They are the first few columns under a table name, and their name is preceded by a `[P]`.

## Some Explanations

There are a few key things to understand about our data storage and these databases to
learn how to properly optimize queries.

### What are these databases?

The databases we use are not traditional relational databases like PostgreSQL or MySQL.
They are distributed SQL engines, where the data is stored separately from the compute resources.
They include multiple machines all working together in a coordinated fashion.

#### How does this impact my queries?

What that means is that multiple machines will be working together to get the result of your
query. Because there is more than one machine, we worry a lot about _Data Shuffles_: when all
of the machines have to send data around to all of the other machines.

For example, consider the following query, which gives the number of rows present for each
`client_id`:

```
SELECT client_id, COUNT(*)
FROM telemetry.main
GROUP BY client_id
```

The steps that would happen are this:
1. Each machine reads a different piece of the data, and parses out the `client_id` for
   each row. Internally, it then computes the number of rows seen for each `client_id`,
   _but only for the data that it read_.
1. Each machine is then given a set of `client_id`s to aggregate. For example, the first
   machine may be told to get the count of `client1`. It will then have to ask every other
   machine for the total seen for `client1`. It can then aggregate the total.
1. Given that every `client_id` has now been aggregated, each machine reports to the coordinator
   the `client_id`s that it was responsible for, as well as the count of rows seen for each.
   The coordinator is responsible for returning the result of the query to the client,
   which in our example is STMO.

A similar process happens on data joins, where different machines are told to join on
different keys. In that case, data from both tables needs to be shuffled to every machine.

#### Key Takeaways

- Use `LIMIT` for query prototyping. This can dramatically reduce the amount of data scanned
  as well as speeding things up.
- Use approximate algorithms. These mean less data needs to be shuffled, since we can use
  probabilistic data structures instead of the raw data itself.
- Specify large tables first in a `JOIN` operation. In this case, small tables can be sent to
  every machine, eliminating one data shuffle operation. Note that Spark supports a `broadcast`
  command explicitly.

### How is the data stored?

The data is stored in columnar format. Let's try and understand that with an example.

#### Traditional Row Stores

Consider a completely normal CSV file, which is actually an example of a row store.

```
name,age,height
"Ted",27,6.0
"Emmanuel",45,5.9
"Cadence",5,3.5
```

When this data is stored to disk, you could read an entire record in a consecutive order. For example if
the first `"` was stored at block 1 on disk, then a sequential scan from 1 will give the first row of
data: `"ted",27,6.0`. Keep scanning and you'll get `\n"Emm`... and so on.

So for the above, the following query will be fast:

```
SELECT *
FROM people
WHERE name == 'Ted'
```

Since the database can just scan the first row of data. However, the following is more difficult:

```
SELECT name
FROM people
```

Now the database has to read _all_ of the rows, and then pick out the `name` column. This is a lot
more overhead!

#### Columnar Stores

Columnar turns the data sideways. For example, we can make a columnar version of the above data,
and still store it in CSV:

```
name,"Ted","Emmanuel","Cadence"
age,27,45,5
height,6.0,5.9,3.5
```

Pretty easy! Now let's consider how we can query the data when it's stored this way.

```
SELECT *
FROM people
WHERE name == "ted"
```

This query is pretty hard! We have to read all of the data now, because the
`(name, age, height)` isn't stored together.

Now let's consider our other query:

```
SELECT name
FROM people
```

Suddenly, this is easy! We don't have to check in as many places for data,
we can just read the first few blocks of disks sequentially.

#### Data Partitions

We can improve performance even further by taking advantage of partitions. These are entire files of data
that share a value for a column. So for example, if everyone in the `people` table lived in `DE`, then we
could add that to the filename: `/country=DE/people.csv`.

From there, our query engine would have to know how to read that path, and understand that it's telling us
that all of those people share a country. So if we were to query for this:

```
SELECT *
FROM people
WHERE country == 'US'
```

The database wouldn't have to even read the file! It could just look at the path and realize there was
nothing of interest.

Our tables are usually partitioned by date, e.g. `submission_date` or `DATE(submission_timestamp)`.

#### Key Takeaways

- Limit queries to a specific few columns you need, to reduce the amount of data that has to be read
- Filter on partitions to prune down the data you need
