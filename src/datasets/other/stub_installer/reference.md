# What is the Stub Installer ping?

When the stub installer completes with almost any result, it generates a ping containing some data about the system and about how the installation went. This ping isn't part of Firefox unified telemetry, it's a bespoke system; we can't use the telemetry client code when it isn't installed yet.

No ping is sent if the installer exits early because initial system requirements checks fail.

## How it’s processed

Installer pings are formed and sent from NSIS code (!) in the stub installer, in the [SendPing subroutine](https://searchfox.org/mozilla-central/source/browser/installer/windows/nsis/stub.nsi).

Like any other ping, they are processed into [ping tables](../../../cookbooks/bigquery/querying.md#structure-of-ping-tables-in-bigquery).

## How to access the data

You can access this data in BigQuery under `firefox_installer.install`.
The following query, for example, gives you the number of successful installs per normalized country code on April 20th, 2021:

```sql
SELECT normalized_country_code,
       succeeded,
       count(*)
FROM firefox_installer.install
WHERE DATE(submission_timestamp) = '2021-04-20'
GROUP BY normalized_country_code,
         succeeded
```

[`STMO#81648`](https://sql.telemetry.mozilla.org/queries/81648/source)

Note about `os_version`: Previous versions of Windows have used a very small set of build numbers through their entire life cycle. However, Windows 10 gets a new build number with every major update (about every 6 months), and many more builds have been released on its insider channels. So, to prevent a huge amount of noise, queries using this field should generally filter out the build number and only use the major and minor version numbers to differentiate Windows versions, unless the build number is specifically needed.
