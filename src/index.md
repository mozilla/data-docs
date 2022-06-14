# Mozilla Data Documentation

This documentation was written to help Mozillians analyze and interpret data collected by our products, such as
[Firefox](https://www.mozilla.org/firefox) and [Mozilla VPN](https://www.mozilla.org/products/vpn/). Mozilla refers
to the systems that collect and process this data as [Telemetry](./concepts/terminology.md#telemetry).

At [Mozilla](https://www.mozilla.org), our data-gathering and data-handling practices are anchored in our
[Data Privacy Principles](https://www.mozilla.org/en-US/privacy/principles/) and elaborated in the
[Mozilla Privacy Policy](https://www.mozilla.org/en-US/privacy/). You can learn more about what data Firefox
collects and the choices you can make as a Firefox user in the
[Firefox Privacy Notice](https://www.mozilla.org/en-US/privacy/firefox/).

If there's information missing from these docs, or if you'd like to contribute, see [this article on contributing](contributing/index.md),
and feel free to [file a bug here](https://bugzilla.mozilla.org/enter_bug.cgi?assigned_to=nobody%40mozilla.org&bug_file_loc=http%3A%2F%2F&bug_ignored=0&bug_severity=normal&bug_status=NEW&cf_fx_iteration=---&cf_fx_points=---&component=Documentation%20and%20Knowledge%20Repo%20%28RTMO%29&contenttypemethod=autodetect&contenttypeselection=text%2Fplain&defined_groups=1&flag_type-4=X&flag_type-607=X&flag_type-800=X&flag_type-803=X&flag_type-916=X&form_name=enter_bug&maketemplate=Remember%20values%20as%20bookmarkable%20template&op_sys=Linux&priority=--&product=Data%20Platform%20and%20Tools&rep_platform=x86_64&target_milestone=---&version=unspecified).

You can locate the source for this documentation in the [data-docs repository](https://github.com/mozilla/data-docs) on GitHub.

## Using this document

This documentation is divided into the following sections:

### [Introduction](introduction/index.md)

This section provides a **quick introduction** to Mozilla's Telemetry data: it should help you understand how this data is collected and how to begin analyzing it.

### [Cookbooks & Tutorials](cookbooks/index.md)

This section contains tutorials presented in a simple problem/solution format, organized by topic.

### [Data Platform Reference](reference/index.md)

This section contains detailed reference material on the Mozilla data platform, including links to other resources where appropriate.

### [Dataset Reference](datasets/reference.md)

In-depth references for some of the major datasets we maintain for our
products.

For each dataset, we include a description of the dataset's purpose,
what data is included, how the data is collected,
and how you can change or augment the dataset.
You do not need to read this section end-to-end.

### [Historical Reference](historical/index.md)

This section contains some documentation of things that used to be part of the Mozilla Data Platform, but are no
longer. You can generally ignore this section, it is intended only to answer questions like "what happened to X?".

You can find the [fully-rendered documentation here](https://docs.telemetry.mozilla.org),
rendered with [mdBook](https://github.com/rust-lang/mdBook), and hosted on Github pages.
