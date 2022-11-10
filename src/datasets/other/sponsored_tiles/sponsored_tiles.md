# Sponsored Tiles

## Introduction

Firefox Sponsored Tiles is an advertising-based feature available on the new tab of both desktop and mobile Firefox browsers. This feature populates the new tab's Top Sites section with up to two Sponsored Tiles. These Sponsored Tiles display a company logo and link to the company website. Mozilla's `Contile` serves the advertisements and may refresh the advertisers every 15 minutes. Each click on a Sponsored Tile generates revenue for Mozilla.

## Data Usage Considerations

Mozillians may access Sponsored Tiles data when advertiser information is **not** attached. This includes metrics such as Sponsored Tile impressions, clicks, dismissals, and disablement. Sponsored Tiles is an important component of new tab user behavior and a growing source of revenue. Therefore, it is encouraged to monitor Sponsored Tile engagement metrics in do no harm experiments testing changes to the new tab.

Access to Sponsored Tiles data by advertiser is restricted to members of the contextual services working group. These restrictions are designed to protect user privacy, preventing excessive access to data which links a given client to their interactions with different advertisers. For more information on requesting access, see [comment here](https://mana.mozilla.org/wiki/display/DATA/Data+Access+Policies).

## Big Query Tables and Looker Explores

### All-Mozilla access

| Access-restriction(s)        | Big Query Table                                                 | Looker Explore                          | Description                                                                                                                                                         |
| ---------------------------- | --------------------------------------------------------------- | --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| All Mozillians               | `telemetry.sponsored_tiles_clients_daily`                       | Firefox Desktop > Sponsored Tiles Clients Daily | Workhorse dataset for Sponsored Tiles, includes desktop and mobile data. All new Sponsored Tiles metrics are added to this table. Does not include advertiser data. |
| All Mozillians               | `telemetry.newtab`                                              | Firefox Desktop > `Newtab`              | Expanded `newtab` **desktop** dataset. Requires unnesting events.      
| All Mozillians               | `telemetry.newtab_interactions`                                 | Firefox Desktop > New Tab Interactions  | In-development dataset for basic analyses. Available metrics are limited to **desktop** clicks and impressions.                                                     |
| Contextual Services          | `contextual_services.event_aggregates`                          | Contextual Services > Event Aggregates  | Dataset with Sponsored Tiles and Suggest analyses by advertiser. Preferred practice is to use the derived `event_aggregates.[product]` datasets. |
| Contextual Services          | `contextual_services.event_aggregates_spons_tiles` | Contextual Services > Event Aggregates Spons Tiles  | Workhorse dataset for Sponsored Tiles analyses by advertiser.                                                                                           |
| Contextual Services          | `contextual_services_derived.adm_forecasting`                   | Contextual Services > `AdM` Forecasting | Dataset with required components for Sponsored Tiles and Suggest revenue forecasts.                                                                                 |
| Contextual Services, Revenue | `contextual_services.event_aggregates` x `revenue.revenue_data` | Revenue > `AdM` Revenue with Telemetry  | Revenue information combined with usage metrics. This dataset is useful for `CPC` analyses.                                                                         |
