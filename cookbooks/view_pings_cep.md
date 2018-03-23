# See My Pings

So you want to see what you're sending the telemetry pipeline, huh? Well follow these steps and we'll have you reading some JSON in no time.

For a more thorough introduction, see [Creating a Real-Time Analysis Plugin Cookbook](realtime_analysis_plugin.md).

## Steps to Create a Viewing Output

1. Get your `clientId` from whatever product you're using. For desktop, it's available in `about:telemetry`.

2. Go to the CEP site: https://pipeline-cep.prod.mozaws.net/

3. Login/Register using your Google `@mozilla.com` account

4. Click on the "Analysis Plugin Deployment" tab

5. Under "Heka Analysis Plugin Configuration", put the following config:

```
filename = '<your_name>_<product>_pings.lua'
message_matcher = 'Type == "telemetry" && Fields[docType] == "<doctype>" && Fields[clientId] == "<your_client_id>"'
preserve_data = false
ticker_interval = 60
```

Where `<product>` is whatever product you're testing, and `<doctype>` is whatever ping you're testing (e.g. `main`, `core`, `mobile-event`, etc.).

6. Under "Heka Analysis Plugin" put the following. This will, by default, show the most recent 10 pings that match your `clientId` on the specified `docType`.

NOTE: If you are looking at `main`, `saved-session`, or `crash` pings, the submitted data is split out into several pieces. Reading just `Fields[submission]`
will not give you the entire submitted ping contents. You can change that to e.g. `Fields[environment.system]`, `Fields[payload.histograms]`, `Fields[payload.keyedHistograms]`.
To see all of the available fields, [look at a ping in the Matcher tab](tools/cep_matcher.md).

```
require "string"
require "table"

output = {}
max_len = 10
cur_ind = 1

function process_message()
    output[cur_ind] = read_message("Fields[submission]")
    cur_ind = cur_ind + 1
    if cur_ind > max_len then
        cur_ind = 1
    end
    return 0
end

function timer_event(ns, shutdown)
    local res = table.concat(output, ",")
    add_to_payload("[" .. res .. "]")
    inject_payload("json")
end
```

7. Click "Run Matcher", then "Test Plugin". Check that no errors appear in "Debug Output"

8. Click "Deploy Plugin". Your output will be available at `https://pipeline-cep.prod.mozaws.net/dashboard_output/analysis.<username>_mozilla_com.<your_name>_<product>_pings..json`
