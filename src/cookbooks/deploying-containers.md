# Building and Deploying Containers to Google Container Registry (GCR) with CircleCI

The following cookbook describes how to set up automated build and deployment for containers with CircleCI, a useful pattern for scheduling custom jobs in Google Kubernetes Engine.

Note that this method intended for rapid prototyping rather than for production workloads.
If you need to transition a prototype to a production deployment,
[file a Data Platform and Tools > Operations bug](https://bugzilla.mozilla.org/enter_bug.cgi?product=Data+Platform+and+Tools&component=Operations)
to start the conversation.

<!-- toc -->

## Assumptions

- Your GitHub project's repository has a working Dockerfile at its root
  - If your file is not named `Dockerfile` or not located in the repo root, see the docs for the [CircleCI GCP-GCR orb](https://circleci.com/orbs/registry/orb/circleci/gcp-gcr) for additional configuration
- The repository is in the [`mozilla` GitHub org](https://github.com/mozilla) (or another org with a paid CircleCI account)

## Steps

### On GCP

- Make sure "Container Registry" (https://console.cloud.google.com/gcr/images/\<your-project-id\>) is enabled for your GCP project
- Create a service account, give it the "Storage Admin" role and create a key
  - Console Link: [Google Cloud Platform](https://console.cloud.google.com/iam-admin/serviceaccounts)
  - Additional documentation: [Configuring access control  |  Container Registry Documentation](https://cloud.google.com/container-registry/docs/access-control?hl=en_US)

### On CircleCI

- **IMPORTANT SECURITY STEP**
  - Go to your project’s CircleCI Advanced Settings Page (e.g. https://circleci.com/gh/mozilla/pensieve/edit#advanced-settings) and make sure that the "_Pass secrets to builds from forked pull requests_" option is TURNED OFF
    - This prevents a bad actor from creating a PR with a CI job that spits out your environment variables to the console, for instance
  - If you can't access your project settings page, make sure you’re logged into CircleCI via your Mozilla GitHub account and that you are a project administrator
- On the CircleCI Environment Variables page (e.g. https://circleci.com/gh/mozilla/pensieve/edit#env-vars), add:
  - `GOOGLE_PROJECT_ID`: the project ID that you created in step 1
  - `GOOGLE_COMPUTE_ZONE`: any compute zone will do, apparently -- try `us-west1` if you're agnostic
  - `GCLOUD_SERVICE_KEY`: paste in the entire text of the service account key that you generated in step 2
  - Check out the docs for the [CircleCI GCP-GCR orb](https://circleci.com/orbs/registry/orb/circleci/gcp-gcr) for other environment variables that you may set

### In your GitHub Repo

- In your CircleCI config file add a changeset like this:
  - [Add automated deployment of docker image to google container registry…](https://github.com/mozilla/pensieve/commit/b56f6f78b16d5893ff1cbf1ba895fa5bc85266c0)
  - The `orb` directive allows the use of the [CircleCI GCP-GCR orb](https://circleci.com/orbs/registry/orb/circleci/gcp-gcr) build-and-push-image job
  - In your `workflows` section, add `gcp-gcr/build-and-push-image` as a job and require any dependencies you’d like to pass before pushing a new image. Assuming you only want this deployment to occur on new commits to master, add a filter for only the master branch (as in the changeset above)
- Create and merge a pull request for this changeset and your newly built image should be in your project’s container registry in a few moments!

### Optional

If your repository is public, you may want to make its container registry publicly readable as well. Go to the GCP container registry’s Settings tab and in the "Public access" section change the visibility for `gcr.io` (the default host if you followed these instructions) to `Public`.
