# Firefox Data Documentation

This document will teach you how to use Firefox data
to answer questions about our users. The source for this documentation
can be found in [this repo](https://github.com/mozilla/firefox-data-docs).

## Using this document

This documentation is divided into four main sections:

### [Getting Started](concepts/getting_started.md)
  This section provides a **quick introduction** to analyzing telemetry data.
  After reading these articles, you will be able to confidently perform analysis
  over telemetry data.

### [Data Collection and Datasets](datasets/README.adoc)
  Describes all available data we have on our users.
  For each dataset, we include a description of the dataset's purpose,
  what data is included, how the data is collected,
  and how you can change or augment the dataset.
  You do not need to read this section end-to-end.

### [Tools](tools/README.adoc)
  Describes the tools we maintain to access and analyze user data.
  For each tool we include a description of the purpose, relative strengths
  and weaknesses, and what data you can access from the tool.

### [Cookbooks & Tutorials](cookbooks/README.adoc)
  This section contains tutorials presented in a simple problem/solution format.

## Missing Documentation

We're writing documentation as fast as we can,
but there's always going to be confusing or missing documentation.
If you can't find what you need, please
[file a bug](https://bugzilla.mozilla.org/enter_bug.cgi?assigned_to=nobody%40mozilla.org&bug_file_loc=http%3A%2F%2F&bug_ignored=0&bug_severity=normal&bug_status=NEW&cf_fx_iteration=---&cf_fx_points=---&component=Documentation%20and%20Knowledge%20Repo%20%28RTMO%29&contenttypemethod=autodetect&contenttypeselection=text%2Fplain&defined_groups=1&flag_type-4=X&flag_type-607=X&flag_type-800=X&flag_type-803=X&flag_type-916=X&form_name=enter_bug&maketemplate=Remember%20values%20as%20bookmarkable%20template&op_sys=Linux&priority=P3&product=Data%20Platform%20and%20Tools&rep_platform=x86_64&target_milestone=---&version=unspecified).

## Reporting a problem

If you have a problem with data tools, datasets, or other pieces of infrastructure,
please help us out by reporting it.

Most of our work is tracked in Bugzilla in the [Data Platform and Tools](https://bugzilla.mozilla.org/enter_bug.cgi?product=Data%20Platform%20and%20Tools) product.

Bugs should be filed in the closest-matching component in the Data Platform and Tools
product, but if there is no component for the item in question, please file an issue
in the [General component](https://bugzilla.mozilla.org/enter_bug.cgi?product=Data%20Platform%20and%20Tools&component=General).

Components are triaged at least weekly by the component owner(s). For issues needing
urgent attention, it is recommended that you use the `needinfo` flag to attract attention
from a specific person. If an issue doesn't receive the appropriate attention within a
week, you can send email to the `fx-data-dev` mailing list or reach out on IRC
in `#datapipeline`.

When a bug is triaged, it will be assigned a **priority** and **points**. **Priorities** have the
following meanings:

- **P1**: in active development in the current sprint
- **P2**: planned to be worked on in the current quarter
- **P3**: planned to be worked on next quarter
- **P4** and beyond: nice to have, we would accept a patch, but not actively being worked on.

**Points** reflect the amount of effort required for a bug and are assigned as follows:

- **1 point**: one day or less of effort
- **2 points**: two days of effort
- **3 points**: three days to a week of effort
- **5 points** or more: SO MUCH EFFORT, major project.

### Problems with the data

There are bugzilla components for several of core [datasets](datasets/README.adoc)
described in this documentation, so if possible, please use a specific component.

If there is a problem with a dataset that does not have its own component, please
file an issue in the [Datasets: General component](https://bugzilla.mozilla.org/enter_bug.cgi?product=Data%20Platform%20and%20Tools&component=Datasets%3A%20General).

### Problems with tools

There are bugzilla components for several of the [tools](tools/README.adoc) that
comprise the [Data Platform](https://bugzilla.mozilla.org/enter_bug.cgi?product=Data%20Platform%20and%20Tools),
so please file a bug in the specific component that most closely matches the
tool in question.

Operational bugs, such as services being unavailable, should be filed either in
the component for the service itself or in the [Operations component](https://bugzilla.mozilla.org/enter_bug.cgi?product=Data%20Platform%20and%20Tools&component=Operations).

### Other problems

When in doubt, please file issues in the [General component](https://bugzilla.mozilla.org/enter_bug.cgi?product=Data%20Platform%20and%20Tools&component=General).