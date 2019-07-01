# Attribution of Firefox Accounts

Users can create or login to an account through an increasingly large number of relying services and entrypoints. This article describes how we attribute authentications to their point of origin, and documents some of the most frequently trafficked entrypoints (it would not be feasible to list them all, but we will try to update this document when there are substantial changes).

## Types of Attribution
We can attribute accounts to the **service** that they sign up for, as well as the **entrypoint** that they use to begin the authentication flow. Each service typically has many entrypoints; sync, for example, has web-based entrypoints and browser-based entrypoints (see below).

### Service Attribution
There is a variable called `service` that we use to (1) attribute users to the relying services of FxA that they have authenticated with and (2) attribute individual events to the services they are associated with. Except in the case of sync, `service` is a mapping from the oauth `client_id` of the relying service/product to a human readable string. Note that this mapping is currently maintained by hand, and is done after the events have been logged by the server. Currently, mapping to the human-readable `service` variable is only done for amplitude metrics, where it is treated as a user property. There is also a `service` variable in the `activity_events` and `flow_metadata` re:dash tables (FxA Activity Metrics data source), however it only contains the opaque oauth `client_id`, not the human-readable string. A table of some of the most common oauth `client_id`s along with their corresponding `service` mapping is shown below. This is not a complete list.

|`service`|oauth `client_id`|Description|
|---|---|---|
|`lockbox`|`e7ce535d93522896`|Lockwise App for Android|
|`lockbox`|`98adfa37698f255b`|Lockwise App for iOS|
|`fenix`|`a2270f727f45f648`|Sync implementation for Fenix|
|`fx-monitor`|`802d56ef2a9af9fa`|Firefox Monitor ([website](https://monitor.firefox.com/))|
|`send`|`1f30e32975ae5112`|Firefox Send ([website](https://send.firefox.com/))|
|`send`|`20f7931c9054d833`|Firefox Send (android app)|
|`pocket-mobile`|`7377719276ad44ee`|Pocket Mobile App|
|`pocket-web`|`749818d3f2e7857f`|Pocket Website|
|`firefox-addons`|`3a1f53aabe17ba32`|addons.mozilla.org|
|`amo-web`|`a4907de5fa9d78fc`|addons.mozilla.org (still unsure how this differs from `firefox-addons`)|
|`screenshots`|`5e75409a5a3f096d`|Firefox Screenshots ([website](https://screenshots.firefox.com/), no longer supported)|
|`notes`|`a3dbd8c5a6fd93e2`|Firefox Notes (desktop extension)|
|`notes`|`7f368c6886429f19`|Firefox Notes (android app)|

In amplitude, there is also a `fxa_services_used` user property which maintains an array of all the services a user has authenticated with.
