`client_ltv` is designed to enable relative user value estimates based on their past and expected search and ad click behavior. This behavior is revenue-generating for Firefox.

## Contents

`client_ltv` has one row for each (`client_id`, `engine`, `submission_date`) triplet.

Each row captures a year's worth of history for the `client_id` on the given `engine`, therefore the values will not change much when looking at `submission_date` in 1-day (or even 1-month) sequences, since there is significant overlap. For **most** analyses, using yesterday's `submission_date` will be sufficient.

Using yesterday's date, a client's row will contain the total number of searches, ad clicks, etc for the last 365 days, along with active search and ad clicks days (how many days did a user search or click an ad). Additionally each row contains the predicted number active search/ad click days for the *next* 365 days. See the schema at the bottom of this page for a full list of the fields.

## LTV

A client's "lifetime" is maxed out at 2 years given the structure of this dataset. Of course a client can exist for longer, but one year on either side of the date in question controls for seasonal trends and lets us easily produce annual estimates for, say, user acquisition ROI.

The procedure for calculating a user's LTV is as follows:

* Step 1: Determine the ad click value for the user's region/engine
    - (*Revenue in Country C for Engine E*) / (*Total Ad Clicks in Country C for Engine E*) 
* Step 2: Determine the user's ad clicks per day for the past 365 days
    - (*Total Ad Clicks for User*) / (*Total Active Ad Click Days for User*)
* Step 3: Calculate a user's past LTV by multiplying the following:
    - *Total Active Ad Click Days for User*
    - *Ad Clicks per Day for User* (derived in step 2)
    - *Ad Click Value in Country C for Engine E* (derived from step 1)
* Step 4: Calculate a user's future LTV by multiplying the following:
    - *Total **Predicted** Active Ad Click Days for User*
    - *Ad Clicks per Day for User* (derived in step 2)
    - *Ad Click Value in Country C for Engine E* (derived from step 1)
* Step 5: Normalized the LTV values from (3) and (4)
    - (*User past LTV*) / (*Sum of all past user LTVs*)
    - (*User future LTV*) / (*Sum of all future user LTVs*)


The normalized LTV for a user can roughly be interpreted as a user's **contribution** to the collective value of our user-base. Note that the above procedure omits some outlier handling steps for simplicity.



## Background and Caveats

The `normalized_ltv_ad_clicks_current` field, for example, does **not** represent a user's contribution to revenue directly. It should be treated as a rough proxy. It is not appropriate to multiply revenue by this number.

LTV is broken down by engine, so the LTV for a user who searches on multiple engines must be interpreted in context. **LTV is only available for Google and Bing on Firefox Desktop** at this time.

We **do** have the ability to calculate a dollar value per user, however the (unnormalized) table is restricted to those with proper revenue access. For more information, please reach out to :bmiroglio (bmiroglio@mozilla.com).


