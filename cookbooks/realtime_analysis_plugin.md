# Creating a Real-time Analysis Plugin

## Getting Started

Creating an analysis plugin consists of three steps:

1. Writing a message matcher

   The message matcher allows one to select specific data from the data stream.

2. Writing the analysis code/business logic

   The analysis code allows one to aggregate, detect anomalies, apply machine
   learning algorithms etc.

3. Writing the output code

   The output code allows one to structure the analysis results in an easy to
   consume format.


### Step by Step Setup

1. Go to the CEP site: https://pipeline-cep.prod.mozaws.net/

1. Login/Register using your Google `@mozilla.com` account

1. Click on the `Plugin Deployment` tab

1. Create a message matcher

    1. Edit the `message_matcher` variable in the `Heka Analysis Plugin Configuration`
       text area. For this example we are selecting all telemetry messages. The
       full syntax of the message matcher can be found here:
       http://mozilla-services.github.io/lua_sandbox/util/message_matcher.html

       ```lua
       message_matcher = "Type == 'telemetry'"
       ```

1. Test the message matcher

    1. Click the `Run Matcher` button.

       Your results or error message will appear to the right.  You can browse
       the returned messages to examine their structure and the data they
       contain; this is very helpful when developing the analysis code but is
       also useful for data exploration even when not developing a plugin.

1. Delete the code in the `Heka Analysis Plugin` text area

1. Create the Analysis Code (`process_message`)

   The `process_message` function is invoked every time a message is matched and
   should return 0 for success and -1 for failure. Full interface documentation:
   http://mozilla-services.github.io/lua_sandbox/heka/analysis.html

    1. Here is the minimum  implementation; type it into the
       `Heka Analysis Plugin` text area:

       ```lua
       function process_message()
           return 0 -- success
       end
       ```

1. Create the Output Code (`timer_event`)

   The `timer_event` function is invoked every `ticker_interval` seconds.

    1. Here is the minimum implementation; type it into the `Heka Analysis Plugin`
       text area:

       ```lua
       function timer_event()
       end
       ```

1. Test the Plugin
    1. Click the `Test Plugin` button.

       Your results or error message will appear to the right. If an error is
       output, correct it and test again.


1. Extend the Code to Perform a Simple Message Count Analysis/Output

   1. Replace the code in the `Heka Analysis Plugin` text area with the
      following:

      ```lua
      local cnt = 0
      function process_message()
          cnt = cnt + 1                       -- count the number of messages that matched
          return 0
      end

      function timer_event()
          inject_payload("txt", "types", cnt) -- output the count
      end
      ```

1. Test the Plugin
    1. Click the `Test Plugin` button.

       Your results or error message will appear to the right. If an error is
       output, correct it and test again.

1. Extend the Code to Perform a More Complex Count by Type Analysis/Output

   1. Replace the code in the `Heka Analysis Plugin` text area with the
      following:

      ```lua
      types = {}
      function process_message()
          -- read the docType from the message, if it doesn't exist set it to "unknown"
          local dt = read_message("Fields[docType]") or "unknown"

          -- look up the docType in the types hash
          local cnt = types[dt]
          if cnt then
              types[dt] = cnt + 1   -- if the type cnt exists, increment it by one
          else
              types[dt] = 1         -- if the type cnt didn't exist, initialize it to one
          end
          return 0
      end

      function timer_event()
          add_to_payload("docType = Count\n")   -- add a header to the output
          for k, v in pairs(types) do           -- iterate over all the key/values (docTypes/cnt in the hash)
              add_to_payload(k, " = ", v, "\n") -- add a line to the output
          end
          inject_payload("txt", "types")        -- finalize all the data written to the payload
      end
      ```

1. Test the Plugin
    1. Click the `Test Plugin` button.

       Your results or error message will appear to the right. If an error is
       output, correct it and test again.

1. Deploy the plugin
    1. Click the `Deploy Plugin` button and dismiss the successfully deployed
       dialog.

1. View the running plugin
    1. Click the `Plugins` tab and look for the plugin that was just deployed
       `{user}.example`
    1. Right click on the plugin to active the context menu allowing you to view
       the source or stop the plugin.

1. View the plugin output
    1. Click on the `Dashboards` tab
    1. Click on the `Raw Dashboard Output` link
    1. Click on `analysis.{user}.example.types.txt` link

### Where to go from here
- Lua Reference: http://www.lua.org/manual/5.1/manual.html
- Available Lua Modules: https://mozilla-services.github.io/lua_sandbox_extensions/
- Support
    - IRC: [#hindsight on `irc.mozilla.org`](irc://irc.mozilla.org/hindsight)
    - Mailing list: https://mail.mozilla.org/listinfo/hindsight
