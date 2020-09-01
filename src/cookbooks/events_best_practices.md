# Telemetry Events Best Practices

## Overview:

[The Telemetry Events API](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/collection/events.html) allows users to define and record events in the browser.

Events are defined in [`Events.yaml`](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/collection/events.html#the-yaml-definition-file) and each events creates records with the following properties:

- timestamp
- category
- method
- object
- value
- extra

With the following restrictions and features:

- The category, method, and object properties of any record produced by an event must have a value.
- All combinations of values from the category, method, and object properties must be unique to that particular event (no other event can produce events with the same combination).
- Events can be 'turned on' or 'turned off' by it's category value. i.e. we can instruct the browser to "stop sending us events from the `devtools` category."

These records are then stored in [event pings](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/data/event-ping.html) and available in the [events dataset](https://docs.telemetry.mozilla.org/datasets/batch_view/events/reference.html).

## Identifying Events

One challenge with this data is it can be difficult to identify all the records from a particular event.
Unlike Scalars and Histograms, which keep data in individual locations (like `scalar_parent_browser_engagement_total_uri_count` for [`total_uri_count`](https://searchfox.org/mozilla-central/rev/501eb4718d73870892d28f31a99b46f4783efaa0/toolkit/components/telemetry/Scalars.yaml#204)), all event records are stored together, regardless of which event generated them. The records themselves don't have a field identifying which event produced it[1].

Take, for example, the [`manage`](https://searchfox.org/mozilla-central/rev/501eb4718d73870892d28f31a99b46f4783efaa0/toolkit/components/telemetry/Events.yaml#151)
event in the `addonsManager` category.

```
addonsManager: # category
  manage: # event name
    description: >
      ...
    objects: ["extension", "theme", "locale", "dictionary", "other"] # object values
    methods: ["disable", "enable", "sideload_prompt", "uninstall"] # method values
    extra_keys: # extra values
      ...
    notification_emails: ...
    expiry_version: ...
    record_in_processes: ...
    bug_numbers: ...
    release_channel_collection: ...
```

This event will produce records that look like:

| timestamp | category        | method            | object      | value | extra |
| --------- | --------------- | ----------------- | ----------- | ----- | ----- |
| ...       | `addonsManager` | `install`         | `extension` |       | ...   |
| ...       | `addonsManager` | `update`          | `locale`    |       | ...   |
| ...       | `addonsManager` | `sideload_prompt` | `other`     |       | ...   |

But none of these records will indicate that it was produced by the `manage` event. To find all records produced by `manage`, one would have to query all records where

```
category = ...
AND method in [...,]
AND object in [...,]
```

which is not ideal.

Furthermore, if one encounters this data without knowledge of how the `manage` event works, they need to look up the event based on the category, method, and object values in order to find the event, and then query the data again to find all the related events. It's not immediately clear from the data if this record:

| timestamp | category        | method   | object   | value | extra |
| --------- | --------------- | -------- | -------- | ----- | ----- |
| ...       | `addonsManager` | `update` | `locale` |       | ...   |

and and this record:

| timestamp | category        | method    | object      | value | extra |
| --------- | --------------- | --------- | ----------- | ----- | ----- |
| ...       | `addonsManager` | `install` | `extension` |       | ...   |

are related or not.

Another factor that can add to confusion is the fact that other events can share similar values for methods or objects (or even the combination of method and object). For example:

| timestamp | category   | method   | object               | value | extra |
| --------- | ---------- | -------- | -------------------- | ----- | ----- |
| ...       | `normandy` | `update` | `preference_rollout` |       | ...   |

which can further confuser users.

[1]: Events do have name fields, but they aren't included in the event records and thus are not present in the resulting dataset. Also, If a user defines an event in `Events.yaml` without specifying a list of acceptable methods, the method will default to the name of the event for records created by that event.

#### Suggested Convention:

To simplify things in the future, we suggest adding the event name to the category field using dot notation when designing new events:

```
"category.event_name"
```

For example:

- `"navigation.search"`
- `"addonsManager.manage"`
- `"frame.tab"`

This provides 3 advantages:

1. Records produced by this event will be easily identifiable. Also, the event which produced the record will be easier to locate in the code.
2. Events can be controlled more easily. The category field is what we use to "turn on" and "turn off" events. By creating a 1 to 1 mapping between categories and events, we can control events on an individual level.
3. By having the category field act as the event identifier, it makes it easier to pass on events to Amplitude and other platforms.
