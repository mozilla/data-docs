_Note: some of the information in this chapter is a duplication of the info found on [this](https://wiki.mozilla.org/CloudServices/Sync/ReDash) wiki page. You can also find more detailed information about the data contained in the sync ping [here](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/sync-ping.html)_

`sync_summary` and `sync_flat_summary` are the primary datasets that track the health of sync. `sync_flat_summary` is derived from `sync_summary` by unpacking/exploding the `engines` field of the latter, so they ultimately contain the same data (see below).

## Which dataset should I use?

Which dataset to use depends on whether you are interested in _per-engine_ sync success or _per-sync_ sync success (see below). If you are interested in whether a sync failed overall, regardless of which engine may have caused the failure, then you can use `sync_summary`. Otherwise, if you are interested in per-engine data, you should use `sync_flat_summary`.

If you aren't sure, or just trying to get acquainted, you should probably just use `sync_flat_summary`.
