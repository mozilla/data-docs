# Work in Progress

This article is a work in progress.
The work is being tracked in
[this bug](https://bugzilla.mozilla.org/show_bug.cgi?id=1341812).

# Guide to our Experimental Tools

## Shield

- Shield is an addon-based experimentation platform with fine-tuned enrollment criteria. The system add-on landed in FF 53.
- For the moment, it sends back data in its own `shield` type ping, so there's lots of flexibility in data you can collect.
- Uses the Normandy server to serve out study “recipes” (?)
- Annotates the main ping in the environment/experiments block
- The shield system is itself a system add-on, so rolling out changes to the entire system does not require riding release trains
- Strategy and Insights (strategyandinsights@mozilla.com) team are product owners and shepherd the study development and release process along
- Opt-out experiments should be available soon?
- Further reading:
  - https://wiki.mozilla.org/Firefox/SHIELD
  - https://wiki.mozilla.org/Firefox/Shield/Shield_Studies
  - [https://mozilla.github.io/shield-studies-docs/study-process/](BROKEN:https://mozilla.github.io/shield-studies-docs/study-process/)
  - When should you use SHIELD over other options?

## Preference Flipping experiments

Uses Normandy, requires NO additional addon as long as a preference rides the release train

## Heartbeat

Survey mechanism, also run via Normandy

## Telemetry Experiments

Pre-release only
[https://gecko.readthedocs.io/en/latest/browser/experiments/experiments/index.html](BROKEN:https://gecko.readthedocs.io/en/latest/browser/experiments/experiments/index.html)

## Funnelcake

Custom builds of Firefox that are served to some percentage of the direct download population
