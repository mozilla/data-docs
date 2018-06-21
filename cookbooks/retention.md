*Authored by the Product Data Science Team. Please direct questions/concerns to Ben Miroglio (`bmiroglio`).*

# Retention

Retention measures the rate at which users are *continuing* to use Firefox, making it one of the more important metrics we track. We commonly measure retention between releases, experiment cohorts, and various Firefox subpopulations to better understand how a change to the user experience or use of a specific feature affect behavior.

### N Week Retention

Time is an embedded component of retention. Most retention analysis starts with some anchor, or action that is associated with a date (experiment enrollment date, profile creation date, button clicked on date *d*, etc.). We then look 1, 2, …, N weeks beyond the anchor to see what percent of users have submitted a ping (signaling their continued use of Firefox).

For example, let’s say we are calculating retention for new Firefox users. Each user can then be anchored by their `profile_creation_date`, and we can count the number of users who submitted a ping between 7-13 days after profile creation (1 Week retention), 14-20 days after profile creation (2 Week Retention), etc.

#### Example Methodology



Given a dataset in Spark, we can construct a field `retention_period` that uses `submission_date_s3` to determine the period to which a ping belongs (i.e. if a user created their profile on April 1st, all pings submitted between April 8th and April 14th are assigned to week 1). 1-week retention can then be simplified to the percent of users with a 1 value for `retention_period`, 2-week retention simplifies to the percent of users with a 2 value for `retention_period`, ..., etc. Note that each retention period is independent of the others, so it is possible to have higher 2-week retention than 1-week retention (especially during holidays). 

First let's map 1, 2, ..., N week retention the the amount of days elapsed after the anchor point:

```python
PERIODS = {}
N_WEEKS = 6
for i in range(1, N_WEEKS + 1):
    PERIODS[i] = {
        'start': i * 7,
        'end': i * 7 + 6
    }  
```
Which gives us

```python
{1: {'end': 13, 'start': 7},
 2: {'end': 20, 'start': 14},
 3: {'end': 27, 'start': 21},
 4: {'end': 34, 'start': 28},
 5: {'end': 41, 'start': 35},
 6: {'end': 48, 'start': 42}}

```

Next, let's define some helper functions: 

```python
import datetime as dt
import pandas as pd
import pyspark.sql.types as st
import pyspark.sql.functions as F

udf = F.udf

def date_diff(d1, d2, fmt='%Y%m%d'):
    """
    Returns days elapsed from d2 to d1 as an integer
    
    Params:
    d1 (str)
    d2 (str)
    fmt (str): format of d1 and d2 (must be the same)
    
    >>> date_diff('20170205', '20170201')
    4
    
    >>> date_diff('20170201', '20170205)
    -4
    """
    try:
        return (pd.to_datetime(d1, format=fmt) - 
                pd.to_datetime(d2, format=fmt)).days
    except:
        return None
    

@udf(returnType=st.IntegerType())
def get_period(anchor, submission_date_s3):
    """
    Given an anchor and a submission_date_s3,
    returns what period a ping belongs to. This 
    is a spark UDF.
    
    Params:
    anchor (col): anchor date
    submission_date_s3 (col): a ping's submission_date to s3
    
    Global:
    PERIODS (dict): defined globally based on n-week method
    
    Returns an integer indicating the retention period
    """
    if anchor is not None:
        diff = date_diff(submission_date_s3, anchor)
        if diff >= 7: # exclude first 7 days
            for period in sorted(PERIODS):
                if diff <= PERIODS[period]['end']:
                    return period

@udf(returnType=st.StringType())
def from_unixtime_handler(ut):
    """
    Converts unix time (in days) to a string in %Y%m%d format.
    This is spark UDF.
    
    Params:
    ut (int): unix time in days
    
    Returns a date as a string if it is parsable by datetime, otherwise None
    """
    if ut is not None:
        try:
            return (dt.datetime.fromtimestamp(ut * 24 * 60 * 60).strftime("%Y%m%d"))
        except:
            return None
        
```

Now we can load in a subset of `main_summary` and construct the necessary fields for retention calculations:

```python
ms = spark.sql("""
    SELECT 
        client_id, 
        submission_date_s3,
        profile_creation_date,
        os
    FROM main_summary 
    WHERE 
        submission_date_s3 >= '20180401'
        AND submission_date_s3 <= '20180603'
        AND sample_id = '42'
        AND app_name = 'Firefox'
        AND normalized_channel = 'release'
        AND os in ('Darwin', 'Windows_NT', 'Linux')
    """)

PCD_CUTS = ('20180401', '20180415')

ms = (
    ms.withColumn("pcd", from_unixtime_handler("profile_creation_date")) # i.e. 17500 -> '20171130'
      .filter("pcd >= '{}'".format(PCD_CUTS[0]))
      .filter("pcd <= '{}'".format(PCD_CUTS[1]))
      .withColumn("period", get_period("pcd", "submission_date_s3"))
)
```

Note that we filter to profiles that were created in the first half of April so that we have sufficient time to observe 6 weeks of behavior. Now we can calculate retention!

```python
os_counts = (
    ms
    .groupby("os")
    .agg(F.countDistinct("client_id").alias("total_clients"))
)

weekly_counts = (
    ms
    .groupby("period", "os")
    .agg(F.countDistinct("client_id").alias("n_week_clients"))
)

retention_by_os = (
    weekly_counts
    .join(os_counts, on='os')
    .withColumn("retention", F.col("n_clients") / F.col("total_count"))
)
```

Peaking at 6-Week Retention

```python
retention_by_os.filter("period = 6").show()
```

```
+----------+------+--------------+-------------+-------------------+
|        os|period|n_week_clients|total_clients|          retention|
+----------+------+--------------+-------------+-------------------+
|     Linux|     6|          1495|        22422|0.06667558647756668|
|    Darwin|     6|          1288|         4734|0.27207435572454586|
|Windows_NT|     6|         29024|       124872|0.23243000832852842|
+----------+------+--------------+-------------+-------------------+


```

we observe that 35.6% of Linux users whose profile was created in the first half of April submitted a ping 6 weeks later, and so forth. The example code snippets are consolidated in [this notebook](https://gist.github.com/benmiroglio/fc708e5905fad33b43adb9c90e38ebf4).


# New vs. Existing User Retention

The above example calculates **New User Retention**, which is distinct from **Existing User Retention**. This distinction is important when understanding retention baselines (i.e. does this number make sense?). Existing users typically have much higher retention numbers than new users. 

Note that is more common in industry to refer to Existing User Retention as "Churn" (Churn = 1 - Retention), however, we use retention across the board for the sake of consistency and interpretability.

**Please be sure to specify whether or not your retention analysis is for new or existing users.**









# Confounding Factors

When performing retention analysis between two or more groups, it is important to look at other usage metrics to get an understanding of other influential factors.

For example, imagine you are tasked with reporting retention numbers for users that enabled sync (`sync_configured = true`) compared to users that haven't. You find that users with and without sync have a 1 week retention of 0.80 and 0.40, respectively. Wow--we should really be be promoting sync as it could double retention numbers!

*Not quite*. Turns out you next look at `active_ticks` and `total_uri_count` and find that sync users report much higher numbers for these measures as well. Now how can we explain this difference in retention?

There could be an entirely separate cookbook devoted to answering this question, however this contrived example is meant to demonstrate that simply comparing retention numbers between two groups isn't capturing the full story. Sans an experiment or model-based approach, all we can say is "enabling sync is **associated** with higher retention numbers." There is still value in this assertion, however it should be stressed that **association/correlation != causation!**


