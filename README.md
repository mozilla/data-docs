# Firefox Data Documentation

[![Linux Build Status](https://travis-ci.org/mozilla/firefox-data-docs.svg?branch=master)](https://travis-ci.org/mozilla/firefox-data-docs)

This document is intended to help Mozilla's developers and data scientists
analyze and interpret the data gathered by the Firefox Telemetry system.

At [Mozilla](https://www.mozilla.org), our data-gathering and data-handling
practices are anchored in our
[Data Privacy Principles](https://www.mozilla.org/en-US/privacy/principles/)
and elaborated in the [Mozilla Privacy Policy](https://www.mozilla.org/en-US/privacy/).

To learn more about what data Firefox collects and the choices you can make
as a user, please see the [Firefox Privacy Notice](https://www.mozilla.org/en-US/privacy/firefox/).

The rendered documentation is hosted at [https://docs.telemetry.mozilla.org/](https://docs.telemetry.mozilla.org/).

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

This documentation has some automatic checks for spelling and link validity in continuous integration. See the respective sections in the [contributing article](https://docs.telemetry.mozilla.org/meta/contributing.html) for more information.

## Contributing

See [this article](https://docs.telemetry.mozilla.org/meta/contributing.html) for detailed information on how to make additions or changes to the documentation.
