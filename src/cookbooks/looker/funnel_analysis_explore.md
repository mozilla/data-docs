# Using the Funnel Analysis Explore

If you want to answer product related questions using events, you can use the Funnel Analysis explore in Looker.
This can help you understand how users interact with specific product features _in sequence_ (for example, what percentage of users completed a specific set of interactions).
You can see a quick demo of how to use this explore to answer a simple Firefox for Android product question in this video:

<center>
<iframe width="560" height="315" src="https://www.youtube.com/embed/Nltt4wYmoUM" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</center>

This explore also exists for Mozilla VPN and other products (and you can use the same Glean Dictionary-based workflow to fill it out).
For Firefox Desktop, this explore is currently using legacy (non-Glean data) and you will need to use the [probe dictionary](../analysis/probe_dictionary.md) to look up event metadata instead.

Under the hood, the funnel analysis explore uses the [`events_daily`](../../datasets/bigquery/events_daily/reference.md) dataset.
