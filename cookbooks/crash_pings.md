# Working with Crash Pings

Here are some snippets to get you started querying crash pings
from the Dataset API.

We can first load and instantiate a Dataset object to query
the crash pings, and look at the possible fields to filter on:

```python
from moztelemetry.dataset import Dataset
telem = Dataset.from_source("telemetry")
telem.schema
# => 'submissionDate, sourceName, sourceVersion, docType, appName, appUpdateChannel,
#     appVersion, appBuildId'
```

The more specific these filters, the faster it can be pulled.
The fields can be filtered by either value or a callable.
For example, a version and date range can be specified from the
`v5758` and `dates`lambdas below:

```python
v5758 = lambda x: x[:2] in ('57', '58')
dates = lambda x: '20180126' <= x <= '20180202'
telem = (
    Dataset.from_source("telemetry")
    .where(docType='crash', appName="Firefox", appUpdateChannel="release",
           appVersion=v5758, submissionDate=dates)
)
```

Now, referencing the [docs for the crash ping](https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/data/crash-ping.html), the desired fields
can be selected and brought in as a spark RDD named `pings`

```python
sel = (
    telem.select(
        os_name='environment.system.os.name',
        os_version='environment.system.os.version',
        app_version='application.version',
        app_architecture='application.architecture',
        clientId='clientId',
        creationDate='creationDate',
        submissionDate='meta.submissionDate',
        sample_id='meta.sampleId',
        modules='payload.stackTraces.modules',
        stackTraces='payload.stackTraces',
        oom_size='payload.metadata.OOMAllocationSize',
        AvailablePhysicalMemory='payload.metadata.AvailablePhysicalMemory',
        AvailableVirtualMemory='payload.metadata.AvailableVirtualMemory',
        TotalPhysicalMemory='payload.metadata.TotalPhysicalMemory',
        TotalVirtualMemory='payload.metadata.TotalVirtualMemory',
        reason='payload.metadata.MozCrashReason',
        payload='payload',
    )
)
pings = sel.records(sc)
```
