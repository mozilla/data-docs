* [Firefox Data Documentation](introduction.md)
  * [Terminology](concepts/terminology.md)
* [Getting Started](concepts/getting_started.md)
  * [Analysis Quick Start](concepts/analysis_intro.adoc)
  * [Data Privacy](/concepts/data_privacy.md)
  * [Choosing a Dataset](concepts/choosing_a_dataset.md)
* [Data Collection and Datasets](datasets/README.adoc)
  * Understanding our Data
    * How we collect data (pings, studies, experiments)
    * Choosing a dataset
    * Experimental vs Descriptive Data
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
  * [Creating a custom re:dash dataset](cookbooks/create_a_dataset.adoc)


* [About this Documentation](meta/README.md)
  * [Structure](meta/structure.md)
  * [Contributing](meta/contributing.md)
