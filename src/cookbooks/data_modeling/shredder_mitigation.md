# Shredder mitigation process

Running a backfill on aggregate tables at Mozilla comes with the high risk of altering reported metrics due to the effects of [shredder](https://mozilla-hub.atlassian.net/wiki/spaces/DATA/pages/6848694/Shredder). It is essential for the business to mitigate these risks while still allowing the addition and modification of columns in aggregate tables to enhance analytic capabilities or propagate changes in business definitions. At the same time, this mitigation must happen in alignment with [Mozilla data protection policies](https://www.mozilla.org/en-US/privacy/firefox/) by preventing aggregate tables from maintaining data that could be used to uniquely identify shredded clients.

**Shredder mitigation** is a process that breaks through this risk by securely executing backfills on aggregate tables. It recalculates metrics using both existing and new data, mitigating the impact of shredder and propagating business definition changes while maintaining data integrity over time.

This documentation provides step-by-step guidance with examples and common scenarios, to help you achieve consistent results.

For context and details on previous analysis and discussions that lead to this solution, refer to the [proposal](https://docs.google.com/document/d/1lU7qSjAOFrdcQuDbdhFzJLgP6Mkn6L8XBjRtFdq6qkU/edit?usp=sharing).

<!-- toc -->

## When to use this process

Shredder mitigation should be used to backfill aggregate tables when business requirements call for metrics to remain consistent and unchanged over time.

Some examples of aggregates where this process is applicable are:

- KPI and OKR aggregates.
- Search aggregates.

#### Use cases

- Add a new dimension or metric to an aggregate.
- Propagate upstream changes to an existing dimension or metric in the aggregate.

## How this process transforms your workflow

- With this process, you can now safely backfill aggregate tables, which previously carried high risks of affecting KPIs, metrics or forecasting.
  Now, it's straightforward: Create a managed backfill with the `--shredder-mitigation` parameter, and you're set!
- The process automatically generates a query that mitigates the effect of shredder and which is automatically used for that specific backfill.
- Clearly identifies which aggregate tables are set up to use shredder mitigation.
- Prevents an accidental backfill with mitigation on tables that are not set up for the process.
- Supports the most common data types used in aggregates.
- Provides a comprehensive set of informative and debugging messages, especially useful during first-time runs where many columns may need updating.
- Each process run is documented, along with its purpose.

## What to expect after running a backfill with shredder mitigation

- A new version of the aggregate table is available, incorporating all new added or modified columns.
- Totals for each column remain stable.
- Subtotals are adjusted for modified or newly added columns, with `NULL` values increasing by the amount corresponding to the shredded client IDs.

## Key considerations before using shredder mitigation for the first time

1. This process ensures it is triggered only for tables set up for this type of backfill, which you can accomplish by ensuring that:

   - `GROUP BY` is explicit in all versions of the query, avoiding expressions like `GROUP BY ALL`, `GROUP BY 1, 2`.
   - All columns have descriptions that if applicable, include the date when new columns become available.
   - The query and schema don't include [id-level columns](https://github.com/mozilla/bigquery-etl/blob/main/bigquery_etl/metadata/id_level_columns.yaml).
   - The table metadata includes the label `shredder_mitigation: true`.

2. Metrics totals will only match if all columns with upstream changes are processed in addition to your own modifications, which can be achieved by renaming any column with upstream or local changes yet to be propagated, both in query and schema.

3. Metrics totals for `NULL` data will only match if the same logic for `NULL` is applied in all versions of the query. Particularly, `country` and `city` are columns where `NULL` values are usually set to `'??'`.

4. It is recommended to always run the process on a `small period of time` or a subset of data to identify potential mismatches and required changes before executing a complete backfill.

#### Columns with recent changes that may require propagation to aggregates

- `first_seen_date` and `first_seen_year` where the business logic for Firefox Desktop changed in 2023-Q4 to integrate data from 3 different pings.
- `segment` where the business logic for all browsers changed in 2024-H1 to integrate the DAU definition to the segmentation of clients.
- `os_version` where the logic now integrates the`build_version` for Windows operating systems.
- `dau`, `wau` and `mau` where the business logic changed in 2024-H1 with new qualifiers.

## Run a managed backfill with shredder mitigation

The following steps outline how to use the shredder mitigation process:

1. Bump the version of the aggregate query.
1. Make the necessary updates to the new version of the query and schema:
   - Include new columns in the query with their corresponding description in the schema and the date when they become available, if relevant.
   - Update existing columns and rename them in the file to ensure they are also recalculated. If you need to avoid changes in Looker, set the expected column name in the view.
1. Use a [managed backfill](https://mozilla.github.io/bigquery-etl/cookbooks/creating_a_derived_dataset/#backfilling-a-table) for the new query version, with the `--shredder_mitigation` parameter.

That's all! All steps are complete.

## Troubleshooting scenarios and guidelines

This section describes scenarios where mismatches in the metrics between versions could occur and the recommended approach to resolution.

1. Dimensions with upstream changes that haven't propagated to your aggregate and show metrics mismatches between versions after the backfill. Follow these steps to resolve the issue

   - Run a backfill with shredder mitigation for a small period of time.
   - Validate the totals for each dimension and identify any columns with mismatches. Investigate whether the column had upstream changes and if so, rename it to ensure it is recalculated in your aggregate. Refer to the [list of known columns with recent changes](#columns-with-recent-changes-that-may-require-propagation-to-aggregates) above for guidance.
   - Check the distribution of values in columns with mismatches and identify any wildcards used for NULL values. Then apply the same logic in the new query.

2. The process halts and returns a detailed failure message that you can resolve by providing the missing information or correcting the issue:

   - Either the previous or the new version of the query is missing.
   - The metadata of the aggregate to backfill does not contain the `shredder_mitigation: true` label.
   - The previous or new version of the query contains a `GROUP BY` that is invalid for this process, such as `GROUP BY 1, 2` or `GROUP BY ALL`.
   - The schema is missing, is not updated to reflect the correct column names and data types, or contains columns without descriptions.

3. The sql-generated queries are not yet supported in managed backfills, so run `bqetl query generate <name>` in advance for this case.

## Validation steps

As part of the managed backfill, it is recommended to validate the following, along with any other specific validations that you may require:

- Metrics totals per dimension match those in the previous version of the table.
- Metric sub-totals for the new or modified columns match the upstream table. Remaining subtotals are reflected under NULL for each column.
- All metrics remain stable and consistent.

## Examples for First-Time and subsequent runs

This section contains examples both for first-time and subsequent runs of a backfill with shredder mitigation.

Let's use as an example a requirement to modify `firefox_desktop_derived.active_users_aggregates_v3` to:

- Update the definition of existing column `os_version`.
- Remove column `attributed`.
- Backfill data.

After running the backfill, we expect the distribution of `os_version` to change with an increase in NULL values. Additionally, column `attributed` will no longer be present, and the totals for each column will remain unchanged.

### Example 1. Regular runs

This example applies when the `active_users_aggregates_v3` already has the label `shredder_mitigation` and upstream changes propagated, which makes the process as simple as:

- Bump the version of the table to `active_users_aggregates_v4` to implement changes in these files.
- Remove column `attributed` and update the definition of `os_version` in both query and schema. Rename `os_version` to `os_version_build` to ensure that it is recalculated. The schema descriptions remain valid.
- Follow the [managed backfill](https://mozilla.github.io/bigquery-etl/cookbooks/creating_a_derived_dataset/#backfilling-a-table) process using the `--shredder_mitigation` parameter.

And it's done!

### Example 2. First-Time run

This example is for a first-run of the process, which requires setting up `active_users_aggregates_v3` and further versions appropriately, also propagating upstream changes.

Customize this example to your own requirements.

##### Initial analysis

The aggregate table `active_users_aggregates_v3` contains Mozilla reported KPI metrics for Firefox Desktop, which makes it a suitable candidate to use the shredder mitigation process.

Since this is the first time the process runs for this table, we will follow the [Considerations before using shredder mitigation for the first time](#key-considerations-before-using-shredder-mitigation-for-the-first-time) above.

##### Preparation for the backfill

In preparation for the process, the first step is to get the table `active_users_aggregates_v3` ready for this type of backfill. Subsequent versions that will use shredder mitigation should also follow these standards, in our case `active_users_aggregates_v4`.

We need these changes:

- Replace `GROUP BY ALL` with the explicit list of columns in both versions of the query.
- Replace the definition of `city` to `IFNULL(city, '??') AS city` for consistent logic in query versions and data.
- Add descriptions to all columns in the schema.
- Include the label `shredder-mitigation: true` in the metadata of the table.
- Merge a Pull Request to apply these changes.

##### Changes related to the requirement

- Bump the version of the table to `active_users_aggregates_v4` and make changes to the new version files.
- Since `os_version` is already present in the table, we need to update its definition _and also rename it to_ `os_version_build` both in query and schema to ensure that it is recalculated. The schema description remains valid.
- Remove column `attributed` from the query and schema.

##### Changes to update columns with upstream changes yet to be propagated:

- Existing column `first_seen_year` is renamed to `first_seen_year_new` and `segment` is renamed to `segment_dau`, as both have upstream changes.
- Merge a PR to apply all changes.

##### Run the backfill:

- Follow the [managed backfill](https://mozilla.github.io/bigquery-etl/cookbooks/creating_a_derived_dataset/#backfilling-a-table) process using the `--shredder_mitigation` parameter.

## Validations

Recommended data validations include:

- Use `SELECT EXCEPT DISTINCT` to identify rows in the previous version of the table that are missing in the new version, which was just backfilled. This command performs a 1:1 comparison by checking both dimensions and metrics.
- Calculate subtotals per column, ensuring you use `COALESCE` for an accurate comparison of `NULL` values, and verify that all values match the upstream sources, except for `NULL` which is expected to increase.

# FAQ

1. Can I run this process to update one column at a time and still achieve the same result?

   Yes, the process allows you to add one column at a time, as long as all columns with upstream changes have been properly propagated to your aggregate table.
   However, this is not the recommended practice as it will lead to multiple table versions and reprocessing data several times, increasing costs. On the plus side, it may facilitate rollback of single changes if needed, so use your best criteria.

2. After following the guidelines I still have a mismatch. Where can I get for help?

   If you need assistance, have suggestions to improve this documentation, or would like to share any recommendations, feel free to reach out to the **Analytics Engineering** team or post a message in #data-help!
