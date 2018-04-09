# HTTP Edge Server Specification

This document specifies the behavior of the server which is accepts Telemetry submissions from Firefox.

The original implementation of the HTTP Edge Server was tracked in [Bug 1129222](https://bugzilla.mozilla.org/show_bug.cgi?id=1129222).

## General Data Flow
HTTP submissions come in from the wild, hit a load balancer, then optionally an nginx proxy, then the HTTP Edge Server described in this document. Data is accepted via a POST/PUT request from clients, which the server will wrap in a [Heka message](https://hekad.readthedocs.io/en/dev/message/index.html) and forward to two places: the [Services Data Pipeline](data_pipeline.md), where any further processing, analysis, and storage will be handled; as well as to a short-lived S3 bucket which will act as a fail-safe in case there is a processing error and/or data loss within the main Data Pipeline.

## GET Requests
Accept GET on `/status`, returning `OK` if all is well. This can be used to check the health of web servers.

## POST/PUT Requests
Treat POST and PUT the same. Accept POST or PUT to URLs of the form

`^/submit/namespace/[id[/dimensions]]$`

Example Telemetry format:

`/submit/telemetry/docId/docType/appName/appVersion/appUpdateChannel/appBuildID`

Specific Telemetry example:

`/submit/telemetry/ce39b608-f595-4c69-b6a6-f7a436604648/main/Firefox/61.0a1/nightly/20180328030202`

Note that `id` above is a unique document ID, which is used for de-duping submissions. This is *not* intended to be the `clientId` field from Telemetry. If `id` is omitted, we will not be able to de-dupe based on submission URLs.

### Namespaces
Each allowed namespace should have some configuration, and it should be relatively easy to add new namespaces.

Per-namespace configuration:
* Required: Max Payload size
* Required: Max path length
* Required: Include Client IP y/n
* Optional: Mapping of dimension index -> field name
* Optional: “logger” value (default is to use the namespace, but could be useful to re-map)

### Creating a Heka message from submission
Main message fields:
* POST Body -> `Payload`
* Client IP -> `remote_addr` (if indicated by the namespace config)
* Now -> `timestamp` ("Now" means the current time on the edge server node. Should use `ntp` or similar to ensure correct server time)
* namespace -> `logger`
* id -> `uuid` (if supplied, otherwise randomly generate a UUID)
* Edge hostname -> `hostname`
* Type -> `incoming` (open to suggestions for naming) Some indication that this is a raw message.

Other fields:
* Store the part of the path after the namespace in `Fields["path"]`
* Try to get the host the client used (`incoming.telemetry.m.o` vs. `fxos.t.m.o` etc).

### Forwarding to the pipeline
Send the constructed message into the pipeline, retrying as needed. The preferred transport is Heka's `KafkaOutput`, but we may use another transport such as TCP for testing / development.

Also send a meta-message into the pipeline for stats/monitoring purposes:
```
  stat = {
    "url": request_url,
    "duration_ms": duration_ms, // how long it took to serve this request
    "code": code, // http status code
    "size": payload_bytes, // may also want “message_size”
    "message": msg, // error message (if any) or “OK"
    "timestamp": new Date() // same as the Heka Message timestamp
  };
```

The above meta-message keeps track of messages that were too large and various other errors.

## Server Responses
### GET Response codes
* *200* - OK. `/status` and all’s well
* *404* - Any GET other than `/status`
* *500* - All is not well

### POST/PUT Response codes
* *200* - OK. Request accepted into the pipeline.
* *400* - Bad request, for example an un-encoded space in the URL.
* *404* - not found - POST/PUT to an unknown namespace
* *405* - wrong request type (anything other than POST/PUT)
* *411* - missing content-length header
* *413* - request body too large (Note that if we have badly-behaved clients that retry on `4XX`, we should send back 202 on body/path too long).
* *414* - request path too long (See above)
* *500* - internal error

## Forwarding to S3
As a fail-safe, we archive the incoming requests to S3 with as little processing as possible. Requests are written to local files and rotated and uploaded externally to the web server.

## Other Considerations
### Compression
It is not desirable to do decompression on the edge node. We want to pass along messages from the HTTP Edge node without "cracking the egg" of the payload.

We may also receive badly formed payloads, and we will want to track the incidence of such things within the main pipeline.

### Bad Messages
We should provide examples / recipes for sending various bad messages out to a “landfill” output - ideally an S3 bucket with short TTL. We want to be able to investigate these messages since we get a lot of failed JSON parsing, bad gzip encoding, etc, and capturing the bad messages will be helpful for debugging.

### GeoIP Lookups
The GeoIP lookup is currently planned to be a part of the main pipeline (after the Edge node described herein).  So the namespace config for whether or not to include Client IP would determine whether or not we are able to later do the GeoIP lookup.  It might be better to do the lookup on the Edge node, though, then we would not need to pass the Client IP in to the pipeline at all.

In either case, the Client IP address will be removed before the message hits long-term storage.

The Geo information will not be stored in the JSON Payload, but will rather be stored in a protobuf field in the Heka message.

### Data Retention
We need a mechanism for specifying the retention period for various data sources that will be sent into the pipeline. This is probably not within the scope of the HTTP Edge Server, but the per-endpoint configuration may be a good enough place to specify the retention period.
