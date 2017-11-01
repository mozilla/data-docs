The churn tracks the 7-day churn rate of telemetry profiles. This dataset is generally used for analysing cohort churn across segments and time. 

#### Content
The columns are broken down into attributes and metrics. An attribute describes a property about a particular group of profiles, such as the country they originate from or the channel they are part of. The metrics are the measurements across these attributes, such as the the group size or the total usage length.

#### Background and Caveats

* Each row in this dataset describes a unique segment of users.
  - The size of the dataset grows exponentially with the number of descriptive dimensions, so attributes should be added only when necessary.
* The dataset lags by 10 days in order account for submission latency. This value was determined to be time for 99% of main pings to arrive to the server before the advent shutdown ping-sender.


#### Accessing the Data
`churn` is available in Redash under Athena and Presto.  The dataset is also available in it's raw form for consumption by Spark at `s3://telemetry-parquet/churn/v3`.
