# Optimizing Looker Performance - Caching

This how-to guide is about improving performance of Looker dashboards and explores using caching. This is particularly
useful if you have many users accessing a dashboard or explore, especially across timezones. 

This guide has two alternatives: Applying Generated Datagroups and Custom Datagroups 

> ⚠️ Some steps in this guide require knowledge of LookML - ask in #data-help for assistance if needed.

The default setting in Looker is to store (cache) the results of any query for one hour. The majority of our data 
is updated at least daily. This means that while users will get the same result for a query, they might have to wait 
for the query to retrieve results from our BigQuery warehouse. 

We solve this by using Looker's [datagroups](https://cloud.google.com/looker/docs/caching-and-datagroups). In short, 
datagroups are a method for scheduling various actions in Looker like resetting the cache, e-mailing dashboards, or 
rebuilding derived tables. 

## Alternative One - Applying Generated Datagroups

For a number of tables in our warehouse, we automatically generate datagroups in looker-hub. 

First locate your `explore.lkml` file. Take note of the source table that powers this explore. Note that this might be
multiple tables. If your explore has _multiple_ tables that are updated by 
[ETL](https://workflow.telemetry.mozilla.org/home) you should move on to Alternative Two. Explores joining 
infrequently updated, shared views such as `countries.view.lkml` can still use this method. 

After finding the source table, in your `explore.lkml` file, include the auto-generated datagroup and add a 
`persist_with` parameter that matches the datagroup. By convention, the datagroup name matches source tables. 
See the following example:

```
...
include: "//looker-hub/search/datagroups/mobile_search_clients_daily_v1_last_updated.datagroup.lkml"

explore: mobile_search_counts {

  ...

  persist_with: mobile_search_clients_daily_v1_last_updated
  
}

```

Now, query results for the `Mobile Search Counts` explore will be cached until the `mobile_search_clients_daily_v1` 
table is updated and users running the same query will receive fast results (a few seconds usually).

If you aren't able to find an auto-generated datagroup or your explore has multiple, complex joins, move on to 
Alternative Two.


## Alternative Two - Custom Datagroups

This, simple alternative makes use of a static timer, longer than the default one hour used by Looker.

First, locate your `explore.lkml` file. Define a datagroup with an `interval_trigger` and `max_cache_age` > 1 hour. For
example:

```
explore: my_explore {

  datagroup: my_explore_datagroup {
    interval_trigger: "6 hours"
    max_cache_age: "6 hours"
  }

  persist_with: my_explore_datagroup
  
}
```

This will cache results for 6 hours at a time.

As always, if any steps in this guide are unclear, or you are unable to locate the source tables, feel free to ask for 
assistance in #data-help.