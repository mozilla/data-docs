# What is the Stub Installer ping?

When the stub installer completes with almost any result, it generates a ping containing some data about the system and about how the installation went. This ping isn't part of Firefox unified telemetry, it's a bespoke system; we can't use the telemetry client code when it isn't installed yet.

## How it’s processed

They are formed and sent from NSIS code (!) in the stub installer, in the [SendPing subroutine](https://searchfox.org/mozilla-central/source/browser/installer/windows/nsis/stub.nsi). 

They are processed into Redshift by [`dsmo_load`](https://github.com/whd/dsmo_load).

## How to access the data

The Redshift tables are accessible from the `DSMO-RS` data source in [STMO](https://sql.telemetry.mozilla.org/). 

The canonical documentation is in [this tree](https://searchfox.org/mozilla-central/source/browser/installer/windows/docs/StubPing.rst).

There are three tables produced every day (you can see them in Redshift as `{tablename}_YYYYMMDD`:

* `download_stats_YYYYMMDD` ([source](https://github.com/whd/dsmo_load/blob/master/hindsight/hs_run/output/dsmo_redshift.lua))
* `download_stats_funnelcake_YYYYMMDD` ([source](https://github.com/whd/dsmo_load/blob/master/hindsight/hs_run/output/dsmo_funnelcake_redshift.lua))
* `download_stats_errors_YYYYMMDD` ([source](https://github.com/whd/dsmo_load/blob/master/hindsight/hs_run/output/dsmo_errors_redshift.lua))

The funnelcake tables aggregate funnelcake builds, which have additional metadata for tracking distribution experiments. [More on Funnelcake](https://wiki.mozilla.org/Funnelcake).

`download_stats` (without the date appended) and `download_stats_year` are views that union all (or a year's worth) of the per-day tables together, which makes e.g. `SELECT * LIMIT 10` operations on them quite slow.

