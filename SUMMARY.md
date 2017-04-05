* [Firefox Data Documentation](introduction.md)
  * [Terminology](concepts/terminology.md)
* [Getting Started](concepts/getting_started.md)
  * [Analysis Quick Start](concepts/analysis_intro.adoc)
  * [Data Privacy](concepts/data_privacy.md)
  * [Choosing a Dataset](concepts/choosing_a_dataset.md)
  * [Common Analysis Gotchas](concepts/analysis_gotchas.md)
* [Data Collection and Datasets](datasets/README.adoc)
  * Understanding our Data
    * Experimental vs Descriptive Data
    * [Choosing a dataset](concepts/choosing_a_dataset.md)
    * [Tools for Experimentation](concepts/experiment_intro.adoc)
    * [Common Analysis Gotchas](concepts/analysis_gotchas.md)
      * Sessions and Subsessions
      * Dates, Timespans, & their caveats
      * Profiles vs. Users
  * [Dataset Reference](datasets/reference.md)
    * Pings
      * Opt-in vs Opt-out
      * [Main Ping](concepts/main_ping_intro.md)
    * Derived Datasets
      * [Longitudinal](datasets/longitudinal/Longitudinal.md)
      * Cross Sectional
      * [Main Summary](datasets/main_summary/MainSummary.md)
      * [Crash Summary](datasets/crash_summary/CrashSummary.md)
      * [Crash Aggregate](datasets/crash_aggregate/CrashAggregateView.md)
      * [Events](datasets/events/Events.md)
      * [Sync Summary](datasets/sync_summary/SyncSummary.md)
      * [Addons](datasets/addons/Addons.md)
      * ETC
    * [Experimental Datasets](concepts/experiment_intro.adoc)
      * Accessing Shield Study data
  * [Collecting New Data](datasets/new_data.md)
* [Tools](tools/README.adoc)
  * Interfaces
    * TMO & STMO
    * Distribution Viewer
    * [Advanced analysis with ATMO](concepts/advanced_analysis_with_atmo.adoc)
    * An Introduction to Spark
    * Realtime Analysis with CEP
    * [HBase](tools/hbase.md)
    * RTMO
  * Infrastructure
    * The Path to Re:dash
      * Heka Messages
      * telemetry-batch-view
      * parquet2hive
      * Airflow
      * Presto
* [Cookbooks](cookbooks/README.adoc)
  * [Working with Parquet Data on ATMO Clusters](cookbooks/parquet.md)
  * [Creating a custom re:dash dataset](cookbooks/create_a_dataset.adoc)
  * [Creating a Real-time Analysis Plugin](cookbooks/realtime_analysis_plugin.md)
  * [Longitudinal Examples](cookbooks/longitudinal.md)


* [About this Documentation](meta/README.md)
  * [Structure](meta/structure.md)
  * [Contributing](meta/contributing.md)
