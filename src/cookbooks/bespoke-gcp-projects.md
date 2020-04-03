# Bespoke GCP Projects for development

If you are working on a more complex project (as opposed to ad-hoc or one-off analysis), it may be worthwhile provisioning a separate GCP project for it with access to our datasets. From the [Google Cloud Console](https://console.cloud.google.com/), you may then:

- Provision service accounts for querying BigQuery (including our production tables) or accessing other GCP resources from the command-line or inside Docker containers.
- Write and query data to private BigQuery tables, without worrying about interfering with what we have in production.
- Make Docker images available via the Google Container Registry (see [the cookbook on deploying containers](deploying-containers.md))
- Creating [Google Cloud Storage](https://cloud.google.com/storage/) buckets for storing temporary data
- Creating [Google Compute Instances](https://cloud.google.com/compute/docs/instances) for test-running software in the cloud.
- Create a temporary Kubernetes cluster for test-running a scheduled job with [telemetry-airflow](https://github.com/mozilla/telemetry-airflow)
- Track the costs for all of the above using the Google Cost Dashboard feature of the GCP console.

This has a number of advantages over our traditional approach of creating bulk "sandbox" projects for larger teams:

- Easy to track costs of individual components
- People can self-serve short-lived administrative credentials which can
  exist only for the lifespan of the project.
- Can easily spin down projects and resources which have run their course

Note that these bespoke GCP projects are not intended to be used for projects which are already in _production_-- those should be maintained on operations-supported projects, presumably after a prototype/development phase.

Each sandbox project has a data engineering contact associated with it, this is meant to be a resource you can freely ask for advice on how to query or use GCP, especially pertaining to projects which you expect to be supported in production at some future date.

If you are sure, [file a ticket] in bugzilla using the provided template.
Not sure if you need a project like this? Don't know who to specify as a Data Engineering contact? Not sure what your project budget might be? [Get in touch with us](../concepts/getting_help.md) and we'll help you figure it out.

[file a ticket]: https://bugzilla.mozilla.org/enter_bug.cgi?assigned_to=nobody%40mozilla.org&bug_ignored=0&bug_severity=normal&bug_status=NEW&bug_type=task&cf_fx_iteration=---&cf_fx_points=---&comment=%2A%2A%20Please%20fill%20out%20the%20following%20information%20and%20needinfo%20the%20data%20engineering%20contact%20you%20specified%20below%20%2A%2A%0D%0A%0D%0AGCP-compatible%20project%20name%20%28e.g.%20missioncontrol-v2%2C%20adi-forecasting%29%3A%0D%0ALDAP%20of%20people%20who%20require%20administrative%20privileges%20for%20this%20project%3A%20%0D%0AProject%20timeline%20%28maximum%206%20months%2C%20projects%20may%20be%20renewed%20if%20development%20is%20still%20ongoing%20at%20the%20end%20of%20that%20period%29%3A%0D%0AApproximate%20budget%20for%20this%20project%20%28if%20expected%20to%20be%20greater%20than%20%241000%29%3A%0D%0AData%20Engineering%20contact%20for%20this%20project%3A%0D%0A&component=General&contenttypemethod=list&contenttypeselection=text%2Fplain&defined_groups=1&filed_via=standard_form&flag_type-4=X&flag_type-607=X&flag_type-800=X&flag_type-803=X&flag_type-936=X&form_name=enter_bug&maketemplate=Remember%20values%20as%20bookmarkable%20template&op_sys=Unspecified&priority=--&product=Data%20Platform%20and%20Tools&rep_platform=Unspecified&target_milestone=---&version=unspecified
