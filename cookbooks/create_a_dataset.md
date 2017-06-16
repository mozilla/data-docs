# Creating Your Own Dataset to Query in re:dash

1. Create a spark notebook that does the transformations you need, either on
   raw data (using Dataset API) or on parquet data
2. Output the results of that to an s3 location, usually
   `telemetry-parquet/user/$YOUR_DATASET/v$VERSION_NUMBER/submission_date=$YESTERDAY/`.
   This would partition by submission_date, meaning each day this runs and is
   outputted to a new location in s3. Do NOT put the submission_date in the
   parquet file as well! A column name cannot also be the name of a partition.
3. Using [this template](https://bugzilla.mozilla.org/enter_bug.cgi?assigned_to=bimsland%40mozilla.com&bug_file_loc=http%3A%2F%2F&bug_ignored=0&bug_severity=normal&bug_status=NEW&cf_fx_iteration=---&cf_fx_points=1&comment=Location%20of%20the%20dataset%3A%20%0D%0ADesired%20dataset%20name%3A&component=Datasets%3A%20General&contenttypemethod=autodetect&contenttypeselection=text%2Fplain&defined_groups=1&flag_type-4=X&flag_type-607=X&flag_type-800=X&flag_type-803=X&flag_type-916=X&form_name=enter_bug&maketemplate=Remember%20values%20as%20bookmarkable%20template&op_sys=Linux&priority=P1&product=Data%20Platform%20and%20Tools&rep_platform=x86_64&short_desc=Add%20dataset%20to%20Presto&target_milestone=---&version=unspecified),
   open a bug to load the dataset in Presto with the following attributes:
   * Assigned to :robotblake
   * Title: "Add Dataset to Presto"
   * Content: Location of the dataset and the desired table name
