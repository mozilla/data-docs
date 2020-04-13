# Dynamic telemetry

Add-on studies may choose to implement new
[scalar] or [event] telemetry probes.
These probes are not described in
the probe metadata files in the Firefox source tree
and are not described in the [probe dictionary].
Often, they are documented in the repositories
associated with the add-on studies instead.

There is no complete central reference for these.
This page is intended as a partial historical reference
for these probes.

| Start date | Study  | Probe type | Probe names | Documentation |
| ---------- | ------ | ---------- | ----------- | ------------- |
| 2020-04 | [HTTP Upgrade](https://bugzilla.mozilla.org/show_bug.cgi?id=1623996) | scalar | `httpsUpgradeStudy.https`, `httpsUpgradeStudy.nonupgradable`, `httpsUpgradeStudy.upgradable` | https://bugzilla.mozilla.org/show_bug.cgi?id=1629585 |
| 2020-02 | [Search interventions](https://bugzilla.mozilla.org/show_bug.cgi?id=1564506) | scalar | `urlbarInterventionsExperiment.tipShownCount`, `.tipPickedCount` | missing |
| 2019-10 | [DNS over HTTPS heuristics](https://bugzilla.mozilla.org/show_bug.cgi?id=1573840) | event | `doh#evaluate.heuristics`, `doh#state` | https://github.com/mozilla/doh-rollout/blob/6787458a6901ef3b2a8fef86a179899213809534/docs/telemetry.md |

[scalar]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/collection/scalars.html
[event]: https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/collection/events.html
[probe dictionary]: https://probes.telemetry.mozilla.org/
