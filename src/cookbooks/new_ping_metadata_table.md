| field                                  | description                                                                           |
| -------------------------------------- | ------------------------------------------------------------------------------------- |
| `additional_properties`                | A JSON string containing any payload properties not present in the schema             |
| `document_id`                          | The document ID specified in the URI when the client sent this message                |
| `normalized_app_name`                  | Set to "Other" if this message contained an unrecognized app name                     |
| `normalized_channel`                   | Set to "Other" if this message contained an unrecognized channel name                 |
| `normalized_country_code`              | An ISO 3166-1 alpha-2 country code                                                    |
| `normalized_os`                        | Set to "Other" if this message contained an unrecognized OS name                      |
| `normalized_os_version`                | N/A                                                                                   |
| `sample_id`                            | Hashed version of client_id (if present) useful for partitioning; ranges from 0 to 99 |
| `submission_timestamp`                 | Time when the ingestion edge server accepted this message                             |
| `metadata.user_agent.browser`          | N/A                                                                                   |
| `metadata.user_agent.os`               | N/A                                                                                   |
| `metadata.user_agent.version`          | N/A                                                                                   |
| `metadata.uri.app_build_id`            | N/A                                                                                   |
| `metadata.uri.app_name`                | N/A                                                                                   |
| `metadata.uri.app_update_channel`      | N/A                                                                                   |
| `metadata.uri.app_version`             | N/A                                                                                   |
| `metadata.header.date`                 | Date HTTP header                                                                      |
| `metadata.header.dnt`                  | DNT (Do Not Track) HTTP header                                                        |
| `metadata.header.x_debug_id`           | X-Debug-Id HTTP header                                                                |
| `metadata.header.x_pingsender_version` | X-PingSender-Version HTTP header                                                      |
| `metadata.geo.city`                    | City name                                                                             |
| `metadata.geo.country`                 | An ISO 3166-1 alpha-2 country code                                                    |
| `metadata.geo.db_version`              | The specific [Geo database] version used for this lookup                              |
| `metadata.geo.subdivision1`            | First major country subdivision, typically a state, province, or county               |
| `metadata.geo.subdivision2`            | Second major country subdivision; not applicable for most countries                   |
| `metadata.isp.db_version`              | The specific [ISP database] version used for this lookup                              |
| `metadata.isp.name`                    | The name of the Internet Service Provider                                             |
| `metadata.isp.organization`            | The name of a specific business entity when available; otherwise the ISP name         |

[geo database]: https://dev.maxmind.com/geoip/geoip2/geoip2-city-country-csv-databases/
[isp database]: https://dev.maxmind.com/geoip/geoip2/geoip2-isp-csv-database/
