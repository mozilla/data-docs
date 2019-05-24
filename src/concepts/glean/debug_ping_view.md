# Using the Glean debug ping view

<!-- toc -->

## What is this good for?

This enables you to easily see in real-time what data your mobile application is sending through [Glean](glean.md).

This data is what actually arrives in our data pipeline, shown in a web interface that is automatically updated when new data arrives.

## What setup is needed for applications?

You can use the debug view for all our mobile applications that use Glean (and enable it), including those installed from the app store. To enable this you need to run a command in adb that tags the outgoing data as "debug data". You will provide a debug tag, which makes it easier to identify your device in the web interface.

```
adb shell am start -n <application-id>/mozilla.components.service.glean.debug.GleanDebugActivity \
  --ez logPings true \
  --es sendPing baseline \
  --es tagPings my-debug-tag
```

_my-debug-tag_ is what will help you identify your data in the web interface, while `<application-id>`  is the application identifier as declared in the [manifest](https://developer.android.com/studio/build/application-id) (e.g. `org.mozilla.reference.browser`). The debug commands are documented in more detail [in the Glean README](https://github.com/mozilla-mobile/android-components/blob/master/components/service/glean/README.md#debugging-products-using-glean).

### Supported applications

As for now, the following application ids are supported:

*   `org.mozilla.fenix`
*   `org.mozilla.reference.browser`
*   `org.mozilla.samples.glean`

## Where can I see the data?

The data is provided in [this web interface](https://debug-ping-preview.firebaseapp.com/). It lists all recently active devices and updates automatically. You can use your debug identifier to quickly identify your own testing data.

Any data sent from a mobile device usually shows up within 10 seconds, updating the pages automatically.

## Can you give me an example?

For example to send a baseline ping immediately from the reference browser, with a debug identifier of `johndoe-test1`:

```
adb shell am start -n org.mozilla.reference.browser/mozilla.components.service.glean.debug.GleanDebugActivity \
  --es sendPing baseline \
  --es tagPings johndoe-test1
```

`baseline` pings are also sent automatically by Glean when the application goes to the background. So to check these you can set the tag:

```
adb shell am start -n org.mozilla.reference.browser/mozilla.components.service.glean.debug.GleanDebugActivity \
  --es tagPings johndoe-test1
```

Now whenever you put the application in the background, a `baseline` ping should show up in the web interface.

If you triggered some event recording and want to confirm them you can use the `events`

```
adb shell am start -n org.mozilla.reference.browser/mozilla.components.service.glean.debug.GleanDebugActivity \
  --es sendPing events \
  --es tagPings johndoe-test1
```

**Note**: Glean will always attempt to collect data for the ping that was requested using the `sendPing` command line switch. However, if no data is recorded by the application, nothing will be sent. The `baseline` ping is _guaranteed_ to always be sent, since it’s populated by Glean itself.


## Troubleshooting

If nothing is showing up on the dashboard, it would be useful to check the following:

*   If `adb logcat` reports _”Glean must be enabled before sending pings.”_ right after calling the `GleanDebugActivity`, then the application has disabled Glean. Please check with the application team on how to fix that.
*   If no error is reported when triggering tagged pings, but the data won't show up on the dashboard, check if the used `<application-id>` is the same expected by the Glean pipeline (i.e. the one used to publish the application on the Play Store).
*   Before April 12 builds, Fenix had a crashing bug around Glean. This is now fixed, please update.
*   The reference-browser debug builds currently don't enable Glean. You could override this in local builds.


## Questions? Problems?

Reach out to Alessio Placitelli (`:dexter`) or Arkadiusz Komarzewski (`:akomar`) in [#glean on slack](https://mozilla.slack.com/messages/CEE12R4E8/) or send an email to [`glean-team@mozilla.com`](mailto:glean-team@mozilla.com).

## References

*   [Glean debug commands in Glean README.](https://github.com/mozilla-mobile/android-components/blob/master/components/service/glean/README.md#debugging-products-using-glean)
*   [Glean Debug ping view web interface.](https://debug-ping-preview.firebaseapp.com/)
