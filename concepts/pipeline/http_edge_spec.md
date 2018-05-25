# HTTP Edge Server Specification

This document specifies the behavior of the server that accepts submissions from
any HTTP client e.g. Firefox telemetry.

The original implementation of the HTTP Edge Server was tracked in
[Bug 1129222](https://bugzilla.mozilla.org/show_bug.cgi?id=1129222).

## General Data Flow

HTTP submissions come in from the wild, hit a load balancer, then optionally an
Nginx proxy, then the HTTP Edge Server described in this document. Data is
accepted via a POST/PUT request from clients, which the server will wrap in a
[Heka message](http://mozilla-services.github.io/lua_sandbox/heka/message.html)
and forward to two places: the [Services Data Pipeline](data_pipeline.md), where
any further processing, analysis, and storage will be handled; as well as to a
short-lived S3 bucket which will act as a fail-safe in case there is a
processing error and/or data loss within the main Data Pipeline.

### Namespaces

Namespaces are used to control the processing of data from different types of
clients, from the metadata that is collected to the destinations where the data
is written, processed and accessible. Namespaces are
[configured](https://github.com/mozilla-services/nginx_moz_ingest#example-configuration)
in Nginx using a location directive, to request a new namespace file a bug
against the [Data Platform Team](https://bugzilla.mozilla.org/enter_bug.cgi?product=Data%20Platform%20and%20Tools&component=Pipeline%20Ingestion)
with a short description of what the namespace will be used for and the desired
configuration options. Data sent to a namespace that is not specifically
configured is assumed to be in the [non-Telemetry JSON format described here](/cookbooks/new_ping.md).

### Forwarding to the pipeline

The constructed Heka protobuf message to is written to disk and the pub/sub
pipeline (currently Kafka). The messages written to disk serve as a fail-safe,
they are batched and written to S3 (landfill) when they reach a certain size or
timeout.

#### Edge Server Heka Message Schema

* required binary **`Uuid`**;                   // Internal identifier randomly generated
* required int64  **`Timestamp`**;              // Submission time (server clock)
* required string **`Hostname`**;               // Hostname of the edge server e.g. `ip-172-31-2-68`
* required string **`Type`**;                   // Kafka topic name e.g. `telemetry-raw`
* required group  **`Fields`**
   * required string **`uri`**;                 // Submission URI e.g. `/submit/telemetry/6c49ec73-4350-45a0-9c8a-6c8f5aded0cf/main/Firefox/58.0.2/release/20180206200532`
   * required binary **`content`**;             // POST Body
   * required string **`protocol`**;            // e.g. `HTTP/1.1`
   * optional string **`args`**;                // Query parameters e.g. `v=4`
   * optional string **`remote_addr`**;         // In our setup it is usually a load balancer e.g. `172.31.32.229`
   * // HTTP Headers specified in the [production edge server configuration](https://github.com/mozilla-services/puppet-config/blob/06ec0beae535184cc7455c3c2c32b6571160196d/pipeline/modules/pipeline/templates/edge/nginx.conf.erb#L24)
   * optional string **`Content-Length`**;      // e.g. `4722`
   * optional string **`Date`**;                // e.g. `Mon, 12 Mar 2018 00:02:18 GMT`
   * optional string **`DNT`**;                 // e.g. `1`
   * optional string **`Host`**;                // e.g. `incoming.telemetry.mozilla.org`
   * optional string **`User-Agent`**;          // e.g. `pingsender/1.0`
   * optional string **`X-Forwarded-For`**;     // Last entry is treated as the client IP for geoIP lookup e.g. `10.98.132.74, 103.3.237.12`
   * optional string **`X-PingSender-Version`**;// e.g. `1.0`

## Server Request/Response

### GET Request

Accept GET on `/status`, returning `OK` if all is well. This can be used to
check the health of web servers.

### GET Response codes

* *200* - OK. `/status` and all’s well
* *404* - Any GET other than `/status`
* *500* - All is not well

### POST/PUT Request
Treat POST and PUT the same. Accept POST or PUT to URLs of the form

`^/submit/namespace/[id[/dimensions]]$`

Example Telemetry format:

`/submit/telemetry/docId/docType/appName/appVersion/appUpdateChannel/appBuildID`

Specific Telemetry example:

`/submit/telemetry/ce39b608-f595-4c69-b6a6-f7a436604648/main/Firefox/61.0a1/nightly/20180328030202`

Example non-Telemetry format:

`/submit/namespace/doctype/docversion/docid`

Specific non-Telemetry example:

`/submit/eng-workflow/hgpush/1/2c3a0767-d84a-4d02-8a92-fa54a3376049`

Note that `id` above is a unique document ID, which is used for de-duping
submissions. This is *not* intended to be the `clientId` field from Telemetry.
If `id` is omitted, we will not be able to de-dupe based on submission URLs. It
is recommended that `id` be a [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier).

### POST/PUT Response codes

* *200* - OK. Request accepted into the pipeline.
* *400* - Bad request, for example an un-encoded space in the URL.
* *404* - not found - POST/PUT to an unknown namespace
* *405* - wrong request type (anything other than POST/PUT)
* *411* - missing content-length header
* *413* - request body too large (Note that if we have badly-behaved clients that retry on `4XX`, we should send back 202 on body/path too long).
* *414* - request path too long (See above)
* *500* - internal error

## Other Considerations

### Compression

It is not desirable to do decompression on the edge node. We want to pass along
messages from the HTTP Edge node without "cracking the egg" of the payload.

We may also receive badly formed payloads, and we will want to track the
incidence of such things within the main pipeline.

### Bad Messages

Since the actual message is not examined by the edge server the only failures
that occur are defined by the response status codes above. Messages are only
forwarded to the pipeline when a response code of 200 is returned to the client.

### GeoIP Lookups

No GeoIP lookup is performed by the edge server. If a client IP is available the
the data warehouse loader performs the lookup and then discards the IP before
the message hits long-term storage.

### Data Retention

The edge server only stores data while batching and will have a retention time
of `moz_ingest_landfill_roll_timeout` which is generally only a few minutes.
Retention time for the S3 landfill, pub/sub, and the data warehouse is outside
the scope of this document.
