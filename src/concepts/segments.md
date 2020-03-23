# Segments

A segment is a group of clients who fit a set of criteria at a point in time. 
The set of criteria itself can also be referred to as a "segment".

Typically you'll use segments to gain more insight into what is going on, by asking 
"Regarding the thing I'm interested in, 
do users in different segments behave differently, 
and what insights does this give me into the users and the product?" 
For example, "In this experiment, how do new users react to this feature, 
and how does this differ from established users?". 
Or "DAU moved dramatically - 
is this restricted to users in this particular country (i.e. a segment) 
where there's an event happening, which would raise our suspicions,
or is it global and therefore not solely due to that event?"

## Versioning

We are building out our library of segments, 
and we want room to iterate to improve them in the future. 
So please quote segments' versions with their names, e.g. "regular users v1"
so that your communication is forwards compatible.

## Current segments

### Regular users v1, Semi-regular users v1, New/irregular users v1

This is a set of three segments. 
On a given day, every client falls into exactly one of these segments.
Each client's segment is stored in `telemetry.clients_last_seen.segment_regular_users_v1`.
(FIXME: or it will be if the [PR](https://github.com/mozilla/bigquery-etl/pull/825) is accepted in a form similar to its current state)

*Regular users v1* is defined as 
clients who have at least two days where they browsed >=5 URIs, 
in *all* of the last four weeks. 
Observationally, on any given day this segment seems to contain a large fraction of our users 
and has exceptionally high retention.

*New/irregular users v1* is defined as 
clients who browsed >=5 URIS on at least two days in *none* of the last four weeks. 
This is a smaller segment of our users and has low retention 
(though "activation" is likely a more relevant word than "retention" for many of these clients).

*Semi-regular users v1* is the other users: the segment is defined as 
clients who browsed >=5 URIs on at least two days in *some but not all* of the last four weeks. 
This seems to be a smaller segment of our users, and has relatively high retention.

In each of these definitions, 
"the last four weeks" refer to 7 day periods that end on the day of week 
before the first day for which we want to study the user. 
They do not necessarily run Monday through Sunday.

## Obsolete segments

None yet.

## Writing queries with segments

When a segment is defined with respect to a user's _behavior_ (e.g. usage levels) 
as opposed to more stable traits (e.g. country), 
we should evaluate each user's segment eligibility 
using data collected _before_ the time period in which we want to study their actions. 
Else we run the risk of making trivial discoveries 
like "heavy users use the product heavily" instead of more meaningful ones 
like "heavy users go on to continue using the product heavily".

So, when writing queries, 
be sure to compute users' segments using only 
data collected before the time period you're analysing their behavior. 
For example, we should compute DAU for the "regular users v1" segment on 2020-03-18 
by checking the usage criterion with data up to and including 2020-03-17.

Segments are found as columns in the `clients_last_seen` dataset: the segment listed for a client on a `submission_date` is valid for that `submission_date` because it is computed only using behavioral data collected _before_ the `submission_date`.

### WAU and MAU

Users can change segments part way through a week or a month. 
When computing MAU for a segment, 
include all clients that fit that segment for at least one day they were active in the month, 
regardless of whether they fit a contradictory segment on another active day. 
This means that the sum of MAU for each non-overlapping segment can be larger than MAU.
(FIXME: This point needs special attention in the review process - it appears to be the best option)


### Example queries

DAU for regular users v1:
```lang=sql
SELECT
    submission_date,
    COUNT(DISTINCT client_id) AS dau_regular_v1
FROM moz-fx-data-shared-prod.telemetry.clients_last_seen
WHERE
    submission_date BETWEEN '2020-01-01' AND '2020-03-01'
    AND segment_regular_users_v1 = 'regular_v1'
    AND days_since_seen = 0  -- Get DAU from clients_last_seen
GROUP BY submission_date
```

MAU for regular users v1:
```lang=sql
SELECT
    cd.submission_date,
    COUNT(DISTINCT cd.client_id) AS mau_regular_v1
FROM moz-fx-data-shared-prod.telemetry.clients_daily cd
INNER JOIN moz-fx-data-shared-prod.telemetry.clients_last_seen cls
    ON cls.client_id = cd.client_id
    AND DATE_DIFF(cd.submission_date, cls.submission_date, DAY) BETWEEN 0 and 27
    AND cls.segment_regular_users_v1 = 'regular_v1'
    AND cls.submission_date BETWEEN
        DATE_SUB('2020-01-01', INTERVAL 27 DAY) AND '2020-03-01'
WHERE
    cd.submission_date BETWEEN '2020-01-01' AND '2020-03-01'
GROUP BY cd.submission_date
```

The "new/irregular users v1" segment has a subtlety: its users don't necessarily have a 28-day-old entry in `clients_last_seen`, so we must use a `LEFT JOIN` and manually handle `NULL`s. MAU for new/irregular users v1:
```lang=sql
SELECT
    cd.submission_date,
    COUNT(DISTINCT cd.client_id) AS mau_new_irregular_v1
FROM moz-fx-data-shared-prod.telemetry.clients_daily cd
LEFT JOIN moz-fx-data-shared-prod.telemetry.clients_last_seen cls
    ON cls.client_id = cd.client_id
    AND cls.submission_date BETWEEN
        DATE_SUB('2020-01-01', INTERVAL 27 DAY) AND '2020-03-01'
WHERE
    cd.submission_date BETWEEN '2020-01-01' AND '2020-03-01'
    AND (
        cls.segment_regular_users_v1 IS NULL
        OR cls.segment_regular_users_v1 = 'new_irregular_v1'
    )
GROUP BY cd.submission_date
```
