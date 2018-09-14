# Terminology

* **Analyst**: Someone performing analysis.
  This is more general than **data scientist**.
* **Ping**: A message sent from the FireFox browser to our telemetry servers containing information on browser state, user actions, etc...
([more details](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/common-ping.html))
* **Dataset**: A set of data, includes ping data, derived datasets, etc...
* **Derived Dataset**: A processed dataset, such as `main_summary` or the 
  `longitudinal` dataset
* **Session**: The time from when a Firefox browser starts until it shuts down
* **Subsession**: `Sessions` are split into `subsessions` when a 24-hour threshold is crossed or an environment change occurs
([more details](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/concepts/sessions.html?highlight=subsession))
* ...

