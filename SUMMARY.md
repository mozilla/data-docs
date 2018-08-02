* [Firefox Data Documentation](introduction.md)
  * [Reporting a problem](concepts/reporting_a_problem.md)
  * [Terminology](concepts/terminology.md)
* [Getting Started](concepts/getting_started.md)
  * [Analysis Quick Start](concepts/analysis_intro.md)
  * [Choosing a Dataset](concepts/choosing_a_dataset.md)
  * [Intro to STMO](tools/stmo.md)
  * [Common Analysis Gotchas](concepts/analysis_gotchas.md)
  * [Optimizing Queries](concepts/sql_optimization.md)
  * [Getting Review](concepts/review.md)
  * [Collecting New Data](datasets/new_data.md)
* [Tools](tools/README.md)
  * [Project Glossary](tools/projects.md)
  * [Overview of Mozilla's Data Pipeline](/concepts/pipeline/data_pipeline.md)
    * [In-depth Data Pipeline Detail](/concepts/pipeline/data_pipeline_detail.md)
    * [HTTP Edge Server Specification](/concepts/pipeline/http_edge_spec.md)
    * [Event Pipeline Detail](/concepts/pipeline/event_pipeline.md)
  * [Analysis Interfaces](tools/interfaces.md)
  * [Custom analysis with Spark](tools/spark.md)
* [Cookbooks](cookbooks/README.md)
  * [Alerts](tools/alerts.md)
  * [Working with Parquet Data on ATMO Clusters](cookbooks/parquet.md)
  * [Creating a custom Re:dash dataset](cookbooks/create_a_dataset.md)
  * [Sending a Custom Ping](cookbooks/new_ping.md)
  * [Using HyperLogLog in Zeppelin](cookbooks/hll_zeppelin.md)
  * Dataset Specific
    * [Longitudinal Examples](cookbooks/longitudinal_examples.md)
    * [Working with Crash Pings](cookbooks/crash_pings.md)
  * Real-time
    * [Creating a Real-time Analysis Plugin](cookbooks/realtime_analysis_plugin.md)
    * [Seeing Your Own Pings](cookbooks/view_pings_cep.md)
    * [CEP Matcher](tools/cep_matcher.md)
  * Metrics
    * [Active DAU Definition](cookbooks/active_dau.md)

---

* [Dataset Reference](datasets/reference.md)
  * [Pings](datasets/pings.md)
  * [Derived Datasets](datasets/derived.md)
    * [Longitudinal](datasets/batch_view/longitudinal/reference.md)
    * [Cross Sectional](datasets/batch_view/cross_sectional/reference.md)
    * [Main Summary](datasets/batch_view/main_summary/reference.md)
    * [First Shutdown Summary](datasets/batch_view/first_shutdown_summary/reference.md)
    * [Crash Summary](datasets/batch_view/crash_summary/reference.md)
    * [Crash Aggregate](datasets/batch_view/crash_aggregates/reference.md)
    * [Events](datasets/batch_view/events/reference.md)
    * [Sync Summary](datasets/batch_view/sync_summary/reference.md)
    * [Addons](datasets/batch_view/addons/reference.md)
    * [Client Count](datasets/batch_view/client_count/reference.md)
    * [Client Count Daily](datasets/batch_view/client_count_daily/reference.md)
    * [Churn](datasets/mozetl/churn/reference.md)
    * [Retention](datasets/batch_view/retention/reference.md)
    * [Clients Daily](datasets/mozetl/clients_daily/reference.md)
    * [New Profile](datasets/batch_view/new_profile/reference.md)
    * [Update](datasets/batch_view/update/reference.md)
    * [Heavy Users](datasets/batch_view/heavy_users/reference.md)
    * [SSL Ratios (public)](datasets/other/ssl/reference.md)
    * [Error Aggregates](datasets/streaming/error_aggregates/reference.md)
  * [Experimental Datasets](tools/experiments.md)
    * [Accessing Shield Study data](datasets/shield.md)
  * [Search Datasets](datasets/search.md)
    * [Search Aggregates](datasets/mozetl/search_aggregates/reference.md)
    * [Search Clients Daily](datasets/mozetl/search_clients_daily/reference.md)


---

* High-level Behavior
    * Profile Behavior
        * [Real World Usage](high_level/profile/realworldusage.md)
        * [Profile History](high_level/profile/profilehistory.md)        

---

* About this Documentation
  * [Contributing](meta/contributing.md)
  * [Bug Template](https://bugzilla.mozilla.org/enter_bug.cgi?assigned_to=nobody%40mozilla.org&bug_file_loc=http%3A%2F%2F&bug_ignored=0&bug_severity=normal&bug_status=NEW&cf_fx_iteration=---&cf_fx_points=---&component=Documentation%20and%20Knowledge%20Repo%20%28RTMO%29&contenttypemethod=autodetect&contenttypeselection=text%2Fplain&defined_groups=1&flag_type-4=X&flag_type-607=X&flag_type-800=X&flag_type-803=X&flag_type-916=X&form_name=enter_bug&maketemplate=Remember%20values%20as%20bookmarkable%20template&op_sys=Linux&priority=--&product=Data%20Platform%20and%20Tools&rep_platform=x86_64&target_milestone=---&version=unspecified)
  * [Structure](meta/structure.md)
