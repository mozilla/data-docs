# Mozilla Data Documentation

[![Build Status](https://github.com/mozilla/data-docs/workflows/Build/badge.svg)](https://github.com/mozilla/data-docs/actions?query=workflow%3ABuild)

This document is intended to help Mozilla's developers and data scientists
analyze and interpret the data gathered by the Firefox Telemetry system.

At [Mozilla](https://www.mozilla.org), our data-gathering and data-handling
practices are anchored in our
[Data Privacy Principles](https://www.mozilla.org/en-US/privacy/principles/)
and elaborated in the [Mozilla Privacy Policy](https://www.mozilla.org/en-US/privacy/).

To learn more about what data Firefox collects and the choices you can make
as a user, please see the [Firefox Privacy Notice](https://www.mozilla.org/en-US/privacy/firefox/).

The rendered documentation is hosted at [https://docs.telemetry.mozilla.org/](https://docs.telemetry.mozilla.org/).

Issues for this documentation are [tracked in Bugzilla][docszilla] ([file a bug]).

[docszilla]: https://bugzilla.mozilla.org/buglist.cgi?product=Data%20Platform%20and%20Tools&component=Documentation%20and%20Knowledge%20Repo%20%28RTMO%29&resolution=---
[file a bug]: https://bugzilla.mozilla.org/enter_bug.cgi?component=Documentation%20and%20Knowledge%20Repo%20(RTMO)&product=Data%20Platform%20and%20Tools

## Building the Documentation

The documentation is rendered with [mdBook](https://github.com/rust-lang/mdBook).
We use a fork named [mdbook-dtmo](https://github.com/badboy/mdbook-dtmo) that includes a number of custom additions to mdbook for our environment
(for example, a plugin to automatically generate a table-of-contents).

You can download `mdbook-dtmo` on the [GitHub releases page](https://github.com/badboy/mdbook-dtmo/releases).
Please use the latest version.
Unpack it and place the binary in a directory of your `$PATH`.

If you have [rustc](https://www.rust-lang.org/) already installed, you can install a pre-compiled binary directly:

```bash
curl -LSfs https://japaric.github.io/trust/install.sh | sh -s -- --git badboy/mdbook-dtmo
```

Make sure this directory is in your `$PATH` or copy it to a directory of your `$PATH`.

You can also build and install the preprocessors:

```bash
cargo install mdbook-dtmo
```

You can then serve the documentation locally with:

```
mdbook-dtmo serve
```

The complete documentation for the mdBook toolchain is available online at <https://rust-lang.github.io/mdBook/>.
If you run into any problems, please [let us know](https://docs.telemetry.mozilla.org/concepts/getting_help.html). We are happy to change the tooling to make it as much fun as possible to write.

### Spell checking

Articles should use proper spelling, and pull requests will be automatically checked for spelling
errors.

Technical articles often contain words that are not recognized by common dictionaries, if this
happens you may either put specialized terms in `code blocks`, or you may add an exception to
the `.spelling` file in the code repository.

For things like dataset names or field names, `code blocks` should be preferred. Things like
project names or common technical terms should be added to the `.spelling` file.

The [markdown-spell-check](https://www.npmjs.com/package/markdown-spellcheck) package checks spelling as part of the build process. To run it locally, install [node.js](https://nodejs.org/en/) (if not already installed) and run `npm install` at the root of the repository. Then run the `scripts/link_check.sh` script.

You may also remove the `--report` parameter to begin an interactive fixing session. In this
case, it is highly recommended to also add the `--no-suggestions` parameter, which greatly
speeds things up.

### Link checking

Any web links should be valid. A dead link might not be your fault, but you will earn a lot of good karma by fixing a dead link!

The [markdown-link-check](https://www.npmjs.com/package/markdown-link-check) package checks links as part of the build process. Note that dead links do not fail the build: links often go dead for all sorts of reasons, and making it a required check constantly caused otherwise-fine pull requests to appear broken. Still, you should check the status of this check yourself when submitting a pull request: you can do this by looking at the Travis CI status after submitting it.

To run link checking locally, run the installation steps [described for spell checking](#spell-checking) if you haven't already, then run the `scripts/link_check.sh` script.

### Markdown formatting

We use [prettier](https://prettier.io) to ensure a consistent formatting style in our markdown.
To reduce friction, this is not a required check but running it on the files
you're modifying before submission is highly appreciated!
Most editors can be configured to run prettier automatically,
see for example the
[Prettier Plugin for VSCode](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode).

To run prettier locally on the entire repository, run the installation steps
[described for spell checking](#spell-checking) if you haven't already, then
run the `scripts/prettier_fix.sh` script.

## Contributing

See [contributing](https://docs.telemetry.mozilla.org/contributing/index.html) for detailed information on making changes to the documentation.
