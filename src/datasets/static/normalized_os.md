# Normalized OS

The OS names and versions received in telemetry is not necessarily the accepted common name.
The `normalized_os_name` and `normalized_os_version` tables in the `static` dataset serve as a
lookup table for mapping the telemetry name to the common name.

### OS Names

For OS names, Mac clients send `Darwin`, Windows clients send `Windows_NT`, and Linux may send the
distribution name.
Pings should already have a `normalized_os` field that corrects this.
The `normalized_os_name` table exists as an alternative lookup table.

Example query:

```sql
SELECT
  client_id,
  environment.system.os.name,
  normalized_os_name
FROM
  telemetry_stable.main_v4
LEFT JOIN
  static.normalized_os_name
ON
  (environment.system.os.name = os_name)
```

### OS Versions

OS versions for some OS's are not properly normalized in telemetry. For example, the version
reported by Mac clients is the Darwin version instead of the MacOS version and the version
reported by Android Fennec clients is the Android SDK version instead of the Android version.
The `normalized_os_version` table can be used to map the sent version to the "display version"
of the OS.

The table uses a regular expression to look up the OS version so `REGEXP_CONTAINS` should be used.
An example query can be found here: <https://sql.telemetry.mozilla.org/queries/67040/source>
