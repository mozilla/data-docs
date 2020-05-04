# Accessing and working with BigQuery

With the transition to [GCP](https://cloud.google.com) in 2019 having been completed, BigQuery has become Mozilla's primary data warehouse and SQL Query engine.

The following topics provide an introduction to working with data that is stored
in [BigQuery](https://cloud.google.com/bigquery/):

- [Accessing BigQuery](./bigquery/access.md)
- [Writing BigQuery Queries](./bigquery/querying.md)
- [Optimizing BigQuery Queries](./bigquery/optimization.md)

BigQuery uses a columnar data storage format that is called [Capacitor](https://cloud.google.com/blog/products/gcp/inside-capacitor-bigquerys-next-generation-columnar-storage-format).It supports semi-structured data.

There is a cost associated with using BigQuery based on operations. The on-demand pricing for queries is based on how much data a query scans. If you want to:

- Minimize costs, see [_Query Optimizations_](bigquery/querying.md#optimizations). 
- Familiarize yourself with the detailed information about pricing, see [pricing](https://cloud.google.com/bigquery/pricing).
