# SSL Ratios

<!-- toc -->

# Introduction

{{#include ./intro.md}}

# Data Reference

## Combining Rows

This is a dataset of ratios. You can't combine ratios if they have different bases. For example,
if 50% of 10 loads (5 loads) were SSL and 5% of 20 loads (1 load) were SSL, you cannot calculate
that 20% (6 loads) of the total loads (30 loads) were SSL unless you know that the 50% was for
10 and the 5% was for 20.

If you're reluctant, for product reasons, to share the numbers 10 and 20, this gets tricky.

So what we've done is normalize the whole batch of 30 down to 1. That means we tell you that
50% of one-third of the loads (0.333...) was SSL and 5% of the other two-thirds of the loads
(0.666...) was SSL. Then you can figure out the overall 20% figure by this calculation:

`0.5 * 0.333 + 0.05 * 0.666 = 0.2`

For this dataset the same rule applies. To combine rows' ratios (to, for example, see what the
SSL ratio was across all `os` and `country` for a given `submission_date`), you must first
multiply them by the rows' `normalized_pageviews` values.

Or, in JavaScript:

```js
let rows = query_result.data.rows;
let ratioForDateInQuestion = rows
  .filter((row) => row.submission_date == dateInQuestion)
  .reduce((row, acc) => acc + row.normalized_pageloads * row.ratio, 0);
```

## Schema

The data is output in STMO API format:

```
"query_result": {
  "retrieved_at": <timestamp>,
  "query_hash": <hash>,
  "query": <SQL>,
  "runtime": <number of seconds>,
  "id": <an id>,
  "data_source_id": 26, // Athena
  "data_scanned": <some really large number, as a string>,
  "data": {
    "data_scanned": <some really large number, as a number>,
    "columns": [
      {"friendly_name": "submission_date", "type": "datetime", "name": "submission_date"},
      {"friendly_name": "os", "type": "string", "name": "os"},
      {"friendly_name": "country", "type": "string", "name": "country"},
      {"friendly_name": "reporting_ratio", "type": "float", "name": "reporting_ratio"},
      {"friendly_name": "normalized_pageloads", "type": "float", "name": "normalized_pageloads"},
      {"friendly_name": "ratio", "type": "float", "name": "ratio"}
    ],
    "rows": [
      {
        "submission_date": "2017-10-24T00:00:00", // date string, day resolution
        "os": "Windows_NT", // operating system family of the clients reporting the pageloads. One of "Windows_NT", "Linux", or "Darwin".
        "country": "CZ", // ISO 639 two-character country code, or "??" if we have no idea. Determined by performing a geo-IP lookup of the clients that submitted the pings.
        "reporting_ratio": 0.006825266611977031, // the ratio of pings that reported any pageloads at all. A number between 0 and 1. See [bug 1413258](https://bugzilla.mozilla.org/show_bug.cgi?id=1413258).
        "normalized_pageloads": 0.00001759145263985348, // the proportion of total pageloads in the dataset that are represented by this row. Provided to allow combining rows. A number between 0 and 1.
        "ratio": 0.6916961976822144 // the ratio of the pageloads that were performed over SSL. A number between 0 and 1.
      }, ...
    ]
  }
}
```

## Scheduling

The dataset updates every 24 hours.

## Public Data

The data is publicly available on BigQuery: `mozilla-public-data.telemetry_derived.ssl_ratios_v1`.
Data can also be accessed through the public HTTP endpoint: [https://public-data.telemetry.mozilla.org/api/v1/tables/telemetry_derived/ssl_ratios/v1/files](https://public-data.telemetry.mozilla.org/api/v1/tables/telemetry_derived/ssl_ratios/v1/files)

## Code Reference

You can find the query that generates the SSL dataset
[here](https://sql.telemetry.mozilla.org/queries/49323/source#table).
