# Static Datasets

Tables containing static data exist in the `static` dataset in BigQuery.
These tables are generated from CSV files named `data.csv` in subdirectories of the `sql/<project>/static/`
directory in [`bigquery-etl`](https://github.com/mozilla/bigquery-etl/tree/master/sql/moz-fx-data-shared-prod/static).

## Creating a Static Table

To create a new table, create a directory in `sql/<project>/static/`.
This directory should be named whatever you wish the table to be named.
Then, put a CSV file named `data.csv` in the directory.
It is expected that the first line of `data.csv` is a header row containing the column
names of the data.

e.g. In `sql/moz-fx-data-shared-prod/static/new_table/data.csv`:

```
id,val
a,1
b,2
c,3
```

An optional `description.txt` and `schema.json` can be added. `description.txt` will fill the description
field in BigQuery. `schema.json` will set the schema of the table; if no schema is provided, it is assumed
that all fields are nullable strings.

See [`country_names_v1`](https://github.com/mozilla/bigquery-etl/tree/master/sql/moz-fx-data-shared-prod/static/country_names_v1) for an example.

To create the table in BigQuery, run [`script/publish_static`](https://github.com/mozilla/bigquery-etl/blob/master/script/publish_static).

### Notes

Static tables can be created in any dataset in bigquery-etl. However, it is recommended for consistency and
organization to keep them in the `static` dataset.
