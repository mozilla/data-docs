# HTTP Edge Server Specification

This document specifies the behavior of the server that accepts submissions from
any HTTP client e.g. Firefox telemetry.

The original implementation of the HTTP Edge Server was tracked in
[Bug 1129222](https://bugzilla.mozilla.org/show_bug.cgi?id=1129222).

## General Data Flow

HTTP submissions come in from the wild, hit a load balancer,
then the HTTP Edge Server described in this document.
Data is accepted via a POST/PUT request from clients,
and forwarded to the [Data Pipeline](gcp_data_pipeline.md), where
any further processing, analysis, and storage will be handled.

Submission payloads are expected to be optionally-gzipped JSON
documents described by a [JSONSchema].

[jsonschema]: https://json-schema.org/

## Server Request/Response

### GET Request

The edge server does not serve application data over GET. It exposes
[Dockerflow] health-check endpoints:

- `/__lbheartbeat__` - returns 200 unconditionally; used by the load balancer
  and Kubernetes probes to confirm the server is up.
- `/__heartbeat__` - returns 200 when internal checks pass (enough free disk
  for the local queue, and the queue is accessible) and 500 otherwise.
- `/__version__` - returns build and version information.

[dockerflow]: https://github.com/mozilla-services/Dockerflow

### GET Response codes

- _200_ - a health check passed (`/__lbheartbeat__`, or `/__heartbeat__` when
  all checks pass), or version info was returned (`/__version__`)
- _404_ - any other GET path
- _500_ - a `/__heartbeat__` check failed

### POST/PUT Request

Treat POST and PUT the same. Accept POST or PUT to URLs of the form:

`/submit/<namespace>/<docType>/<docVersion>/<docId>`

A specific example submission URL looks like:

`/submit/eng-workflow/hgpush/1/2c3a0767-d84a-4d02-8a92-fa54a3376049`

With the following components:

- `namespace` - an identifier used for grouping a set of related document types. Typically this represents an application that produces data.
- `docType` - a short descriptive name of the document type. Examples include `event`, `crash`, or `baseline`
- `docVersion` - a numeric value indicating the version of the schema for this `docType`
- `docId` - a UUID identifying the exact submission. If the same `docId` is seen more than once, it will be discarded as a duplicate.

The combination of `namespace`, `docType` and `docVersion` together identify a specific schema to be used for validating submissions to the above endpoint.

If a schema is not present in the [schemas repository] corresponding to this combination, the submission
will be considered an error and will not proceed to the data lake.

#### Special handling for Firefox Desktop Telemetry

Firefox Desktop Telemetry uses a slightly different URL scheme:

`/submit/telemetry/docId/docType/appName/appVersion/appUpdateChannel/appBuildID?v=4`

A specific example:

`/submit/telemetry/ce39b608-f595-4c69-b6a6-f7a436604648/main/Firefox/61.0a1/nightly/20180328030202?v=4`

Here the `namespace` is fixed as "telemetry", and there is no `docVersion` in the URL.
This means that incoming JSON documents must be parsed to determine the schema version
to apply for validation. This logic is part of the downstream [decoder] job.
Also note the query parameter suffix `?v=4`, a historical convention sent by
Firefox Desktop. The edge server routes on the URL path only and forwards the
request body opaquely; the query string is preserved as request metadata.

### POST/PUT Response codes

- _200_ - OK. Request accepted into the pipeline.
- _400_ - Bad request, for example an un-encoded space in the URL.
- _404_ - not found - POST/PUT to an unknown namespace
- _405_ - wrong request type (anything other than POST/PUT)
- _413_ - request body too large
- _431_ - a request header (or other captured metadata attribute) exceeds PubSub's 1024-byte attribute limit
- _500_ - internal error
- _507_ - insufficient storage - the edge's local retry queue is full (for example during an extended PubSub outage)

### Supported HTTP Headers

The following headers will be passed through the pipeline and made available as metadata.

- `Date` - The client-supplied timestamp of the incoming request.
  Used for computing client clock skew.
- `DNT` - The "Do Not Track" header.
- `X-PingSender-Version` - The version of [Pingsender] used to send this ping (if applicable).
- `X-Debug-ID` - An optional tag used to make data available to the [Glean Debug View][gdv].
- `X-Source-Tags` - An optional comma-separated list of tags related to the client source; pings sent from automated testing should include the "automation" tag so that they are not included in analyses

[pingsender]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/internals/pingsender.html
[gdv]: https://debug-ping-preview.firebaseapp.com/

## Other Considerations

### Compression

Compression of submission payloads is optional but recommended.

The supported compression scheme is `gzip`.

We do not decompress or validate the content of submissions at the edge,
the server will reply with a success code even if a message is badly formed.

Badly formed data is still accepted and made available for monitoring, recovery,
analysis, and analysis purposes.

### Bad Messages

Since the actual message is not examined by the edge server the only failures
that occur are defined by the response status codes above. Messages are only
forwarded to the pipeline when a response code of `200` is returned to the client.

### GeoIP Lookups

No GeoIP lookup is performed by the edge server. If a client IP is available the
the decoder performs the lookup and then discards the IP before the message hits
long-term storage.

### Data Retention

The edge server only stores data while waiting for it to be accepted to
PubSub, spilling to local disk in the case of a PubSub outage.

This means that in the normal case, data is not retained on the edge at all.
In the case of errors writing to PubSub, data is retained until the service
is restored and messages can be flushed to the queue.
Based on [past outages], this is typically a few hours or less.

[past outages]: https://status.cloud.google.com/incident/cloud-pubsub
[schemas repository]: https://github.com/mozilla-services/mozilla-pipeline-schemas
[decoder]: gcp_data_pipeline.md#decoding
