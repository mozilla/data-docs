# Using the Event Counts Explore

If you want to answer product related questions using events, you can use the Event Counts explore in Looker.
This can help you understand how users interact with specific product features _in isolation_ (for example, the number of users that created a bookmark in Firefox for Android).
You can see a quick demo of how to use this explore to answer a simple Firefox for Android product question in this video:

<center>
<iframe width="560" height="315" src="https://www.youtube.com/embed/J0Hi5poV4D4" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</center>

This explore also exists for Mozilla VPN and other products (and you can use the same Glean Dictionary-based workflow to fill it out).
For Firefox Desktop, this explore is currently using legacy (non-Glean data) and you will need to use the [probe dictionary](../analysis/probe_dictionary.md) instead.
