# Exact MAU Data

## Introduction

This article introduces the usage of and methodology behing the "exact MAU"
tables in BigQuery:
`firefox_desktop_exact_mau28_by_dimensions`,
`firefox_nondesktop_exact_mau28_by_dimensions`, and
`firefox_accounts_exact_mau28_by_dimensions`.
The calculation of MAU (monthly active users) has historically been frought
with troubling details around exact definitions and computational limitations,
leading to disagreements between analyses.
These tables contain precalculated MAU, WAU, and DAU aggregates for 
various usage criteria and dimensions, allowing efficient calculation of
aggregates across arbitrary slices of those dimensions.
The tables follow a consistent methodology which is intended as a standard
across Mozilla for MAU analysis going forward.

## Table of Contents

<!-- toc -->

# Conceptual Model

## Metric

A metric is anything want to (and can) measure.  In order for a metric to be 
calculated, a _usage criterion_ and a _slice_ must be specified. The metric 
will produce a single value per day, summarizing data:

- for one day or more days (i.e. the metric value for a particular day may depend on data from other days as well)
- for all users (whatever notion of user makes sense for the data, generally profiles) in a particular sub-population
- where the sub-population will include users that meet the specified usage criteria and are in the specified slice.

A simple __usage criterion_ is "All Desktop Activity", which includes all Firefox Desktop users that we have any data (telemetry ping) for on the day in question.  The simplest slice is "All" which places no restrictions on the sub-population.

For example, the metric "Daily Active Users (DAU)" with usage criteria "All Desktop Activity" and slice "All" involves summarizing data on all users of Firefox Desktop over a single day.

## Usage Criteria

A _usage criterion_ is any product or feature for which we wish to calculate
metrics.  It may be something simple like "All Desktop Activity" (as above) or, 
similarly, "All Mobile Activity".  It may also be something more specific like
"Desktop 5 URI Active" corresponding to calculation of 
[aDAU](/cookbooks/active_dau.html).

The 2019 KPI definition for Relationships relies on a MAU calculation restricted
to a specific set of "Tier 1" countries which we also end up codifying as a usage
criterion. As discussed in the next section, country is normally a dimension that
woud be specified in a slice definition and we should be able to calculate 
"Tier 1 FxA MAU" on top of a general "All FxA Activity" usage criterion. Due to the
methodology used when forecasting goal values for the year, however, we need to
follow a more inclusive definition where a user counts toward MAU if they register
even a single FxA activity from a tier 1 country in the 28 day MAU window.
That calculation requires a separate "FxA Activity in Tier 1 Country" criterion.

## Slice

A slice defines the sub-population on which we can calculate a metric and
is specified by setting restrictions in different dimensions.
Examples of dimensions include: "Country", "Attribution Source",
and "Firefox Version".
Thus an example slice may be "Country = US; Firefox Version = 60|61", which
restricts to profiles that report usage in the US on Firefox versions 60 or 61.
There is implicitly no restriction on any other dimensions.
Thus, the empty slice - "All" - is also a valid slice and simply places no 
restrictions on any dimension.
Note there are some complexities here:

- Firstly, a dimension may be scalar and need to be suitably bucketed (instead of every possible profile age being a unique slice element, maybe we prefer to group users between 12 and 16 months old into a single slice element); likewise we may need to use normalized versions of string fields
- Secondly, we require that dimensions be non-overlapping, especially for metrics calculated over multiple days of user activity.  In a given day, a profile may be active in multiple countries, but we aggregate that to a single value by taking the most frequent value seen in that day, breaking ties by taking the value that occurs last. In a given month, the assigned country may change from day to day; we use the value from the most recent active day up to the day we're calculating usage for.

# Using the Tables

To be written...
