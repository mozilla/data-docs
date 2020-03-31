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

### Usage regularity v1

This is a set of three segments. 
On a given day, every client falls into exactly one of these segments.
Each client's segment is stored in `telemetry.clients_last_seen.segment_usage_regularity_v1`.


*Regular users v1* is defined as 
clients who browsed >=5 URIs on at least _one_ of the previous 6 days, and browsed >=5 URIs on _at least two_ days in each of the three weeks before that. 
Observationally, on any given day this segment seems to contain a large fraction of our users 
and has exceptionally high retention.

*New/irregular users v1* is defined as 
clients who did not browse >=5 URIs on any of the previous 6 days, and browsed >=5 URIs on _less than two_ days in each of the three weeks before that.
This is a smaller segment of our users and has low retention 
(though "activation" is likely a more relevant word than "retention" for many of these clients).

*Semi-regular users v1* contains the other clients.  
This seems to be a smaller segment of our users, and has relatively high retention.

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
data collected before the time period you're analyzing their behavior.
For example, we should compute DAU for the "regular users v1" segment on 2020-03-18 
by checking the usage criterion with data up to and including 2020-03-17.

Segments are found as columns in the `clients_last_seen` dataset: the segment listed for a client on a `submission_date` is valid for that `submission_date` because it is computed only using behavioral data collected _before_ the `submission_date`.

### WAU and MAU

Users can change segments part way through a week or a month. 
At present, 
we have not settled the questions of whether and how to split MAU by segment,
and whether and how to measure MAU for each segment.
So stick to DAU for now.


### Example queries

DAU for _regular users v1_:
```lang=sql
SELECT
    submission_date,
    COUNT(*) AS dau_regular_users_v1
FROM moz-fx-data-shared-prod.telemetry.clients_last_seen
WHERE
    submission_date BETWEEN '2020-01-01' AND '2020-03-01'
    AND segment_usage_regularity_v1 = 'regular_users_v1'
    AND days_since_seen = 0  -- Get DAU from clients_last_seen
GROUP BY submission_date
```

DAU for _regular users v1_, but joining from a different table:
```lang=sql
SELECT
    cd.submission_date,
    COUNT(*) AS dau_regular_users_v1
FROM clients_daily cd
INNER JOIN clients_last_seen cls
    ON cls.client_id = cd.client_id
    AND cls.submission_date = cd.submission_date
    AND cls.submission_date BETWEEN '2020-01-01' AND '2020-03-01'
WHERE
    cd.submission_date BETWEEN '2020-01-01' AND '2020-03-01'
    AND cls.segment_usage_regularity_v1 = 'regular_users_v1'
```
