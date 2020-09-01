# `bmobugs`

This dataset mirrors bugs (defects, enhancements, tasks) reported in the
[`Bugzilla`](https://bugzilla.mozilla.org/) bug tracker.

# Data Reference

The dataset is accessible via [`STMO`](https://sql.telemetry.mozilla.org).
Use the `eng_workflow.bmobugs` table with the `Telemetry (BigQuery)` data source.

## Field Types and Descriptions

`bug_id`

The unique ID of the bug. The bug can be accessed at
`https://bugzilla.mozilla.org/show_bug.cgi?id=<bug_id>`

`reporter`

The `bugmail` of the user who filed the bug

`assigned_to`

The `bugmail` of the user the bug has been assigned to
by default, this is `nobody@mozilla.org`

`qa_contact`

The `bugmail` of the user who is responsible for answering
QA questions about the bug; This field is assigned on a per-
product::component basis

`product`

The product in which the bug was filed; see the
[Bugzilla product descriptions](https://bugzilla.mozilla.org/describecomponents.cgi)
for details

`component`

The component of the product in which the bug was filed

`bug_status`

The status of the bug:

- `UNCONFIRMED`
- `NEW`
- `ASSIGNED`
- `RESOLVED`
- `CLOSED`

`keywords`

Controlled vocabulary [keywords](https://bugzilla.mozilla.org/describekeywords.cgi)
assigned to the bug

`groups`

`Bugzilla` groups to which the bug has been assigned

`flags`

Flags requested by users of other users

- `name`: the name of the flag such as `needinfo`
- `status`: `?`, `+`, `-`
- `setter_id`: the `bugmail` of the user requesting the flag
- `requestee_id`: the `bugmail` of the user who the flag was requested of

`priority`

The bug's priority, as set by the developers who triage the product::component

`resolution`

If non-default, `---`, the resolution of the bug; which includes `FIXED`, `VERIFIED`,
`WORKSFORME`, `DUPLICATE`, `INVALID`, `WONTFIX`, and `MOVED`.

`blocked_by`

Bugs which much be resolved before this bug can be worked on
or resolved

`depends_on`

Bugs depending on the resolution of this bug before they can be resolved.

`duplicate_of`

If the bug has been resolved as `DUPLICATE`, the id of the bug of which
this is a duplicate

`duplicates`

List of bugs which have been resolved as duplicates of this bug

`target_milestone`

The version number of the branch of Nightly in which the change
set associated with the bug was landed; note that version
numbers vary by product

`version`

The version of Firefox in which the bug was reported

`delta_ts`

The timestamp of when the bug was last modified

`creation_ts`

The timestamp of when the bug was filed

## Example Queries

Select the number of bugs in the Core product filed
in the past 7 days:

```sql
SELECT
  count(distinct bug_id)
FROM
  eng_workflow.bmobugs
WHERE
  product = 'Core'
  AND date_diff(current_date(), date(parse_timestamp('%Y-%m-%d %H:%M:%S', creation_ts)), DAY) <= 7
  AND date(submission_timestamp) >= '2019-01-01' -- required submission date filter
```

# Code Reference

The dataset is populated via the
[simple ping service on Bugzilla](https://github.com/mozilla-bteam/bmo/blob/master/Bugzilla/Report/Ping/Simple.pm).
