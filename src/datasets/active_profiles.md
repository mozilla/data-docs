# Intro

The `active_profiles` dataset gives client-level estimates of whether a profile
is still an active user of the browser at a given point in time, as well as probabilistic forecasts
of the client's future activity. These quantities are estimated by a model that attempts to infer
and decouple a client's latent propensity to leave Firefox and become inactive, as well as their
latent propensity to use the browser while still active. These estimates are currently
generated for release desktop browser profiles only, across all operating systems and
geographies.

# Model

The model generates predictions for each client by looking at just the recency and frequency of a
client's daily usage within the previous 90 day window. Usage is defined by the daily level binary
indicator of whether they show up in `clients_daily` on a given day.

The table contains columns related to these quantities:

- `submission_date`: Day marking the end of the 90 day window. Earliest `submission_date` that
  the table covers is `'2019-05-13'`.
- `min_day`: First day in the window that the client was seen. This could be anywhere between
  the first day in the window and the last day in the window.
- `max_day`: Last day in the window the client was seen. The highest value this can be is
  `submission_date`.
- `recency`: Age of client in days.
- `frequency`: Number of days in the window that a client has returned to use the browser
  after `min_day`.
- `num_opportunities`: Given a first appearance at `min_day`, what is the highest number of
  days a client could have returned. That is, what is the highest possible value for `frequency`.

Since the model is only using these 2 coarse-grained statistics, these columns should make it
relatively straightforward to interpret why the model made the predictions that it did for a given
profile.

## Latent quantities

The model estimates the expected value for 2 related latent probability variables for a user. The
values in `prob_daily_leave` give our expectation of the probability that they will become inactive
on a given day, and `prob_daily_usage` represents the probability that a user will return on a given
day, _given that they are still active_.

These quantities could be useful for disentangling usage _rate_ from the likelihood that a user is
still using the browser. We could, for example, identify intense users who are at risk of
churning, or users who at first glance appear to have churned, but are actually just infrequent
users.

`prob_active` is the expected value of the probability that a user is still active on
`submission_date`, given their most recent 90 days' of activity. 'Inactive' in this sense
means that the profile will not use the browser again, whether because they have uninstalled
the browser or for some other reason.

## Predictions

There are several columns of the form `e_total_days_in_next_7_days`, which give the expected
number of times that a user will show up in the next 7 days (or 14, 21, 28 days). These
predictions take into account both the likelihood that a user will become inactive in the
future, as well as their daily propensity to use the browser, given that they are still active.
The values in `e_total_days_in_next_7_days` will be between 0 and 7.

An estimate for the probability that a client will contribute to MAU is available in the
column `prob_mau`. This is simply the probability that the user will return at any point in
the following 28 days, thereby contributing to MAU. Since it is a probability, the values will
range between 0 and 1, just like `prob_daily_leave` and `prob_daily_usage`.

## Attributes

There are several columns that contain attributes of the client, like `os`, `locale`,
`normalized_channel`, `normalized_os_version`, and `country`. `sample_id` is also included,
which can be useful for quicker queries, as the table is clustered by this column in BigQuery.

## Remarks on the model

A way to think about the model that infers these quantities is to imagine a simple process
where each client is given 2 weighted coins when they become users, and that they flip each
day. Since they're weighted, the probability of heads won't be 50%, but rather some probability
between 0 and 100%, specific to each client's coin. One coin, called `L`, comes up heads with
probability `prob_daily_leave`, and if it ever comes up heads, the client will never use the
browser again. The daily usage coin, `U`, has heads `prob_daily_usage`% of the time. _While
they are still active_, clients flip this coin to decide whether they will use the browser
on that day, and show up in `clients_daily`.

The combination of these two coin flipping processes results in a history of activity that we
can see in `clients_daily`. While the model is simple, it has very good predictive power that
can tell, _in aggregate_, how many users will still be active at some point in the future.
A downside of the model's simplicity, however, is that its predictions are not highly tailored
to an individual client. The very simplified features do not take into account things like
seasonality, or finer grained attributes of their usage (like active hours, addons, etc.).
Further, the predictions in this table only account for existing users that have been seen in
the 90 days of history, and so longer term forecasts of user activity would need to somehow model
new users separately.

# Caveats and future work

Due to the lightweight feature space of the model, the predictions perform better at the
population level rather than the individual client level, and there will be a lot of client-level
variation in behavior. That is, when grouping clients by different dimensions, say all of the
`en-IN` users on Darwin, the _average_ MAU prediction should be quite close, but a lot of users'
behavior can deviate significantly from the predictions.

The model will also be better at medium- to longer- term forecasts. In particular, the model
will not be well suited to give predictions for new users who have appeared only once in the data
set very recently. These constitute a disproportionately large share of users, but do not
have enough history for this model to make good use of.
These single day profiles are currently the subject of
[an investigation](https://bugzilla.mozilla.org/show_bug.cgi?id=1507073)
that will hopefully yield good heuristics for users that only show up for a single day.

# Sample query

[Here](https://console.cloud.google.com/bigquery?sq=630180991450:648f8e0a2faa4d86847fe8d27daf1938) is
a sample query that will give averages for predicted MAU, probability that users are still
active, and other quantities across different operating systems:

```sql
SELECT
  os,
  cast(sum(prob_mau) AS int64) AS predicted_mau,
  count(*) AS n,
  round(avg(prob_active) * 100, 1) AS prob_active,
  round(avg(prob_daily_leave) * 100, 1) AS prob_daily_leave,
  round(avg(prob_daily_usage) * 100, 1) AS prob_daily_usage,
  round(avg(e_total_days_in_next_28_days), 1) AS e_total_days_in_next_28_days
FROM
  `telemetry.active_profiles`
WHERE
  submission_date = '2019-08-01'
  AND sample_id = 1
GROUP BY
  1
HAVING
  count(*) > 100
ORDER BY
  avg(prob_daily_usage) DESC
```

## Scheduling

The code behind the model can be found in the [`bgbb_lib` repo](https://github.com/wcbeard/bgbb_lib/),
or on [PyPI](https://pypi.org/project/bgbb/). The airflow job is defined in the
[`bgbb_airflow` repo](https://github.com/wcbeard/bgbb_airflow).

The model to fit the parameters is run weekly, and the table is updated daily.
