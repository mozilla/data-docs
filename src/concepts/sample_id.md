# Sampling in Telemetry data

Since the early days of Telemetry, it has been desirable to have a quick and
simple way to do analysis on a sample of the full population of Firefox
clients.

The mechanism for doing that is encoded in the data itself, namely the
`sample_id` field.

This is a field that is computed from the telemetry `client_id` using
the [CRC] hash function.

This CRC hash is then bucketed into 100 possible values from 0 to 99,
each of which represents a roughly 1% uniform sample of the `client_id` space.

All ping tables that contain a client id, as well as many derived datasets,
include the `sample_id` field.

TL;DR `sample_id = crc32(client_id) % 100`

An example python implementation:

```python
# USAGE: python cid2sid.py 859c8a32-0b73-b547-a5e7-8ef4ed9c4c2d
# Prints
#        Client ID b'859c8a32-0b73-b547-a5e7-8ef4ed9c4c2d' => Sample ID 55
import binascii
import sys

clientid = sys.argv[1].encode()

crc = binascii.crc32(clientid)
sampleid = (crc & 0xFFFFFFFF) % 100
print("Client ID {} => Sample ID {}".format(clientid, sampleid))
```

[crc]: https://en.wikipedia.org/wiki/Cyclic_redundancy_check
