# Reporting a problem

If you have a problem with data tools, datasets, or other pieces of infrastructure,
please help us out by reporting it.

Most of our work is tracked in Bugzilla in the [Data Platform and Tools](https://bugzilla.mozilla.org/enter_bug.cgi?product=Data%20Platform%20and%20Tools) product.

Bugs should be filed in the closest-matching component in the Data Platform and Tools
product, but if there is no component for the item in question, please file an issue
in the [General component](https://bugzilla.mozilla.org/enter_bug.cgi?product=Data%20Platform%20and%20Tools&component=General).

Components are triaged at least weekly by the component owner(s). For issues needing
urgent attention, it is recommended that you use the `needinfo` flag to attract attention
from a specific person. If an issue doesn't receive the appropriate attention within a
week (or it's urgent), you can find out how to reach us in the [getting help](getting_help.md) section.

When a bug is triaged, it will be assigned a **priority** and **points**. **Priorities** have the
following meanings:

- **`P1`**: in active development in the current sprint
- **`P2`**: planned to be worked on in the current quarter
- **`P3`**: planned to be worked on next quarter
- **`P4`** and beyond: nice to have, we would accept a patch, but not actively being worked on.

**Points** reflect the amount of effort required for a bug and are assigned as follows:

- **1 point**: one day or less of effort
- **2 points**: two days of effort
- **3 points**: three days to a week of effort
- **5 points** or more: SO MUCH EFFORT, major project.

### Problems with the data

There are bugzilla components for several of core datasets.
described in this documentation, so if possible, please use a specific component.

If there is a problem with a dataset that does not have its own component, please
file an issue in the [Datasets: General component](https://bugzilla.mozilla.org/enter_bug.cgi?product=Data%20Platform%20and%20Tools&component=Datasets%3A%20General).

### Problems with tools

There are bugzilla components for several of the [tools](../tools/interfaces.md) that
comprise the [Data Platform](https://bugzilla.mozilla.org/enter_bug.cgi?product=Data%20Platform%20and%20Tools),
so please file a bug in the specific component that most closely matches the
tool in question.

Operational bugs, such as services being unavailable, should be filed either in
the component for the service itself or in the [Operations component](https://bugzilla.mozilla.org/enter_bug.cgi?product=Data%20Platform%20and%20Tools&component=Operations).

### Other problems

When in doubt, please file issues in the [General component](https://bugzilla.mozilla.org/enter_bug.cgi?product=Data%20Platform%20and%20Tools&component=General).

