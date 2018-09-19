Public crash statistics for Firefox are available through the Data Platform in a `socorro_crash` dataset.
The crash data in [Socorro](https://wiki.mozilla.org/Socorro) is sanitized and made available to ATMO and STMO.
A nightly import job converts batches of JSON documents into a columnar format using the associated JSON Schema. 

### Contents
#### Accessing the Data
The dataset is available in parquet at `s3://telemetry-parquet/socorro_crash/v2`.
It is also indexed with Athena and Presto with the table name `socorro_crash`.

