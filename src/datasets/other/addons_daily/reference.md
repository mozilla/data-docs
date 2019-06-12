[![CircleCI](https://circleci.com/gh/mozilla/addons_daily.svg?style=svg)](https://circleci.com/gh/mozilla/addons_daily)

# `addons_daily` Derived Dataset
Contributers: Sarah Melancon, Ben Miroglio, Brian Wright, Daniel Thorn

This ETL code produces daily aggregates of Firefox extensions. It supports the broader "Extention Data for Developers" Project.

### Deriving a Dataset
Extension data is stored in multiple different places, the main sources being addons.mozilla.org (AMO), about:addons (disco-pane) and telemetry user data. We know a lot about extensions thanks to these sources, however, it is difficult to get a bird’s eye view. We know how many users have extension X, and their associated browser behavior from telemetry. We know extension X got, say, 1000 views last week on AMO from Google Analytics dashboards, and we know it was installed 100 times from telemetry. We need this data to all live in one place, broken out by each individual extension to help support (first and foremost) product decisions around extensions. 

This part of the project should allow someone to learn everything there is to know about extension X after looking in one place (at this point the “place” is a dataset). This repo accomplishes all of the above, the ideal next steps involve sharing these insights with a broader audience.

### Sharing Insights 
Developers get a narrow view of their extension in the wild through AMO’s dashboards (i.e. see Privacy Badger’s Dashboard). These dashboards are great for tracking user uptake and and language/OS breakdowns, however it completely omits user behavior. 

For instance, how long does it take extension X’s browser action (the button on the Firefox toolbar) to load compared to the average? How many tabs do users with extension X typically use compared to the average? Compared to extension Y? These are just some examples of things a developer would interested to know when prioritizing improvements to their software (and also very useful for Mozilla’s internal use!).

This part of the project should first allow Mozilla to better understand how individual extensions are behaving with minimal effort by way of a dashboard/report. Lastly, the hope is to share a subset of this data with developers/the public. An idea what this might look like is a lightweight version of the public data report sans any commentary (since there will be hundreds of add-ons), or a more zoomed out representation of TMO.

