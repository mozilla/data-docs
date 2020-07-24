The `clients_last_seen` dataset is useful for efficiently determining exact
user counts such as [DAU and MAU](../../../cookbooks/dau.md).
It can also allow efficient calculation of other windowed usage metrics
like retention via its [bit pattern fields](../../../cookbooks/clients_last_seen_bits.md).

It does *not* use approximates, unlike the HyperLogLog algorithm used in the
[`client_count_daily` dataset](/datasets/obsolete/client_count/reference.md),
and it includes the most recent values in a 28 day window for all columns in
the [`clients_daily` dataset](/datasets/batch_view/clients_daily/reference.md).

This dataset should be used instead of `client_count_daily`.
