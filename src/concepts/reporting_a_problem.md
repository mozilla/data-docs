# Reporting a problem

If you see a problem with data tools, datasets, or other pieces of infrastructure,
report it!

Defects in the data platform and tools are tracked in Bugzilla in the [Data Platform and Tools](https://bugzilla.mozilla.org/enter_bug.cgi?product=Data%20Platform%20and%20Tools) product.

Bugs need to be filed in the closest-matching component in the Data Platform and Tools
product. If you are not able to locate an appropriate component for the item in question, file an issue
in the [General component](https://bugzilla.mozilla.org/enter_bug.cgi?product=Data%20Platform%20and%20Tools&component=General).

Components are triaged at least weekly by the component owner(s). For any issues that need
urgent attention, it is recommended that you use the `needinfo` flag to attract attention
from a specific person. If an issue does not receive the appropriate attention in a
week (or it is urgent), see [getting help](getting_help.md).

When a bug is triaged, it is assigned a **priority** and **points**. **Priorities** are processed as follows:

- **`P1`**: in active development in the current sprint
- **`P2`**: planned to be worked on in the current quarter
- **`P3`**: planned to be worked on next quarter
- **`P4`** and beyond: nice to have, would accept a patch, but not actively being worked on.

**Points** reflect the amount of effort that is required for a bug. They are assigned as follows:

- **1 point**: one day or less of effort
- **2 points**: two days of effort
- **3 points**: three days to a week of effort
- **5 points** or more: SO MUCH EFFORT, major project.

### Problems with the data

There are Bugzilla components for several core datasets, as
described in this documentation. If at all possible, assign a specific component to the issue.

If there is an issue with a dataset to which you are unable to assign its own component,
file an issue in the [Datasets: General component](https://bugzilla.mozilla.org/enter_bug.cgi?product=Data%20Platform%20and%20Tools&component=Datasets%3A%20General).

### Problems with tools

There are Bugzilla components for several of the [tools](../introduction/tools.md) that
comprise the [Data Platform](https://bugzilla.mozilla.org/enter_bug.cgi?product=Data%20Platform%20and%20Tools).
File a bug in the specific component that most closely matches the tool in question.

Operational bugs, such as services being unavailable, need to be filed in the [Data SRE Jira Project](https://mozilla-hub.atlassian.net/secure/CreateIssue.jspa?pid=10058).

- The ticket should contain the following information:
  - Service details
  - Steps to reproduce
  - Impact to users

### Other issues

When in doubt, file issues in the [General component](https://bugzilla.mozilla.org/enter_bug.cgi?product=Data%20Platform%20and%20Tools&component=General).
