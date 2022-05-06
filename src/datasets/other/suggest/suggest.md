# Firefox Suggest

## Introduction

Firefox Suggest is a monetizable feature in the Firefox urlbar. Suggest providesreal-time recommendations as users type in the urlbar. The recommendations include URLs from the user's browsing history, open tabs and bookmarks, as well as URLs for sponsored and non-sponsored content from third-party partners like AdMarketplace and Wikipedia.

Firefox Suggestions compete directly with Search Engine Suggestions for user attention and clicks in the urlbar. A holistic analysis of the urlbar should include data from all the sources providing recommendations to the urlbar, including Firefox Suggestions, Search Engine Suggestions, auto-fill, etc.

This section will include information about Firefox Suggest data. See [Search Datasets](https://docs.telemetry.mozilla.org/datasets/search.html) for documentation on Search Engine Data.

## Data Collection

Firefox Suggestions may be served to the urlbar from Firefox itself, or by a Mozilla-owned service called Merino. When users opt in to sharing their search query data, Firefox sends the search queries to Merino, and Merino responds with recommendations.

In addition to the search queries, we collect Category 1 and 2 telemetry data from Firefox about how users are interacting with Suggest.

### Interactions data (Cat 1 and 2)

Interactions data related to Firefox Suggest is collected in the following ways.

1. Interactions with Firefox Suggestions in the urlbar (i.e., clicks, impressions, blocks, clicks on help links) are collected using the standard (legacy) Telemetry system as Scalars and Events.
  Full documentation of the probes is [here](https://firefox-source-docs.mozilla.org/browser/urlbar/firefox-suggest-telemetry.html). The Scalars are available in [Clients Daily](https://docs.telemetry.mozilla.org/datasets/batch_view/clients_daily/reference.html).

2. Interactions with Firefox Suggestions in the urlbar (i.e., clicks, impressions, blocks) are collected using Custom Contextual Services Pings.
  The Custom Contextual Services Pings contain additional information not available in the standard Scalars and Events, such as the advertiser provided the recommendation, if any. This data has a much shorter retention period than the data collecting in (1) above. It also does not contain the Firefox Desktop Client ID, and is not joinable by design to any datasets outside of Contextual Services. Full documentation of the probes is [here](https://firefox-source-docs.mozilla.org/browser/urlbar/firefox-suggest-telemetry.html#contextual-services-pings).

3. [Preference Settings](about:preferences) are collected using the standard (legacy) Telemetry system in the Environment.
  Full documentation of the probes is [here](https://firefox-source-docs.mozilla.org/browser/urlbar/firefox-suggest-telemetry.html#environment). The Preferences are available in [Clients Daily](https://docs.telemetry.mozilla.org/datasets/batch_view/clients_daily/reference.html). Choices users made on opt-in modals (which propagage to [Preferences](about:preferences)) are also recorded in the Environment.

4. Exposure Events for experiments are recorded using the standard Nimbus system.
  Full documentation of the probes is [here](https://firefox-source-docs.mozilla.org/browser/urlbar/firefox-suggest-telemetry.html#nimbus-exposure-event). 

### Search queries and Merino

1. Search queries sent to Merino by Firefox are logged by Merino.
  Full documentation of the probes is [here](https://firefox-source-docs.mozilla.org/browser/urlbar/firefox-suggest-telemetry.html#merino-search-queries). For more information about the much shorter retention periods, security and access controls on this data, see the [Search Terms Data Access Policy](https://docs.google.com/document/d/11rOM3r5AOPUrqDnCAODY7gknxnqtjphgINSK5oAR9T4/edit#) (Mozilla internal only).

2. Merino responses as seen from Firefox.
  We collect data about Merino's response times and response types in Firefox using the standard (legacy) Telemetry system as Histograms. Full documentation of the probes is [here](https://firefox-source-docs.mozilla.org/browser/urlbar/firefox-suggest-telemetry.html#histograms).

3. Service and operational data on Merino
  We also collect data about Merino as a service from Merino directly. Full documentation of the data is here. 
