# Creating Static Dashboards with Protosaur

[`protosaur.dev`](https://protosaur.dev) allows data practitioners at Mozilla to create _prototype_ static dashboards behind Mozilla SSO (single-sign-on).
As the name implies, protosaur is intended for prototypes -- dashboards created using this system are not monitored or supported by Data Operations or Data Engineering.
Protosaur is a simple static hosting service: it does not provide form handling, databases, or any other kind of server-side operation.
However, for presenting dashboards and other types of data visualization, a static website is often all you need (see, for example, the galaxy of sites produced using [GitHub Pages](https://pages.github.com/)).

Protosaur's architecture is simple: it serves files in a [Google Cloud Storage](https://cloud.google.com/storage/) (GCS) bucket under the [`protosaur.dev`](https://protosaur.dev) domain. How you get the files into the bucket is entirely up to you: you can use CircleCI, Airflow, or any other method that you might choose.

The current procedure for creating a new protosaur dashboard is as follows:

- Find a GCP project to use for the GCS bucket. This could be a team project (if you have one already) or a [GCP prototype project](../gcp-projects.md). Using a prototype project is preferred for larger efforts with multiple components in addition to a front-end dashboard.
- Create a GCS bucket in said project.
- Upload content into the bucket (e.g. via [`gsutil`](https://cloud.google.com/storage/docs/gsutil)).
- Add the project to Protosaur's configuration, which currently lives in the [protodash repository](https://github.com/mozilla/protodash) on GitHub. For up to date instructions on how to do this, [see the project's README](https://github.com/mozilla/protodash/blob/master/README.md).
