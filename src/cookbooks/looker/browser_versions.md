# Normalizing Browser Version Data

This how-to guide is about getting numerical browser version data in your Looker Explores, Looks and Dashboards:

This guide only has one step: Normalizing Version Strings

> ⚠️ Some steps in this guide require knowledge of SQL - ask in #data-help for assistance if needed.

Many of our data sources (particularly browser telemetry) have `version_id`'s: A string that (most of the time) 
looks like `"99.1.0"` in the format `"major.minor.patch"`.

> ⚠️ In SQL you might be tempted to compare these version identifiers. This might however, return misleading results! 
> `"99" > "100"` but `99 < 100`. Note the string vs number comparison.

## Step One - Normalizing Version Strings

In your `view.sql` file, locate the browser version identifier. In many tables/views, this is called `app_version`.

To extract the numerical version data you have two options:

### 1. The [truncate version UDF](https://mozilla.github.io/bigquery-etl/mozfun/norm/#truncate_version-udf) - `truncate_version`
This extracts the major or minor version from the version identifier. See the Mozfun Docs for a detailed description.

Modify your `view.sql`:
```SQL
CREATE OR REPLACE VIEW
  `project.dataset.view`
AS
SELECT
  *,
  `mozfun.norm.truncate_version`(app_version, "major") as major_browser_version  --  <--- New Line
FROM
  `project.dataset_derived.table`
```

`major_version` will be added as a new field containing the numerical major browser version. 

### 2. The [browser version info UDF](https://mozilla.github.io/bigquery-etl/mozfun/norm/#browser_version_info-udf) - `browser_version_info`
This extracts a number of useful fields from the version identifier. See the Mozfun Docs for a detailed description.

Modify your `view.sql`: 
```SQL
CREATE OR REPLACE VIEW
  `project.dataset.view`
AS
SELECT
  *,
  `mozfun.norm.browser_version_info`(app_version) as browser_version_info  --  <--- New Line
FROM
  `project.dataset_derived.table`
```

`browser_version_info` will be added as a new struct field containing numerical version fields and other useful metadata. 


After choosing an option, open a Pull Request ([for example](https://github.com/mozilla/bigquery-etl/pull/2898)) and get a review. 
Once your change is merged, the updated field will be available in Looker once the lookml-generator runs 
(usually by the next calendar day, or [by manually running it on Airflow](https://github.com/mozilla/lookml-generator/#deploying-new-lookml-generator-changes)).