# Event Data Pipeline

We collect event-oriented data from different sources. This data is collected and processed in a
specific path through our data pipeline, which we will detail here.

```mermaid
graph TD

subgraph Products
fx_code(fa:fa-cog Firefox code) --> firefox(fa:fa-firefox Firefox Telemetry)
fx_extensions(fa:fa-cog Mozilla extensions) --> firefox
mobile(fa:fa-cog Mobile products) --> mobile_telemetry(fa:fa-firefox Glean)
end

subgraph Data Platform
firefox -.->|main ping, Firefox <62| pipeline((fa:fa-database Firefox Data Pipeline))
firefox -->|event ping, Firefox 62+| pipeline
mobile_telemetry --> |events ping| pipeline
pipeline -->|Firefox <62 events| main_summary[fa:fa-bars main summary table]
pipeline -->|Firefox 62+ events| mobile_events_table[fa:fa-bars events table]
main_summary --> events_table
pipeline -->|Glean events| events_table[fa:fa-bars events table]
end

subgraph Data Tools
events_table --> looker
events_table --> looker
main_summary --> looker(fa:fa-bar-chart Looker)
end

style fx_code fill:#f94,stroke-width:0px
style fx_extensions fill:#f94,stroke-width:0px
style mobile fill:#f94,stroke-width:0px
style firefox fill:#f61,stroke-width:0px
style mobile_telemetry fill:#f61,stroke-width:0px
style pipeline fill:#79d,stroke-width:0px
style main_summary fill:lightblue,stroke-width:0px
style events_table fill:lightblue,stroke-width:0px
style mobile_events_table fill:lightblue,stroke-width:0px
style looker fill:salmon,stroke-width:0px
```

# Overview

Across the different Firefox teams there is a common need for a more fine grained understanding of
product usage, like understanding the order of interactions or how they occur over time.
To address that our data pipeline needs to support working with event-oriented data.

We specify a common event data format, which allows for broader, shared usage of data processing tools.
To make working with event data feasible, we provide different mechanisms to get the event data
from products to our data pipeline and make the data available in tools for analysis.

# The event format

Events are submitted as an array, e.g.:

```javascript
[
  [2147, "ui", "click", "back_button"],
  [2213, "ui", "search", "search_bar", "google"],
  [
    2892,
    "ui",
    "completion",
    "search_bar",
    "yahoo",
    { querylen: "7", results: "23" },
  ],
  [5434, "dom", "load", "frame", null, { prot: "https", src: "script" }],
  // ...
];
```

Each event is of the form:

```javascript
[timestamp, category, method, object, value, extra];
```

Where the individual fields are:

- `timestamp`: `Number`, positive integer. This is the time in ms when the event was recorded, relative to the main process start time.
- `category`: `String`, identifier. The category is a group name for events and helps to avoid name conflicts.
- `method`: `String`, identifier. This describes the type of event that occurred, e.g. `click`, `keydown` or `focus`.
- `object`: `String`, identifier. This is the object the event occurred on, e.g. `reload_button` or `urlbar`.
- `value`: `String`, optional, may be null. This is a user defined value, providing context for the event.
- `extra`: `Object`, optional, may be null. This is an object of the form `{"key": "value", ...}`, both keys and values need to be strings. This is used for events when additional richer context is needed.

See also the [Firefox Telemetry documentation](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/collection/events.html#serialization-format).

# Event data collection

## Firefox event collection

To collect this event data in Firefox there are different APIs in Firefox, all addressing different
use cases:

- The [_Telemetry event API_](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/collection/events.html)
  allows easy recording of events from Firefox code.
- The [_dynamic event API_](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/collection/events.html#registerevents)
  allows code from Mozilla addons to record new events into Telemetry without shipping Firefox
  code.
- The _[Telemetry WebExtension API](https://searchfox.org/mozilla-central/rev/55da592d85c2baf8d8818010c41d9738c97013d2/toolkit/components/extensions/schemas/telemetry.json#87)_ ([introduced here](https://bugzilla.mozilla.org/show_bug.cgi?id=1280234))
  which allows Mozilla extensions to record new events into Telemetry.

For all these APIs, events will get sent to the pipeline through the
[event ping](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/event-ping.html), which gets sent hourly, if any pings were recorded, or up to every 10 minutes whenever 1000 events were recorded.
Before Firefox 62, events were sent through the [main ping](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/main-ping.html) instead, with a hard limit of 500 events per ping.
From Firefox 61, all events recorded through these APIs are [automatically counted in scalars](https://bugzilla.mozilla.org/show_bug.cgi?id=1440673).

Finally, [_custom pings_](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/collection/custom-pings.html)
can follow the event data format and potentially connect to the existing tooling with some integration work.

## Mobile event collection

Mobile data collection is done through [Glean](glean_data.md). [Glean events](https://mozilla.github.io/glean/book/reference/metrics/event.html) are recorded for our mobile applications.

# Datasets

On the pipeline side, the event data is made available in different datasets:

- [`main_summary`](../../datasets/batch_view/main_summary/reference.md) has a row for each main ping and includes
  its event payload for Firefox versions before 62.
- [`events`](../../datasets/batch_view/events/reference.md) contains a row for each event received from main pings and event pings. See [`STMO#52582`](https://sql.telemetry.mozilla.org/queries/52582/source).
- For applications that collect events through Glean, each application has a separate `events` dataset.

# Data tooling

The above datasets are all accessible through [STMO](../../tools/stmo.md) and [Looker](../../cookbooks/looker/intro.md).
