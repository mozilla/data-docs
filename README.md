# Firefox Data Documentation

This document will teach you how to answer questions about Firefox Users with data.
You can find the [rendered documentation here](https://mozilla.github.io/firefox-data-docs/).

This documentation is rendered with [GitBook](https://www.gitbook.com), and hosted on Github pages.


## Building the documentation

To build the documentation locally, you'll need to install the gitbook-cli app with npm:
```bash
npm install gitbook-cli -g
```

You can then clone the repository and serve the documentation locally with:
```
gitbook serve
```

The complete documentation for the gitbook toolchain is at: https://toolchain.gitbook.com/.

## Adding a new article

This documentation is under active development,
so we may already be working on the documentation you need.
Take a look at 
[this bug tree](https://bugzilla.mozilla.org/showdependencytree.cgi?id=1341617&hide_resolved=1)
to check.
Please open a new bug if you spot any missing documentation.

Articles can be written in either 
[Markdown](https://daringfireball.net/projects/markdown/syntax) or 
[AsciiDoc](http://asciidoctor.org/docs/asciidoc-syntax-quick-reference/).
I recommend using Markdown by default.
If you run into any technical limitations, let me (@harter) know.
I'm happy to change the tooling to make it as much fun as possible to write.

Be sure to link to your new article from `SUMMARY.md`, or GitBook will not render the file.

### Review

Once your happy with your contribution, please open a PR and flag @harterrt for review. 
Please squash your changes  into meaningful commits  and follow these
[commit message guidelines](https://chris.beams.io/posts/git-commit/).


I'll give it review for clarity.
This documentation is meant to address higher level concepts,
so I'm aiming to keep a conversational tone throughout the document.
Beyond that, I don't have a strong opinion.
If you'd find it helpful,
we have some consumers of this documentation who have agreed to review PRs for clairty.
This will give you a fresh set of eyes to identify any jargon or difficult to understand sections.

