# Segments (beta)

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
So please quote segments' versions with their names, e.g. "regular users v3"
so that your communication is forwards compatible.

## Current segments

### Regular users v3

This segment contains clients who sent pings on _at least 14_ of the previous 27 days. As of February 2020 this segment contained approximately 2/3 of DAU and its users had a 1-week retention of around 95%.

### New or Resurrected v3

This segment contains clients who sent pings on _none_ of the previous 27 days. As of February 2020 this segment contained approximately 4% of DAU and its users had a 1-week retention of approximately 30%.

## Writing queries with segments

When a segment is defined with respect to a user's _behavior_ (e.g. usage levels) 
as opposed to more stable traits (e.g. country), 
we should evaluate each user's segment eligibility 
using data collected _before_ the time period in which we want to study their actions. 
Else we run the risk of making trivial discoveries 
like "heavy users use the product heavily" instead of more meaningful ones 
like "heavy users go on to continue using the product heavily".

So, when writing queries to compute segments directly from their definition, 
be sure to compute users' segments using only 
data collected before the time period you're analyzing their behavior.

Segments are found as columns in the `clients_last_seen` dataset: the segment listed for a client on a `submission_date` is valid for that `submission_date` because it is computed only using behavioral data collected _before_ the `submission_date`.

### WAU and MAU

Users can change segments part way through a week or a month. 
At present, 
we have not settled the questions of whether and how to split MAU by segment,
and whether and how to measure MAU for each segment.
So stick to DAU for now.


### Example queries

DAU for _regular users v3_:
```lang=sql
SELECT
    submission_date,
    COUNTIF(BIT_COUNT(days_seen_bits & 0x0FFFFFFE) >= 14) AS dau_regular_users_v3
FROM moz-fx-data-shared-prod.telemetry.clients_last_seen
WHERE
    submission_date BETWEEN '2020-01-01' AND '2020-03-01'
    AND days_since_seen = 0  -- Get DAU from clients_last_seen
GROUP BY submission_date
```

DAU for _regular users v3_, but joining from a different table:
```lang=sql
SELECT
    cd.submission_date,
    COUNTIF(BIT_COUNT(cls.days_seen_bits & 0x0FFFFFFE) >= 14) AS dau_regular_users_v3
FROM clients_daily cd
INNER JOIN clients_last_seen cls
    ON cls.client_id = cd.client_id
    AND cls.submission_date = cd.submission_date
    AND cls.submission_date BETWEEN '2020-01-01' AND '2020-03-01'
WHERE
    cd.submission_date BETWEEN '2020-01-01' AND '2020-03-01'
```


## Obsolete segments

### Usage regularity v2

This is a set of three segments. 
On a given day, every client falls into exactly one of these segments.
Each client's segment can be computed from `telemetry.clients_last_seen.days_visited_5_uri_bits`.


*Regular users v2* is defined as 
clients who browsed >=5 URIs on _at least eight_ of the previous 27 days.
As of February 2020 this segment contained approximately 2/3 of DAU
and its users had a 1-week retention for a 5 URI day usage criterion of approximately 95%.

*New/irregular users v2* is defined as 
clients who browsed >=5 URIs on _none_ of the previous 27 days.
As of February 2020 this segment contained approximately 15% of DAU,
and had a retention for a 5 URI day usage criterion of about 10%
(though "activation" is likely a more relevant word than "retention" for many of these clients).

*Semi-regular users v2* is defined as
clients who browsed >=5 URIs on _between one and seven_ of the previous 27 days,
i.e. it contains users who do not fit the other two segments at this time.
As of February 2020 this segment contained approximately 20% of DAU,
and had a retention for a 5 URI day usage criterion of about 60%.
We do not yet know what proportion of users in this segment stay in this segment for an extended period, and what proportion are in transition between other segments.
