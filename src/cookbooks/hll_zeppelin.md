# Working with HyperLogLog in Zeppelin

This guide will set you up to work with HyperLogLog in Zeppelin.

## Zeppelin Configuration

* Launch a Zeppelin notebook
* Open the panel for Interpreter configuration
    - This can be found at `localhost:8890/#/intepreter`
* Add the Sonatype Snapshot repository
    - Expand the Repository Information cog, next to the create button
    - Settings are as follows:
    ```
    ID: Sonatype OSS Snapshots
    URL: https://oss.sonatype.org/content/repositories/snapshots
    Snapshot: true
    ```
* Add the dependency to the `Spark` interpreter
    - spark > Edit > Dependencies
    - Add the following entry to artifacts:
    ```
    com.mozilla.telemetry:spark-hyperloglog:2.0.0-SNAPSHOT
    ```

These steps should enable the use of the library within the notebook. Using the
`%dep` interpreter to dynamically add the library is currently not supported.
You may want to add a short snippet near the top of the notebook to make the
functions more accessible.

```scala
import org.apache.spark.sql.functions.udf
import com.mozilla.spark.sql.hyperloglog.aggregates._
import com.mozilla.spark.sql.hyperloglog.functions._

val HllMerge = new HyperLogLogMerge
val HllCreate = udf(hllCreate _)
val HllCardinality = udf(hllCardinality _)

spark.udf.register("hll_merge", HllMerge)
spark.udf.register("hll_create", HllCreate)
spark.udf.register("hll_cardinality", HllCardinality)
```

## Example Usage

This is a short example which can also be used to verify expected behavior.
```scala
case class Example(uid: String, color: String)

val examples = Seq(
    Example("uid_1", "red"),
    Example("uid_2", "blue"),
    Example("uid_3", "blue"),
    Example("uid_3", "red"))

val frame = examples.toDF()
```


In a single expression, we can create and count the unique id's that appear in the DataFrame.
```scala
>>> frame
  .select(expr("hll_create(uid, 12) as hll"))
  .groupBy()
  .agg(expr("hll_cardinality(hll_merge(hll)) as count"))
  .show()

+-----+
|count|
+-----+
|    3|
+-----+
```


The code in the previous section defines UDF functions that can be used directly
as Spark column expressions. Let's explore the data structure a bit more in
slightly more detail.

```scala
val example = frame
    .select(HllCreate($"uid", lit(12)).alias("hll"), $"color")
    .groupBy("color")
    .agg(HllMerge($"hll").alias("hll"))

example.createOrReplaceTempView("example")
```

This groups `uid`s by the `color` attribute and registers the table with the SQL
context. Each row contains a HLL binary object representing the set of `uid`s.

```scala
>>> example.show()
+-----|--------------------+
|color|                 hll|
+-----|--------------------+
|  red|[02 0C 00 00 00 0...|
| blue|[02 0C 00 00 00 0...|
+-----|--------------------+
```
Each HLL object takes up `2^12` bits of space. This configurable size parameter
affects the size and standard error of the cardinality estimates. The
cardinality operator can count the number of `uid`s associated with each `color`.

```scala
>>> example.select($"color", HllCardinality($"hll").alias("count")).show()
+-----|-----+
|color|count|
+-----|-----+
|  red|    2|
| blue|    2|
+-----|-----+
```

We can also write this query in the `%sql` interpreter.

```SQL
%dep sql

SELECT color, hll_cardinality(hll_merge(hll)) as count
FROM example
GROUP BY color
```

Finally, note that the `color` HLL sets have an overlapping `uid`. We obtain the
count of `uid`s and avoid double counting by merging the sets.

```scala
>>> example.groupBy().agg(HllCardinality(HllMerge($"hll")).alias("count")).show()
+-----+
|count|
+-----+
|    3|
+-----+
```
