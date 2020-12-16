# User states/segments

A user state is a group of clients who fit a set of criteria at a point in time.
The set of criteria itself can also be referred to as a "user state".

In data science these are normally called "segments"; for Firefox we call them "user states".

Typically you'll use user states to gain more insight into what is going on, by asking
"Regarding the thing I'm interested in,
do users in different user states behave differently,
and what insights does this give me into the users and the product?"
For example, "In this experiment, how do new users react to this feature,
and how does this differ from established users?".
Or "DAU moved dramatically -
is this restricted to users in this particular country (i.e. a user state)
where there's an event happening, which would raise our suspicions,
or is it global and therefore not solely due to that event?"

## Versioning

We are building out our library of user states,
and we want room to iterate to improve them in the future.
So please quote user states' versions with their names, e.g. "regular users v3"
so that your communication is forwards compatible.

## Current user states/segments

### Regular users v3

`clients_last_seen.is_regular_user_v3`

This user state contains clients who sent pings on _at least 14_ of the previous 27 days. As of February 2020 this user state contained approximately 2/3 of DAU and its users had a 1-week retention of around 95%.

### New or Resurrected v3

`clients_last_seen.is_new_or_resurrected_v3`

This user state contains clients who sent pings on _none_ of the previous 27 days. As of February 2020 this user state contained approximately 4% of DAU and its users had a 1-week retention of approximately 30%.

### Weekday regulars v1

`clients_last_seen.is_weekday_regular_v1`

This user state contains clients in _Regular users v3_ who typically use the browser only on weekdays. This user state is responsible for a slight majority of the weekly seasonality in DAU for _Regular users v3_. Of the previous 27 days, these users submitted a ping on at most one weekend day (UTC). Due to differing timezones, we allow flexibility: the "weekend" could be Friday/Saturday, Saturday/Sunday, or Sunday/Monday; we only ask that each client is self-consistent for the 27 day period.

### All-week regulars v1

`clients_last_seen.is_allweek_regular_v1`

This user state contains clients in _Regular users v3_ who do not fit in _Weekday regulars v1_ - clients that used the browser on a weekend at least twice in the previous 27 days. DAU for this user state does have some weekly seasonality, so some of the clients in this user state use the browser on weekdays preferentially, but not exclusively.

### Core Actives v1

`clients_last_seen.is_core_active_v1`

This user state contains clients that browsed at least 1 URI in at least 21 of the previous 28 days (including the current date). URI counts are derived from the column `scalar_parent_browser_engagement_total_uri_count_sum` in [`clients_daily`](../datasets/batch_view/clients_daily/reference.md) and [`clients_last_seen`](../datasets/bigquery/clients_last_seen/reference.md). Note that `is_core_active_v1` can be `true` on days where clients did not send a ping or browse at least 1 URI, so long as the aforesaid condition still holds.

### Activity Segments (informal)

`clients_last_seen.activity_segments_v1`

This column classifies each client-day based into one of four informal segments, defined below:

- `infrequent_user`: client that browsed at least 1 URI in at least 1 and up to 6 days in the past 28 days.

- `casual_user`: client that browsed at least 1 URI in at least 7 and up to 13 days in the past 28 days.

- `regular_user`: client that browsed at least 1 URI in at least 14 and up to 20 days in the past 28 days.
  (note that this differs from `regular_user_v3`)
- `core_user`: client that browsed at least 1 URI in at least 21 of the past 28 days.
- `other`: client does not meet any of the criteria above (i.e. they sent pings in at least 1 day out of the previous
  28 but did not browse any URIs).

Note that these are informal segments and are provided for convenience - one should not, for example, assume that
there are inherent differences between infrequent and casual users, for example. Also note that they do not divide up
the past 28 days evenly. One can use `clients_last_seen.days_visited_1_uri_bits` to define their own criteria if a
different breakdown is desired.

## Writing queries with user states/segments

When a user state is defined with respect to a user's _behavior_ (e.g. usage levels) as opposed to more stable
traits (e.g. country),
we should evaluate each user's user state eligibility
using data collected _before_ the time period in which we want to study their actions.
Else we run the risk of making trivial discoveries
like "heavy users use the product heavily" instead of more meaningful ones
like "heavy users go on to continue using the product heavily".

So, when writing queries to compute user states directly from their definition,
be sure to compute users' user states using only
data collected before the time period you're analyzing their behavior.

User states are found as columns in the `clients_last_seen` dataset: the user state listed for a client on a `submission_date` is valid for that `submission_date` because it is computed only using behavioral data collected _before_ the `submission_date`.

TODO: mention that user states are only really defined on days the user is active

### WAU and MAU

Users can move in or out of specific user states part way through a week or a month.
This poses a conundrum if we want to plot the WAU or MAU for a user state.

Our convention is to _count the number of distinct users who were active in the user state in the period_: e.g. "MAU(sent a ping as a regular user v3)".
So if a user was active as a regular user v3 on e.g. the second day of a 28-day window, then they will contribute to "regular user v3 MAU" regardless of whether they lost their "regular user v3" status at any point in the 28-day window.

Since many user states use the full extent of the `*_bits` column wizardry in `clients_last_seen`, you'll have to query WAU or MAU the old fashioned way:

```sql
WITH dates AS (
    SELECT *
    FROM UNNEST(GENERATE_DATE_ARRAY('2020-05-01', '2020-07-01')) as d
) SELECT
    dates.d AS submission_date,
    COUNT(DISTINCT client_id) * 100 AS regular_user_v3_mau,
FROM dates
INNER JOIN telemetry.clients_last_seen cls
    ON cls.submission_date BETWEEN DATE_SUB(dates.d, INTERVAL 27 DAY) AND dates.d
    AND cls.submission_date BETWEEN '2020-04-01' AND '2020-07-01'
WHERE cls.sample_id = 42
    AND cls.is_regular_user_v3
    AND cls.days_since_seen = 0
GROUP BY dates.d
ORDER BY dates.d
```

Our convention has the potentially counterintuitive consequence that a user can count towards "MAU(sent a ping as a regular user v3)" and "MAU(sent a ping as not a regular user v3)" for the same 28-day window.
If you need to break MAU down into the sum of MAU for various user states, then in this instance you would need to break it down into "only regular v3", "only not regular v3", and "both".

It might be tempting to assign users to whichever user state they happened to be in at the end of the window: this quantity is easy to query.
But many of the user states were defined to be meaningful _on days the users were active_.
"Regular users v3" is predictive of retention, _given that the user was active on the day of interest as a regular user_.
If someone has been using the browser every day for a year but then suddenly churns, then it's misleading to consider them to be active as a "not regular user v3" for MAU on the period ending the 15th day after their last activity.
A user can be "new or resurrected v3" for only one day in a 28-day period: unless they appear for the first time on the last day of the month, the user will not qualify as "new or resurrected v3" at the end of the MAU window!
So beware this trap and try to only use user states on days the users are active.

### Example queries

DAU for _regular users v3_:

```sql
SELECT
    submission_date,
    COUNTIF(is_regular_user_v3) AS dau_regular_users_v3
FROM moz-fx-data-shared-prod.telemetry.clients_last_seen
WHERE
    submission_date BETWEEN '2020-01-01' AND '2020-03-01'
    AND days_since_seen = 0  -- Get DAU from clients_last_seen
GROUP BY submission_date
```

DAU for _regular users v3_, but joining from a different table:

```sql
SELECT
    cd.submission_date,
    COUNTIF(is_regular_user_v3) AS dau_regular_users_v3
FROM clients_daily cd
INNER JOIN clients_last_seen cls
    ON cls.client_id = cd.client_id
    AND cls.submission_date = cd.submission_date
    AND cls.submission_date BETWEEN '2020-01-01' AND '2020-03-01'
WHERE
    cd.submission_date BETWEEN '2020-01-01' AND '2020-03-01'
```

Using `_is_core_active_v1_`:

Here are two basic ways to calculate a time series that counts the number of clients qualifying as Core Active:

1. On a 28 day basis. Here we ask: for a given 28 day period, how many clients qualify as Core Active on that day?
   This is equivalent to looking at a sliding 28 day window where we evaluate the 28 day history of each client on
   the last day of the window and ask whether they meet the criteria. This means that they do not necessarily have to
   be active (either sent a ping or browsed at least 1 URI) on the last day of the window to qualify. Below we show an
   example of a query that returns this time series.

```sql
SELECT submission_date,
    COUNTIF(is_core_active_v1) as number_core_actives
FROM telemetry.clients_last_seen
WHERE submission_date >= DATE_SUB(CURRENT_DATE, INTERVAL 7 DAY)
GROUP BY 1
ORDER BY 1
```

2. On a daily basis. Here we ask: of all the users who sent a ping on a given day, how many of them qualify as Core
   Active? In this case, we restrict ourselves to looking only at clients who reported telemetry (sent a main ping)
   on a given day, and then ask how many of them qualify as core active based on their history in the most recent
   28 day window. This is equivalent to asking what subset of DAU qualifies as Core Active. The query here is similar
   to the one above, with one addition to the WHERE clause:

```sql
SELECT submission_date,
    COUNTIF(is_core_active_v1) as number_core_actives
FROM telemetry.clients_last_seen
WHERE submission_date >= DATE_SUB(CURRENT_DATE, INTERVAL 7 DAY) AND days_since_seen = 0
GROUP BY 1
ORDER BY 1
```

## Obsolete user states

### Usage regularity v2

This is a set of three segments.
On a given day, every client falls into exactly one of these segments.
Each client's segment can be computed from `telemetry.clients_last_seen.days_visited_5_uri_bits`.

_Regular users v2_ is defined as
clients who browsed >=5 URIs on _at least eight_ of the previous 27 days.
As of February 2020 this segment contained approximately 2/3 of DAU
and its users had a 1-week retention for a 5 URI day usage criterion of approximately 95%.

_New/irregular users v2_ is defined as
clients who browsed >=5 URIs on _none_ of the previous 27 days.
As of February 2020 this segment contained approximately 15% of DAU,
and had a retention for a 5 URI day usage criterion of about 10%
(though "activation" is likely a more relevant word than "retention" for many of these clients).

_Semi-regular users v2_ is defined as
clients who browsed >=5 URIs on _between one and seven_ of the previous 27 days,
i.e. it contains users who do not fit the other two segments at this time.
As of February 2020 this segment contained approximately 20% of DAU,
and had a retention for a 5 URI day usage criterion of about 60%.
We do not yet know what proportion of users in this segment stay in this segment for an extended period, and what proportion are in transition between other segments.
