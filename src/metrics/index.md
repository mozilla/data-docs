# Standard Metrics

This section provides an overview of standard metrics used at Mozilla.
Here you'll find the definitions and descriptions for each.

For a deep dive into these metrics, see [the GUD documentation](https://mozilla.github.io/gud/).

The [Telemetry Behavior Reference](../concepts/index.md) section also provides
information related to the definitions below.

We are now in the process of setting up the metrics top-level section here. This information will be moved into the appropriate subsection and this page will be replaced with an overview.

## Activity

### DAU

The number of unique profiles active on each day.

### WAU

The number of unique profiles active at least once during the 7-day window
ending on the specified day.

### MAU

The number of unique profiles active at least once during the 28-day window
ending on the specified day.

### Intensity

Intuitively, how many days per week do users use the product? Among profiles
active at least once in the week ending on the date specified, the number of
days on average they were active during that one-week window.

## Retention

### 1-Week New Profile Retention

Among new profiles created on the day specified, what proportion (out of 1) are
active during the week beginning one week after the day specified.

### 1-Week Retention

Among profiles that were active at least once in the week starting on the
specified day, what proportion (out of 1) are active during the following week.

## Frequently Asked Questions

- Why isn't "New Users" a metric?
  - "New Users" is considered a [usage criterion], which means it may be used
    to filter other metrics, rather than itself being a metric. For example,
    you can compute "New User DAU", which would be the subset of DAU that match
    the "New User" criterion. The exception here is 1-Week New Profile
    Retention, which is so common that it makes sense to include with all
    usage criteria.
- What dates are used to determine activity for things like MAU and DAU?
  - [Submission dates] are used for determining when activity happened (_not_
    client-side activity dates).
- What [pings] are used as a signal of activity?
  - For Firefox Desktop, we use the `main` ping to determine activity.
  - For products instrumented using Glean, we use the `baseline` ping.

[usage criterion]: https://mozilla.github.io/gud#data-model
[submission dates]: https://bugzilla.mozilla.org/show_bug.cgi?id=1422892
[pings]: ../datasets/pings.md
