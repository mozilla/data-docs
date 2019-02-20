# Datasets available to use with the Dataset class in `python_moztelemetry`

The `python_moztelemetry` library gives easy access to the raw telemetry ping data via PySpark. For reference, see below for commonly used dataset schemas available through the `python_moztelemetry` API. The `telemetry`, `telemetry-cohorts`  and `telemetry-sample` schemas are listed, but see notes below on how to see all tables you can pass to the [`Dataset`](https://mozilla.github.io/python_moztelemetry/api.html#dataset) class.

Usage example:

```
records = Dataset.from_source('telemetry').where(
    docType='main',
    submissionDate='20160701',
    appUpdateChannel='nightly'
)
```

## `telemetry`

 *Field* | *Allowed values* 
-------|----------------
 `submissionDate`   | *  
 `sourceName   `    | *  
 `sourceVersion`    | * 
 `docType`          | `idle-daily` 
 |                   | `saved-session` 
 |                   | `android-anr-report` 
 |                   | `ftu`  
 |                   | `loop` 
 |                   | `flash-video` 
 |                   | `main` 
 |                   | `activation` 
 |                   | `deletion` 
 `appName`          | `Firefox` 
 |                   | `Fennec` 
 |                   | `Thunderbird` 
 |                   | `FirefoxOS` 
 |                   | `B2G` 
 `appUpdateChannel` | `default `
  |                  | `nightly` 
  |                  | `aurora` 
  |                  | `beta` 
  |                  | `release` 
  |                  | `esr` 
 `appVersion`       | * 


## `telemetry-cohorts` 

Partitioned by `experimentId`

 *Field* | *Allowed values* 
-------|----------------
 `submissionDate`     | *  
 `docType`            | *  
 `experimentId`       | *  
 `experimentBranch`   | *   


## `telemetry-sample` 

 *Field* | *Allowed values* 
-------|----------------
`submissionDate` | * 
`sourceName` 	 | * 
`sourceVersion`  | * 
`docType`        | `idle-daily` 
 |               | `saved-session` 
 |               | `android-anr-report` 
 |               | `ftu` 
 |               | `loop`
 |               | `flash-video` 
 |               | `main` 
 |               | `activation` 
 |               | `deletion` 
 |               | `crash` 
 |               | `uitour-tag` 
 |               | `heartbeat` 
 |               | `core` 
 |               | `b2g-installer-device` 
 |               | `b2g-installer-flash` 
 |               | `advancedtelemetry` 
 |               | `appusage` 
 |               | `testpilot` 
 |               | `testpilottest` 
 |               | `malware-addon-states` 
 |               | `sync` 
 |               | `outofdate-notifications-system-addon` 
 |               | `tls-13-study` 
 |               | `shield-study` 
 |               | `system-addon-deployment-diagnostics` 
 `appName`        | `Firefox` 
 |               | `Fennec` 
 |               | `Thunderbird` 
 |               | `FirefoxOS` 
 |               | `B2G` 
 `appUpdateChannel` | `default` 
 |                | `nightly` 
 |               | `aurora` 
 |               | `beta` 
 |               | `release` 
 |               | `esr` 
 `appVersion`     | * 
 `sampleId`       | *



## Pull all table schemas from the metadata S3 bucket

Load the metadata bucket (name from (here)[https://github.com/mozilla/python_moztelemetry/blob/09ddf1ec7d953a4308dfdcb0ed968f27bd5921bb/moztelemetry/dataset.py#L402])

```
from io import BytesIO
import json

import boto3
from IPython.display import HTML, Markdown, display
from tabulate import tabulate

session = boto3.Session(profile_name="cloudservices-aws-dev")
s3 = session.resource("s3")
metadata_bucket = s3.Bucket("net-mozaws-prod-us-west-2-pipeline-metadata") 


```

List the tables with description:

```
stream = BytesIO()
metadata_bucket.download_fileobj("sources.json", stream)
stream.seek(0)
sources = json.load(stream)

display(HTML(
    tabulate(sorted([k, v["description"]] for k, v in sources.items()),
             headers=["Stub", "Description"],
             tablefmt="html")
))
```

List schemas in each table:

```
for stub in sorted(sources.keys()):
    stream = BytesIO()
    
    try:
        metadata_bucket.download_fileobj(stub + "/schema.json", stream)
    except Exception as e:
        print("no schema for", stub)
        continue
    
    stream.seek(0)
    schema = json.load(stream)
    
    d = [(dim["field_name"], "<br>".join(dim["allowed_values"])) for dim in schema["dimensions"]]
    
    display(Markdown(f"## {stub}"))
    display(HTML(tabulate(d, headers=["Field", "Allowed values"], tablefmt="html"))) 
```



