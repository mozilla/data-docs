CEP Matcher
===========

The CEP Matcher tab lets you easily view some current pings of any ping type. To access it, follow 
[these first few directions](cookbooks/realtime_analysis_plugin.md) for accessing the CEP. Once there,
click on the "Matcher" tab. The message-matcher is set by default to `TRUE`, meaning all pings will
be matched. Click "Run Matcher" and a few pings will show up.

## Editing the Message Matcher

Changing the message matcher will filter down the accepted pings, letting you hone in on a certain type.
Generally, you can filter on any fields in a ping. For example, `docType`:

```
Fields[docType] == "main"
```

Or OS:

```
Fields[os] == "Android"
```

We can also combine matchers together:

```
Fields[docType] == "core" && Fields[os] == "Android" && Fields[appName] == "Focus"
```

Note that most of the time, you want just proper telemetry pings, so include this in your matcher:

```
Type == "telemetry"
```

Which would get us a sample of Focus Android core pings.

The [Message Matcher documentation](https://hekad.readthedocs.io/en/v0.10.0/message_matcher.html) has
more information on the syntax.

To see the available fields that you can filter on for any `docType`, see [this document](https://pipeline-cep.prod.mozaws.net/dashboard_output/analysis.moz_telemetry_parquet_schema.parquet.txt).
For example, look under the `telemetry` top-level field at `system-addon-deployment-diagnostics`. The available fields to filter on are:

```
required binary Logger;
required fixed_len_byte_array(16) Uuid;
optional int32 Pid;
optional int32 Severity;
optional binary EnvVersion;
required binary Hostname;
required int64 Timestamp;
optional binary Payload;
required binary Type;
required group Fields {
    required binary submission;
    required binary Date;
    required binary appUpdateChannel;
    required double sourceVersion;
    required binary documentId;
    required binary docType;
    required binary os;
    optional binary environment.addons;
    optional binary DNT;
    required binary environment.partner;
    required binary sourceName;
    required binary appVendor;
    required binary environment.profile;
    required binary environment.settings;
    required binary normalizedChannel;
    required double sampleId;
    required binary Host;
    required binary geoCountry;
    required binary geoCity;
    required boolean telemetryEnabled;
    required double creationTimestamp;
    required binary appVersion;
    required binary appBuildId;
    required binary environment.system;
    required binary environment.build;
    required binary clientId;
    required binary submissionDate;
    required binary appName;
}
```

So, for example, you could have a message matcher like:

```
Type == "telemetry" && Fields[geoCountry] == "US"
```
