# Build metadata

[Buildhub] is a database of metadata for official Mozilla builds of
Firefox, Thunderbird, and Fennec (legacy Firefox for Android).
Support for the new Firefox for Android is being tracked in
[bug 1622948](https://bugzilla.mozilla.org/show_bug.cgi?id=1622948).

It includes data on the [build id](../concepts/terminology.md#build-id) and revision,
which can help you understand what changes went into a specific version
of the product you see in telemetry.

Buildhub data is exported to BigQuery as it becomes available (generally very soon after our software is released) at `mozdata.telemetry.buildhub2`.

The `build` column contains a struct value
that matches the structure of the `buildhub.json` files
built by [`informulate.py`] during a Firefox build.

An example of a `build` record is:

```json
{
  "build": {
    "as": "/builds/worker/workspace/build/src/clang/bin/clang -std=gnu99",
    "cc": "/builds/worker/workspace/build/src/clang/bin/clang -std=gnu99",
    "cxx": "/builds/worker/workspace/build/src/clang/bin/clang++",
    "date": "2019-06-03T18:14:08Z",
    "host": "x86_64-pc-linux-gnu",
    "id": "20190603181408",
    "target": "x86_64-pc-linux-gnu"
  },
  "download": {
    "date": "2019-06-03T20:49:46.559307+00:00",
    "mimetype": "application/octet-stream",
    "size": 63655677,
    "url": "https://archive.mozilla.org/pub/firefox/candidates/68.0b7-candidates/build1/linux-x86_64/en-US/firefox-68.0b7.tar.bz2"
  },
  "source": {
    "product": "firefox",
    "repository": "https://hg.mozilla.org/releases/mozilla-beta",
    "revision": "ed47966f79228df65b6326979609fbee94731ef0",
    "tree": "mozilla-beta"
  },
  "target": {
    "channel": "beta",
    "locale": "en-US",
    "os": "linux",
    "platform": "linux-x86_64",
    "version": "68.0b7"
  }
}
```

The fields of `build` are documented in the [schema].

Notably, the timestamp in `build.download.date` reflects the publication date of the build on https://archive.mozilla.org.
This is earlier than the moment that the build would have been offered to clients through either the download website
or the in-product updater.

To find the earliest publication date for each release in the Firefox 82 series,
you can use a query like:

```sql
SELECT
    build.target.version,
    MIN(build.download.date) AS published
FROM mozdata.telemetry.buildhub2
WHERE
    build.target.version LIKE "82.%"
    AND ENDS_WITH(build.source.repository, "mozilla-release")
GROUP BY 1
ORDER BY 1
```

[buildhub]: https://buildhub.moz.tools/
[`informulate.py`]: https://searchfox.org/mozilla-central/source/toolkit/mozapps/installer/informulate.py
[schema]: https://github.com/mozilla-releng/buildhub2/blob/master/schema.yaml
