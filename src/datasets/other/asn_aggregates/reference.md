# Autonomous system aggregates

In the normal course of processing incoming telemetry,
the contents of pings are separated from the IP address of the client that sent the ping.
Analysts do not have access to the IP address data,
and the IP address data is discarded after several days.

To provide some insight about the different experiences users have on different ISP networks,
while preserving the IP privacy of individual users,
this dataset computes some aggregates from the telemetry data
before the IP address information is discarded.
The dataset is computed each day from the pings received the prior day.

The motivating question for this dataset was to understand
which network operators are using the
[`use-application-dns.net`](https://use-application-dns.net)
canary domain to disable DNS over HTTPS (DoH) by default for clients using their networks.
If a user has not specifically turned DoH on or off,
Firefox checks for indications that DoH should not be enabled.
One of these checks is to perform a lookup for the canary domain
using the client's default DNS resolver.
If the lookup returns a `NXDOMAIN` error code indicating the canary domain does not exist,
DoH will not be enabled by default.
Network operators control this behavior
by configuring the resolvers they provision for their clients.

An [autonomous system](<https://en.wikipedia.org/wiki/Autonomous_system_(Internet)>)
represents a network with a common routing policy,
often because it is controlled by a single entity.
Autonomous systems advertise a set of routes, representing blocks of network addresses.
We use them as a way to identify the entity controlling an IP address.

The `asn_aggregates` dataset,
created in [bug 1615269](https://bugzilla.mozilla.org/show_bug.cgi?id=1615269),
contains the columns:

- `autonomous_system_number` (int64): the number of the autonomous system
  from which pings were submitted
- `submission_date` (date): the date that pings reached the ingestion endpoint
- `n_clients` (int64): number of Firefox clients sending event pings that day, from that AS
- `doh_enabled` (int64): number of clients who sent a `enable_doh` result
  **for the canary heuristic** that day, from that AS
- `doh_disabled` (int64): number of clients who sent a `disable_doh` result
  **for the canary heuristic** that day, from that AS

The canary heuristic indicates whether a client was able to resolve
[`use-application-dns.net`](https://use-application-dns.net);
this is a mechanism available to network operators
who may choose to disable DoH by default for their clients.

We record rows only for ASs where `n_clients` is at least 500.

The ingestion endpoint only accepts connections with IPv4.
If that changes, clients submitting telemetry from IPv6 addresses will be ignored by this dataset.

The client AS number is determined by looking up the client's IP address in a MaxMind database.

Some notes on interpretation:

- ASs can change route announcements frequently, so the MaxMind database may be stale
- Telemetry is not necessarily sent on network change events,
  so users may record activity on one network and submit it from another.
- The number of distinct client evaluating DoH heuristics is not currently captured;
  if clients report both enabled and disabled states for DoH, they will be double-counted.
