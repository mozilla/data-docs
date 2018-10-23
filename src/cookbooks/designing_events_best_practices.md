# Designing Telemetry Events Best Practices

## Naming Events/Probes:

One of the limitations of the Telemetry Events API is that it is difficult to distinguish between events produced by different probes. The API allows for a lot of flexibility. Any probe written into Firefox can create an event with any values the following fields: 

	| Timestamp | Category (string) | Method (string) | Object (string) | Value (string) | Extra (map) |

With the following restrictions: 
* The Category, Method, and Object of any event produced by the probe must have a value. 
* All combinations of Category, Method, and Object values must be unqiue to that probe (no other probes can produce the same combination). 

However, there is no identifier or name field for the probe itself. Furthermore, although the combinations of Category, Method, and Object for a probe must be unique, individually, those fields can share values with other probes. 

This can make it confusing and difficult to isolate events from a particular probe, or find what probe produced a specific event. 

#### Suggested Convention: 

To deal with this API limitation, we suggest recording the probe name in the Category field of the event in this format: 

```
"category.probe_name"
```

For example: 
* ```"navigation.search"```
* ```"frame.tab"```
* ```"encounter.popup"```


This provides 3 advantages: 
1. Events produced by this probe will be easily identifiable. Conversely, the probe which produced the event will be easier to locate in the code. 
2. Probes can be controlled easier. The category field is what we use to "turn on" and "turn off" events. By creating a 1 to 1 mapping between categories and probes, we can control events on an individual probe level. 
3. By having the category field act as the probe identifier, it makes it easier to pass on events to Amplitude and other platforms. 


