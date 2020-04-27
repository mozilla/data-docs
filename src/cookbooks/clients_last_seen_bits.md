# Working with Bit Patterns in Clients Last Seen

An powerful feature of the `clients_last_seen` methodology is that we can capture
per-day usage information for the entire 28-day period that each row in the table
describes. We encode usage information in "bit patterns" where the physical
type of the field is a BigQuery 64-bit integer, but logically the integer
represents an array of bits, with each 1 indicating a day where the given clients
was active and each 0 indicating a day where the client was inactive.

The representation is space-efficient and actually easier to manipulate
in BigQuery than a date array would be, but requires some practice to interact
with directly. For well-established usage and retention metrics, we generally
provide logic in views to insulate users from having to ever consider the
raw bit patterns, but new investigations may require novel retention definitions.

## Usage: Backward-looking windows

The simplest application of usage bit patterns is for calculating metrics in
backward-looking windows. This is what we do for our canonical _usage_ measures
DAU, WAU, and MAU.

Let's imagine a single row from `clients_last_seen` with `submission_date = 2020-01-28`.
The `days_seen_bits` field records usage for a single client over a period of 28 days
_ending_ on the given `submission_date`. We will call this anchor date "day 0" 
(2020-01-28 in this case) and count backwards to "day -27" (2020-01-01).

Let's suppose this client was only active on two days in the past month:
2020-01-22 (day -6) and 2020-01-15 (day -13). That client's`days_seen_bits`
value would show up as an integer with value `8256` which is pretty inscrutable.
Let's look at that value as a string representing each bit instead:

```
SELECT udf.bits28_to_bitstring(32768)
-- 0000000000000010000001000000
```

Let's make that representation a bit more visual:

```
    0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  1  0  0  0  0  0  0
    ──────────────────────────────────────────────────────────────────────────────────
    │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │
    │ 26  │ 24  │ 22  │ 20  │ 18  │ 16  │ 14  │ 12  │ 10  │  8  │  6  │  4  │  2  │  0
   27    25    23    21    19    17    15    13    11     9     7     5     3     1
   
  └──────────────────────────────────────────────────────────────────────────────────┘
  MAU                                                             └──────────────────┘
                                                                   WAU             └─┘
                                                                                   DAU
```

In this picture, we've annotated the windows for DAU (day 0 only), 
WAU (days 0 through -6) and MAU (days 0 through -27). This particular client
won't count toward DAU for 2020-01-28, but the client does count towards both
WAU and MAU.

You may notice that the day 13 bit doesn't end up affecting these metrics.
For DAU, WAU, and MAU, all that matters is the rightmost bit that's set,
telling us about the most recent activity seen for that user. We provide
a special function for that use case:


```
SELECT udf.bits28_days_since_seen(8256)
-- 6
```

Indeed, this is so commonly used that we build this function into user-facing
views, so that instead of referencing `days_seen_bits` with a UDF, you can
instead reference a field called `days_since_seen`. Counting MAU, WAU, and
DAU generally looks like:

```
SELECT
  COUNT(days_since_seen < 28) AS mau,
  COUNT(days_since_seen <  7) AS wau,
  COUNT(days_since_seen <  1) AS dau
FROM
  telemetry.clients_last_seen
```

Note that this particular client is about to fall outside the WAU window.
If the client doesn't send a main ping on 2020-01-29, the new `days_seen_bits`
pattern will look like:

```
    0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  1  0  0  0  0  0  0  0
    ──────────────────────────────────────────────────────────────────────────────────
    │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │
    │ 26  │ 24  │ 22  │ 20  │ 18  │ 16  │ 14  │ 12  │ 10  │  8  │  6  │  4  │  2  │  0
   27    25    23    21    19    17    15    13    11     9     7     5     3     1
   
  └──────────────────────────────────────────────────────────────────────────────────┘
  MAU                                                             └──────────────────┘
                                                                   WAU             └─┘
                                                                                   DAU
```

The `days_seen_bits` value is now `16512` and the user is indeed outside the WAU window:

```
SELECT udf.bits28_days_since_seen(16512)
-- 7
```

## Retention: Forward-looking windows

For retention calculations, we user forward-looking windows. This means that
when we report a retention value for 2020-01-01, we're talking about what
portion of clients active on 2020-01-01 are still active some number of days
later.

When we were talking about backward-looking windows, our anchor date or "day 0"
was always the `submission_date`. When we define forward-looking windows, however,
we always choose an anchor date some time in the past. How we number the individual
bits depends on what anchor date we choose.

In GUD, we show a "Week 1 Retention" which considers a window of 14 days.

Let's consider the same user from before, grabbing the `days_seen_bits` value
with `submission_date = 2020-01-28`. We'll still choose a window that _ends_
on the submission date, but the anchor date (day 0) will now be 13 days earlier:


```
    0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  1  0  0  0  0  0  0
    ──────────────────────────────────────────────────────────────────────────────────
                                              │  │  │  │  │  │  │  │  │  │  │  │  │  │
                                              │  1  │  3  │  5  │  7  │  9  │ 11  │ 13
                                              0     2     4     6     8    10    12                                     
                                             └───────────────────┘
                                                    Week 0       └───────────────────┘
                                                                        Week 1
```

## UDF Reference
