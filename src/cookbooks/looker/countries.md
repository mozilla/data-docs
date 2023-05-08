# Normalizing Country Data

This how-to guide is about getting standard country data in your Looker Explores, Looks and Dashboards:

![Country View in Explore Image]

This guide has only two steps: Normalizing Aliases and Accessing Standard Country Data.

> ⚠️ Some steps in this guide require knowledge of SQL and LookML - ask in #data-help for assistance if needed.

We get country data from many sources: partners, telemetry, third-party tools etc. 
In order to analyze these in a standard way, i.e. make different analyses comparable, 
we can conform these sources to a set of standard country codes, names, regions, 
sub-regions, etc.

## Step One - Normalizing Aliases

> ⚠️ If your country data already consists of two-character ISO3166 codes, you can skip to Step Two! 

We refer to a different input name for the same country as "alias". For example, your data might contain
the country value "US", another might contain "USA" and yet another might contain "United States", etc. 
This can be confusing when read in a table or seen on a graph. 

To normalize this, we maintain a mapping of [aliases](https://github.com/mozilla/bigquery-etl/blob/main/sql_generators/country_code_lookup/aliases.yaml) 
from each country to its two-character [ISO3166 code](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes) 
This includes misspellings and alternate language encoding that we encounter in various datasets. 
For example:  

```yaml
CI:
    - "Ivory Coast"
    - "Côte d’Ivoire"
    - "Côte d'Ivoire"
    - "Cote d'Ivoire"
    - "CÃ´te dâ€™Ivoire"
    - "The Republic of Côte d'Ivoire"
```

To map (normalize) your input alias to its country code, add a LEFT join from your table or view to the alias lookup 
table: `mozdata.static.country_codes_v1`. For example:

```sql
SELECT
    ...
    your_table.country_field,
    COALESCE(lookup.code, your_table.country, '??') as country_code
    ...
FROM
    your_table 
    LEFT JOIN mozdata.static.country_codes_v1 lookup ON your_table.country_field = lookup.name 
```

Note: we use `??` as a country-code for empty country data from data sources. This will map to "Unknown Country", 
"Unknown Region", etc.

At this point, you should check for cases where the resulting `country_code` matches `your_table.country` but does 
not match any values in the lookup table - you may have discovered a new alias, in which case please add it to the list!
You can do this via a bigquery-etl pull request for example: https://github.com/mozilla/bigquery-etl/pull/2858.

> ⚠️ This list of aliases is public. If you are working with sensitive data, please do not add to the public list of 
> aliases, you should handle it in custom logic in code that interfaces with your sensitive data for example in 
> [private-bigquery-etl](https://github.com/mozilla/private-bigquery-etl) or the 
> [private Looker spoke](https://github.com/mozilla/looker-spoke-private). 

If you are satisfied that the `country_code` field is appropriately normalized, move on to Step Two! 


## Step Two - Accessing Standard Country Data

Standard country data is contained in the `mozdata.static.country_codes_v1` table and by extension the 
`shared/views/countries` Looker View.

Add the following join to your Explore (either in the `.explore.lkml` or `.model.lkml` file):

```lookml
include: "/shared/views/*"

...

join: countries {
    type: left_outer
    relationship: one_to_one
    sql_on: ${your_table.country_code} = ${countries.code} ;;
}
```

Now, you should be able to see the Countries View in your Explore 🎉

![Country View in Explore Image]

[Country View in Explore Image]: ../../assets/Looker_screenshots/countries_explore.png 
