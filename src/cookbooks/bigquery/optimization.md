# Query Optimizations

If you want to improve query performance and minimize the cost that is associated with using BigQuery, familiarize yourself with the following query optimizations:

- Avoid `SELECT *` by selecting only the columns you need
    - Using `SELECT *` is the most expensive way to query data. When you use `SELECT *` _BigQuery does a full scan of every column in the table._
    - Applying a `LIMIT` clause to a `SELECT *` query might not affect the amount of data read, depending on the table structure.
      - Many of our tables are configured to use _clustering_ in which case a `LIMIT` clause does effectively limit the amount of data that needs to be scanned.
      - Tables that include a `sample_id` field will usually have that as one of the clustering fields and you can efficiently scan random samples of users by specifying `WHERE sample_id = 0` (1% sample), `WHERE sample_id < 10` (10% sample), etc. This can be especially helpful with `main_summary`, `clients_daily`, and `clients_last_seen` which are very large tables and are all clustered on `sample_id`.
      - To check whether your `LIMIT` and `WHERE` clauses are actually improving performance, you should see a lower value reported for actual "Data Scanned" by a query compared to the prediction ("This query will process X bytes") in STMO or the BigQuery UI.
    - If you are experimenting with data or exploring data, use one of the [data preview options](https://cloud.google.com/bigquery/docs/best-practices-costs#preview-data) instead of `SELECT *`.
        - Preview support is coming soon to BigQuery data sources in [re:dash](https://sql.telemetry.mozilla.org/)
- Limit the amount of data scanned by using a date partition filter
    - Tables that are larger than 1 TB will require that you provide a date partition filter as part of the query.
    - You will receive an error if you attempt to query a table that requires a partition filter.
        - `Cannot query over table 'moz-fx-data-shared-prod.telemetry_derived.main_summary_v4' without a filter over column(s) 'submission_date' that can be used for partition elimination`
    - See [_Writing Queries_](./querying.md#writing-queries) for examples.
- Reduce data before using a JOIN
    - Trim the data as early in the query as possible, before the query performs a JOIN. If you reduce data early in the processing cycle, shuffling and other complex operations only execute on the data that you need.
    - Use sub queries with filters or intermediate tables or views as a way of decreasing sides of a join, prior to the join itself.
- Do not treat WITH clauses as prepared statements
    - WITH clauses are used primarily for readability because they are not materialized. For example, placing all your queries in WITH clauses and then running UNION ALL is a misuse of the WITH clause. If a query appears in more than one WITH clause, it executes in each clause.
- Use approximate aggregation functions
    - If the SQL aggregation function you're using has an equivalent approximation function, the approximation function will yield faster query performance. For example, instead of using `COUNT(DISTINCT)`, use `APPROX_COUNT_DISTINCT()`.
    - See [approximate aggregation functions](https://cloud.google.com/bigquery/docs/reference/standard-sql/functions-and-operators#approximate-aggregate-functions) in the standard SQL reference.
- Reference the data size prediction ("This query will process X bytes") in STMO and the BigQuery UI to help gauge the efficiency of your queries. You should see this number go down as you limit the range of `submission_date`s or include fewer fields in your `SELECT` statement. For clustered tables, this estimate won't take into account benefits from `LIMIT`s and `WHERE` clauses on clustering fields, so you'll need to compare to the actual "Data Scanned" after the query is run. [Queries are charged by data scanned at $5/TB](https://cloud.google.com/bigquery/pricing#on_demand_pricing) so each 200 GB of data scanned will cost $1; it can be useful to keep the data estimate below 200 GB while developing and testing a query to limit cost and query time, then open up to the full range of data you need when you have confidence in the results.

You can locate a complete list of optimizations [here](https://cloud.google.com/bigquery/docs/best-practices-performance-overview) and cost optimizations [here](https://cloud.google.com/bigquery/docs/best-practices-costs)
