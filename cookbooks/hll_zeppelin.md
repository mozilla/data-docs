# Working with HyperLogLog in Zeppelin

This guide will set you up to work with HyperLogLog in Zeppelin.

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
    "com.mozilla.telemetry:spark-hyperloglog:2.0.0-SNAPSHOT"
    ```

These steps should enable the use of the library within the notebook. Using the `%dep` interpreter to dynamically add the library is currently not supported. You may want to add a short snippet near the top of the notebook to make the functions more accessible.

```
import org.apache.spark.sql.SparkSession
import com.mozilla.spark.sql.hyperloglog.functions._
import com.mozilla.spark.sql.hyperloglog.aggregates._

object UDFs{
  val HllCreate = "hll_create"
  val HllCardinality = "hll_cardinality"
  val HllMerge = new HyperLogLogMerge

  //val FilteredHllMerge = new FilteredHyperLogLogMerge

  implicit class MozUDFs(spark: SparkSession) {
    def registerUDFs: Unit = {
      spark.udf.register(HllCreate, hllCreate _)
      spark.udf.register(HllCardinality, hllCardinality _)
    }
  }
}

import UDFs._
spark.registerUDFs
```

