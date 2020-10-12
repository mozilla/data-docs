# Client Implementation Guidelines for Experiments

There are three supported approaches for enabling experimental features for Firefox:

- [Firefox Prefs](#prefs)
  - Prefs can be used to control features that **land in-tree**.
    [Feature Gates](#feature-gates) provide a wrapper around prefs that can be used from JavaScript.
- [Firefox Extensions](#extensions) AKA "**Add-ons**".
  - If the feature being tested should not land in the tree, or if it will ultimately ship as an extension, then an extension should be used.

New features go through the standard Firefox review, testing, and deployment processes, and are then enabled experimentally in the field using [Normandy][normandy-docs].

## Prefs

Firefox Preferences (AKA "prefs") are commonly used to enable and disable features. However, prefs are more complex to implement correctly than [feature gates](#feature-gates).

**Each pref should represent a different experimental treatment**. If your experimental feature requires multiple prefs, then Normandy does not currently support this but will soon. In the meantime, an [extension](#extensions) such as [multipreffer][multipreffer-docs] may be used.

There are three types of Prefs:

1. Built-in prefs - shipped with Firefox, in `firefox.js`.
2. `user branch` - set by the user, overriding built-in prefs.
3. `default branch` - Overrides both built-in and `user branch` prefs. Only persists until the browser session ends, next restart will revert to either built-in or `user branch` (if set).

[Normandy][normandy-docs] supports overriding both the `user` and `default` branches, although the latter is preferred as it does not permanently override user settings. `default` branch prefs are simple to reset since they do not persist past a restart.

**In order for features to be activated experimentally using `default branch` prefs**:

- The feature must not start up before `final-ui-startup` is observed.

For instance, to set an observer:

```js
Services.obs.addObserver(this, "final-ui-startup", true);
```

In this example, `this` would implement an `observe(subject, topic, data)` function which will be called when `final-ui-startup` is observed. See the [Observer documentation][observer-docs] for more information.

- It must be possible to enable/disable the feature at runtime, via a pref change.

This is similar to the observer pattern above:

```js
Services.prefs.addObserver("pref_name", this);
```

More information is available in the [Preference service documentation][pref-service-docs].

- Never use `Services.prefs.prefHasUserValue()`, or any other function specific to `user branch` prefs.

- Prefs should be set by default in `firefox.js`

If your feature cannot abide by one or more of these rules (for instance, it needs to run at startup and/or cannot be toggled at runtime) then experimental preferences can be set on the `user branch`. This is more complex than using the methods described above; user branch prefs override the users choice, which is a really complex thing to try to support when flipping prefs experimentally. We also need to be careful to back up and reset the pref, and then figure out how to resolve conflicts if the user has changed the pref in the meantime.

## Feature Gates

A new Feature Gate library for Firefox Desktop is now available.

**Each feature gate should represent a different experimental treatment**. If your experimental feature requires multiple flags, then Normandy will not be able to support this directly and an [extension](#extensions) may be used.

### Feature Gate caveats

The current Feature Gate library comes with a few caveats, and may not be appropriate for your situation:

- Only JS is supported.
- Always asynchronous.

Future versions of the Feature Gate API will include C++/Rust support and a synchronous API.

### Using the Feature Gate library

Read [the documentation][feature-gate-docs] to get started.

## Extensions

Firefox currently supports the [Web Extensions API](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions).

**If new WebExtension APIs are needed, they should land in-tree**. Extensions which are signed by Mozilla can load privileged code using the [WebExtension Experiments](https://firefox-source-docs.mozilla.org/toolkit/components/extensions/webextensions/index.html), but this is not preferred.

WebExtensions go through the same correctness and performance tests as other features. This is possible using the Mozilla tryserver by dropping your XPI into `testing/profiles/common/extensions` in `mozilla-central` and pushing to Tryserver - see the [Testing Extensions](#testing-extensions) section below.

NOTE - it is ideal to test against the version of Firefox which the extension will release against, but there is a [bug related to artifact builds on release channels][artifact-bug] which must be worked around. The workaround is pretty simple (modify an `artifacts.py` file), but this bug being resolved will make it much simpler.

**Each extension can represent a different experimental treatment (preferred), or the extension can choose the branch internally**.

### SHIELD studies

The previous version of the experiments program, SHIELD, always bundled privileged code with extensions and would do things such as mock UI features in Firefox.

This sort of approach is discouraged for new features - land these (or the necessary WebExtension APIs) in-tree instead.

For the moment, the [SHIELD Study Add-on Utilities](https://github.com/mozilla/shield-studies-addon-utils/) may be used if the extension needs to control the lifecycle of the study, but using one extension per experimental treatment makes this unnecessary and is preferred. The APIs provided by the SHIELD Study Add-on Utilities will be available as privileged APIs shipped with Firefox soon.

# Development and Testing

## Testing Built-in Features

Firefox features go through standard development and testing processes. See the [Firefox developer guide][firefox-dev-docs] for more information.

## Testing Extensions

Extensions do not need to go through the same process, but should take advantage of Mozilla CI and bug tracking systems:

1. Use the Mozilla CI to test changes (tryserver).
2. Performance tests (**this step is required**) - extension XPI files should be placed in `testing/profiles/common/extensions/`, which will cause test harnesses to load the XPI.
3. Custom unit/functional tests (AKA `xpcshell`/`mochitest`) may be placed in `testing/extensions`, although running these tests outside Mozilla CI is acceptable so these are **optional**.
4. Receive reviewer approval. A Firefox peer **must sign off** if this extension contains privileged code, aka WebExtension Experiments.

- Any [Firefox Peer][firefox-peer-list] should be able to do the review, or point you to someone who can.

5. Extension is signed.
6. Email to `pi-request@mozilla.com` is sent to request QA
7. QA approval signed off in Bugzilla.
8. Extension is shipped via [Normandy][normandy-docs].

## Example Extensions Testing Workflow

Note that for the below to work you only need [Mercurial][mercurial] installed, but if you want to do local testing you must be set up to [build Firefox][firefox-build-docs]. You don't need to build Firefox from source; [artifact builds][firefox-artifact-build] are sufficient.

In order to use Mozilla CI (AKA "[Tryserver][try-server-docs]"), you must have a full clone of the `mozilla-central` repository:

```bash
hg clone https://hg.mozilla.org/mozilla-central
cd mozilla-central
```

Copy in unsigned XPI, and commit it to your local Mercurial repo:

```bash
cp ~/src/my-extension.xpi testing/profiles/common/extensions/
hg add testing/profiles/common/extensions/my-extension.xpi
hg commit -m "Bug nnn - Testing my extension" testing/profiles/common/extensions/my-extension.xpi
```

Push to Try:

```bash
./mach try -p linux64,macosx64,win64 -b do -u none -t all --artifact
```

This will run Mozilla CI tests on all platforms

Note that you must have Level 1 commit access to use tryserver. If you are interested in interacting with Mozilla CI from Github (which only requires users to be in the Mozilla GitHub org), check out the [Taskcluster Integration proof-of-concept][taskcluster-integration-poc].

Also note that this requires an investment time to set up just as CircleCI or Travis-CI would, so it's not really appropriate for short-term projects. Use tryserver directly instead.

[feature-gate-docs]: https://firefox-source-docs.mozilla.org/toolkit/components/featuregates/featuregates/index.html
[firefox-dev-docs]: https://developer.mozilla.org/en-US/docs/Mozilla/Developer_guide
[mercurial]: https://www.mercurial-scm.org/
[taskcluster-integration-poc]: https://github.com/biancadanforth/taskcluster-integration-poc/
[firefox-build-docs]: https://developer.mozilla.org/en-US/docs/Mozilla/Developer_guide/Build_Instructions
[firefox-artifact-build]: https://developer.mozilla.org/en-US/docs/Mozilla/Developer_guide/Build_Instructions/Artifact_builds
[try-server-docs]: https://firefox-source-docs.mozilla.org/tools/try/
[observer-docs]: https://developer.mozilla.org/en-US/docs/Mozilla/Tech/XPCOM/Reference/Interface/nsIObserverService#addObserver()
[normandy-docs]: https://github.com/mozilla/normandy
[pref-service-docs]: https://developer.mozilla.org/en-US/docs/Mozilla/Tech/XPCOM/Reference/Interface/nsIPrefService
[multipreffer-docs]: https://github.com/nhnt11/multipreffer
[firefox-peer-list]: https://wiki.mozilla.org/Modules/All#Firefox
[artifact-bug]: https://bugzilla.mozilla.org/show_bug.cgi?id=1435403
