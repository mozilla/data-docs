# What is the Stub Installer ping?

When the stub installer completes with almost any result, it generates a ping containing some data about the system and about how the installation went. This ping isn't part of Firefox unified telemetry, it's a bespoke system; we can't use the telemetry client code when it isn't installed yet.

No ping is sent if the installer exits early because initial system requirements checks fail.

## How it’s processed

They are formed and sent from NSIS code (!) in the stub installer, in the [SendPing subroutine](https://searchfox.org/mozilla-central/source/browser/installer/windows/nsis/stub.nsi).

They are processed into Redshift by [`dsmo_load`](https://github.com/whd/dsmo_load).

## How to access the data

The Redshift tables are accessible from the `DSMO-RS` data source in [STMO](https://sql.telemetry.mozilla.org/).

The canonical documentation is in [this tree](https://searchfox.org/mozilla-central/source/toolkit/components/telemetry/docs/data/install-ping.rst).

There are three tables produced every day (you can see them in Redshift as `{tablename}_YYYYMMDD`:

- `download_stats_YYYYMMDD` ([source](https://github.com/whd/dsmo_load/blob/master/hindsight/hs_run/output/dsmo_redshift.lua))
- `download_stats_funnelcake_YYYYMMDD` ([source](https://github.com/whd/dsmo_load/blob/master/hindsight/hs_run/output/dsmo_funnelcake_redshift.lua))
- `download_stats_errors_YYYYMMDD` ([source](https://github.com/whd/dsmo_load/blob/master/hindsight/hs_run/output/dsmo_errors_redshift.lua))

The funnelcake tables aggregate funnelcake builds, which have additional metadata for tracking distribution experiments. [More on Funnelcake](https://wiki.mozilla.org/Funnelcake).

`download_stats` (without the date appended) and `download_stats_year` are views that union all (or a year's worth) of the per-day tables together, which makes e.g. `SELECT * LIMIT 10` operations on them quite slow.

Note about `os_version`: Previous versions of Windows have used a very small set of build numbers through their entire life cycle. However, Windows 10 gets a new build number with every major update (about every 6 months), and many more builds have been released on its insider channels. So, to prevent a huge amount of noise, queries using this field should generally filter out the build number and only use the major and minor version numbers to differentiate Windows versions, unless the build number is specifically needed.
