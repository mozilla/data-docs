`mobile_search_clients_engines_sources_daily` is designed to enable client-level search analyses for mobile.
Querying this dataset can be slow;
consider using `mobile_search_aggregates` for coarse analyses.

## Contents

`mobile_search_clients_engines_sources_daily` has one row for each unique combination of:
(`client_id`, `submission_date`, `engine`, `source`).

Alongside standard search metrics, this dataset includes client specific descriptive information as well.
For example, we include `normalized_app_name` and `normalized_app_name_os` for each row of data. `normalized_app_name` modifies the raw `app_name` data to align it more consistently with KPI reporting while `normalized_app_name_os` combines app name and os used by each client. Refer to the table below for comprehensive mapping details regarding these two fields.

| `app_name`            | `os`    | `normalized_app_name_os`     | `normalized_app_name` |
| --------------------- | ------- | ---------------------------- | --------------------- |
| `Fenix`               | Android | Firefox Android              | Firefox               |
| `Fennec`              | Other   | Fennec Other                 | Fennec                |
| `Fennec`              | Android | Legacy Firefox Android       | Fennec                |
| `Fennec`              | iOS     | Firefox iOS                  | Firefox               |
| `Firefox Preview`     | Android | Firefox Preview              | Firefox Preview       |
| `FirefoxConnect`      | Android | Firefox for Echo Show        | Firefox for Echo Show |
| `FirefoxForFireTV`    | Android | Firefox for FireTV           | Firefox for FireTV    |
| `Focus Android Glean` | Android | Focus Android                | Focus                 |
| `Focus iOS Glean`     | iOS     | Focus iOS                    | Focus                 |
| `Klar Android Glean`  | Android | Klar Android                 | Klar                  |
| `Klar iOS Glean`      | iOS     | Klar iOS                     | Klar                  |
| `Other`               | iOS     | Other iOS                    | Other                 |
| `Other`               | Other   | Other                        | Other                 |
| `Other`               | Android | Other Android                | Other                 |
| `Zerda`               | Android | Firefox Lite Android         | Firefox Lite          |
| `Zerda_cn`            | Android | Firefox Lite Android (China) | Firefox Lite (China)  |

Note that, if there were no such searches in a row's segment
(i.e. the count would be 0),
the column value is `null`.
Each of these columns represent different types of searches.
For more details, see the [search data documentation]

## Background and Caveats

`mobile_search_clients_engines_sources_daily` does not include
(`client_id` `submission_date`) pairs
if we did not receive a ping for that `submission_date`.

We impute a `NULL` `engine` and `source` for pings with no search counts.
This ensures users who never search are included in this dataset.

This dataset is large.
If you're querying this dataset from STMO,
heavily limit the data you read using `submission_date` or `sample_id`.

As of August 1, 2024, the `mobile_search_clients_daily` table has been updated to extract data from the `baseline` ping tables instead of the original `metrics` ping tables. This shift maintains the same search totals with greater confidence in the mobile search engagement dates. 

As [noted](https://docs.telemetry.mozilla.org/concepts/analysis_gotchas.html?highlight=submission)#submission-date), the `submission_date` used throughout telemetry is the date Mozilla received that client's engagement, not necessarily the actual date on which that client engaged with Firefox. Mobile `metrics` pings are historically sent later than the actual date of activity: it takes roughly [4 days for Firefox to receive 95% of Fenix `metrics` pings](https://sql.telemetry.mozilla.org/queries/92717) which originate from a given actual date. `Baseline` pings are more frequently sent/ received and serve as the basis of KPI DAU metrics. Therefore, this switch ensures client KPI activity can be matched to search activity from that same active day.  

The view, accessible via `mozdata.search.mobile_search_clients_daily`, pulls metrics ping data from `mobile_search_clients_daily_historical` prior to August 1, 2024 and baseline ping data from `mobile_search_clients_daily_v2` after August 1, 2024.

[search data documentation]: ../../search.md
