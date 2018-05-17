# SQL Style Guide

## Table of Contents

<!-- toc -->

## Consistency

From [Pep8](https://www.python.org/dev/peps/pep-0008/#a-foolish-consistency-is-the-hobgoblin-of-little-minds):

> A style guide is about consistency.
> Consistency with this style guide is important.
> Consistency within a project is more important.
> Consistency within one module or function is the most important.
>
> However, know when to be inconsistent --
> sometimes style guide recommendations just aren't applicable.
> When in doubt, use your best judgment.
> Look at other examples and decide what looks best.
> And don't hesitate to ask!

## Reserved Words

Always use uppercase for reserved keywords like `SELECT`, `WHERE`, or `AS`.

## Variable Names

1. Use consistent and descriptive identifiers and names.
1. Use lower case names with underscores, such as `first_name`.
   Do not use CamelCase.
1. Presto functions, such as `cardinality`, `approx_distinct`, or `substr`,
   [are identifiers](https://www.postgresql.org/docs/10/static/sql-syntax-lexical.html#SQL-SYNTAX-IDENTIFIERS)
   and should be treated like variable names.
1. Names must begin with a letter and may not end in an underscore.
1. Only use letters, numbers, and underscores in variable names.

## Aliasing

Always include the `AS` keyword when aliasing a variable,
it's easier to read when explicit.

**Good**
```sql
SELECT
  substr(submission_date, 1, 6) AS month
FROM
  main_summary
LIMIT
  10
```

**Bad**
```sql
SELECT
  substr(submission_date, 1, 6) month
FROM
  main_summary
LIMIT
  10
```

## Left Align Root Keywords

Root keywords should all start on the same character boundary.
This is counter to the common "rivers" pattern
[described here](https://www.sqlstyle.guide/#spaces).

**Good**:

```sql
SELECT
  client_id,
  submission_date
FROM
  main_summary
WHERE
  sample_id = '42'
  AND submission_date > '20180101'
LIMIT
  10
```

**Bad**:

```sql
SELECT client_id,
       submission_date
  FROM main_summary
 WHERE sample_id = '42'
   AND submission_date > '20180101'
```

## Code Blocks

Root keywords should be on their own line.
For example:

**Good**:
```sql
SELECT
  client_id,
  submission_date
FROM
  main_summary
WHERE
  submission_date > '20180101'
  AND sample_id = '42'
LIMIT
  10
```

It's acceptable to include an argument on the same line as the root keyword,
if there is exactly one argument.

**Acceptable**:
```sql
SELECT
  client_id,
  submission_date
FROM main_summary
WHERE
  submission_date > '20180101'
  AND sample_id = '42'
LIMIT 10
```

Do not include multiple arguments on one line.

**Bad**:
```sql
SELECT client_id, submission_date
FROM main_summary
WHERE
  submission_date > '20180101'
  AND sample_id = '42'
LIMIT 10
```

**Bad**
```sql
SELECT
  client_id,
  submission_date
FROM main_summary
WHERE submission_date > '20180101'
  AND sample_id = '42'
LIMIT 10
```

## Parentheses

If parentheses span multiple lines:

1. The opening parenthesis should terminate the line.
1. The closing parenthesis should be lined up under
   the first character of the line that starts the multi-line construct.
1. The contents of the parentheses should be indented one level.

For example:

**Good**
```sql
WITH sample AS (
  SELECT
    client_id,
  FROM
    main_summary
  WHERE
    sample_id = '42'
)
```

**Bad** (Terminating parenthesis on shared line)
```sql
WITH sample AS (
  SELECT
    client_id,
  FROM
    main_summary
  WHERE
    sample_id = '42')
```

**Bad** (No indent)
```sql
WITH sample AS (
SELECT
  client_id,
FROM
  main_summary
WHERE
  sample_id = '42'
)
```

## Boolean at the Beginning of Line

`AND` and `OR` should always be at the beginning of the line.
For example:

**Good**
```sql
...
WHERE
  submission_date > 20180101
  AND sample_id = '42'
```

**Bad**
```sql
...
WHERE
  submission_date > 20180101 AND
  sample_id = '42'
```

## Nested Queries

Do not use nested queries.
Instead, use common table expressions to improve readability.

**Good**:
```sql
WITH sample AS (
  SELECT
    client_id,
    submission_date
  FROM
    main_summary
  WHERE
    sample_id = '42'
)

SELECT *
FROM sample
LIMIT 10
```

**Bad**:
```sql
SELECT *
FROM (
  SELECT
    client_id,
    submission_date
  FROM
    main_summary
  WHERE
    sample_id = '42'
)
LIMIT 10
```

## About this Document

This document was heavily influenced by https://www.sqlstyle.guide/

Changes to the style guide should be reviewed by at least one member of
both the Data Engineering team and the Data Science team.


