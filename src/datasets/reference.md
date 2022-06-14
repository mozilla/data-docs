# Dataset Reference

This section contains reference material on some of the major datasets we store in BigQuery.
Reading this section front to back is not recommended.
Instead, identify a dataset you'd like to understand better and read through
the relevant documentation.
After reading the tutorial, you should know all you need about the dataset.

Also see more detailed [per-table docs](https://mozilla.github.io/bigquery-etl/mozdata/introduction/)
that are generated alongside ETL code in the `bigquery-etl` repository.

Each tutorial should include:

- Introduction
  - A short overview of why we built the dataset and what need it's meant to solve
  - What data source the data is collected from,
    and a high level overview of how the data is organized
  - How it is stored and how to access the data
- Reference
  - An example query to give the reader an idea of what the data looks like
    and how it is meant to be used
  - How the data is processed and sampled
  - How frequently it's updated, and how it's scheduled
  - An up-to-date schema for the dataset
  - How to augment or modify the dataset
