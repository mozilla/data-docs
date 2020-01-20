# Mozilla Growth & Usage Dashboard
#### *overall: jmccrosky@ | data: jklukas@ | front end: hulmer@ (updated 2020-01-15)*
___

**The Mozilla Growth & Usage Dashboard is in general release and can be found [here](https://growth-stage.bespoke.nonprod.dataops.mozgcp.net/).**

___

# Overview

The Mozilla Growth & Usage Dashboard (GUD) is a tool to visualize growth metrics in a standard way across Mozilla’s products.  It is intended to be quite intuitive to use, but we provide some brief documentation here.  Please reach out (`#gud` on slack) if anything is unclear or you are unsure how to use GUD for your purposes.

# Quick Start

To visualize a particular metric (such as `MAU` or `Retention`) for a particular product:

1. By default, all metrics are shown.  To zoom into a particular metric, choose it from the `METRIC` selector on the left.

2. Choose the product of interest from the `PRODUCT / USAGE CRITERIA` selector on the left.  Some products may have multiple possible usage criteria, corresponding to different types of use of the product.

    * New profile creation is considered one of these usage criteria; thus, to determine the rate of new profile creation for a product, select that product’s "`Profile Created`" usage criterion and look at the `DAU` metric.

You may also restrict to particular slices (for example, country) and to a particular date range using the additional selectors on the left.

# Data Model

The key to understanding how to use GUD is to understand the GUD data model.  The key concepts are `usage criteria`, `slicing dimensions`, and `metrics`.

The data model and terminology used here is nearly identical to the [Exact MAU tables].

* A `usage criterion` defines what a metric is measuring.  It generally specifies a product and what specific use of that product qualifies as active.  For example, “Any Fenix Activity” measures activity for all Fenix profiles that send a telemetry pings.  Similarly, “Opened DevTools” means that we measure activity for all Firefox profiles that send a telemetry ping indicating that DevTools was opened.

* A `dimension` allows slicing to a subset of profiles according to characteristics of those profiles.  Available dimensions include: country, channel, OS, etc.  A slice is a set of particular values within dimensions, for example, “country is US” is one slice and “country is either US or DE and channel is release” is another.

* A `metric` summarizes activity for a particular day.  It is defined in terms of a `usage criterion` and `slice`.  For example, the `DAU` metric will tell you how many profiles met the `usage criterion` within the `slice` or, more concretely, might tell you how many profiles had any Firefox Desktop activity within Canada.

# Confidence Intervals

The dashboard uses a jackknife resampling method to compute confidence intervals that represent the variation of the underlying random process of the metric on that specific day.  If you look at very small slices (nightly channel in a smaller country) you will see that the metrics vary quite wildly due to this randomness, but that the confidence intervals will make clear that these variations could easily just be statistical fluctuations.

However, to be clear, the confidence intervals do not capture all possible sources of “meaningless variation” - if two days’ confidence intervals do not overlap, it does not necessarily mean that something important is happening.  There is normal variation over time that is inherent in the metrics’ behaviour, such as seasonal variation, which is not reflected in the confidence intervals.

Please consider the confidence interval as a **guardrail only** - non-overlapping confidence intervals can be considered a **necessary but not sufficient condition** that something interesting has been detected.

For the statisticians, we’ll note that it’s not actually a necessary condition, due to type II error and as there can be a statistically significant difference in quantities with overlapping confidence intervals.  We plan to support hypothesis testing in a future release.

# Definitions

## Metrics

### DAU

The number of unique profiles that meet the usage criterion on each day.

### WAU

The number of unique profiles that met the usage criterion at least once during the 7-day window, ending on the specified day.

### MAU

The number of unique profiles that met the usage criterion at least once during the 28-day window, ending on the specified day.

### Intensity

Intuitively, how many days per week do users use the product?  Among profiles that meet the usage criterion at least once in the week ending on the date specified, the number of days on average they meet the usage criterion during that one-week window.

### 1-Week New Profile Retention

Among new profiles created on the day specified, what proportion (out of 1) meet the usage criterion during the week beginning one week after the day specified.

### 1-Week Retention

Among profiles that were active in the specified usage criterion at least once in the week starting on the specified day, what proportion (out of 1) meet the usage criterion during the following week.

## Usage Criteria

### Firefox (Desktop)

#### Any Firefox Activity

The profile has sent a telemetry ping from Firefox Desktop on the day in question.

#### New Firefox Desktop Profile Created

The count of the number of new profiles created on the day in question.  Note this uses a main ping methodology for support for our entire history, rather than the newer `new-profile` ping.

#### Visited 5 URIs

The profile sent a main ping on the day in question that indicates that the profile opened at least 5 URIs.

#### Opened DevTools

The profile sent a main ping on the day in question that indicates that the developer tools feature was activated at least once.

### Fenix

#### Any Fenix Activity

The profile has sent a telemetry ping from Fenix on the day in question.
Firefox Accounts

#### Any Firefox Account Activity

The profile has sent a telemetry ping from Firefox Account on the day in question.  This corresponds to “active” events in Amplitude.

### Fennec

#### Any Fennec Android Activity

The profile has sent a telemetry ping from Fennec Android on the day in question.

#### Any Fennec iOS Activity

The profile has sent a telemetry ping from Fennec iOS on the day in question.

### Focus

#### Any Focus Android Activity

The profile has sent a telemetry ping from Focus Android on the day in question.

#### Any Focus iOS Activity

The profile has sent a telemetry ping from Focus iOS on the day in question.

### Other Products

#### Any Firefox Lite Activity

The profile has sent a telemetry ping from Firefox Lite on the day in question.

#### Any Firefox for FireTV Activity

The profile has sent a telemetry ping from Firefox for FireTV on the day in question.

#### Any `FirefoxConnect` Activity

The profile has sent a telemetry ping from `FirefoxConnect` on the day in question.

## Dimensions

During a period of time, a particular profile may take on more than one value within a dimension.  For example, a profile may use release channel and beta channel browsers in a single day, resulting in two pings for the day with different values of channel.  Similarly, a profile may be used in one country one day and another country the next day, resulting in two pings for two consecutive days that have different values of country.  Generally, for a metric, we need to assign a profile to one particular value for each dimension.  As such we define the value for each dimension within a day by taking the most frequent value seen in that day, breaking ties by taking the value that occurs last.  We then use the values from the last day within the data that the metric examines.  This is documented in more detail [here](../datasets/bigquery/exact_mau/reference.md#slice).

### OS

Whether the profile’s pings were sent from Mac OS, Windows, or Linux.

### Language

The language (as extracted from the locale) of the profile’s pings.

### Country

The country (as extracted through GeoIP lookup) of the profile’s pings.

### Channel

The channel of the profile’s pings.

# Bug reports / Feature Requests

Please direct all feedback to `#gud` on slack.

# Other References

* There is more information on the design, definitions and data model in the [Engineering Design Doc](https://docs.google.com/document/d/1L8tWDUjccutGGAldhpypRtPCaw3kkXboPUTtTZb02OA/), although some information there may be out of date.

* The underlying tables are closely related to the [Exact MAU tables].

* There is a [prototype tool](https://github.com/mozilla/dscontrib/tree/master/src/dscontrib/jmccrosky/gudnightly) in Databricks on which GUD was based.  It still exists and has been branded `“gudnightly”` as it has many features that do not yet exist in GUD, including smoothing, year-over-year comparisons, plotting multiple slices on a single axis, etc.   However, it is very slow, less user-friendly, and as of this writing only supports desktop data.

* Tables can be queried directly from BigQuery for programmatic access; see an example in [https://sql.telemetry.mozilla.org/queries/65337/source](https://sql.telemetry.mozilla.org/queries/65337/source).

[Exact MAU tables]: ../datasets/bigquery/exact_mau/reference.md
