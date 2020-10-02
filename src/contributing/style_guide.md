# Style Guide

These are some general style guidelines for articles which appear on `docs.telemetry.mozilla.org` (DTMO). Reading these guidelines can help you write content that is more accessible and easier to understand.

<!-- toc -->

## Audience

_Data practitioners_ at Mozilla represent the primary audience for DTMO. A "data practitioner" is someone who wants to inform themselves or others using Mozilla-collected data. Here are some real-world examples of this persona:

- A data scientist performing an experiment analysis
- An analyst producing a report on the effectiveness of a recent marketing campaign
- A Firefox engineer trying to measure the performance of a new feature
- A technical product manager trying to understand the characteristics of a particular user segment
- A quality assurance engineer trying to understand the severity and frequency of a new Firefox crash

In general, you can assume that readers have at least some technical knowledge.
Different articles on DTMO may have different target audiences: when you write a new article, you should consider who you are writing it for and adjust your content appropriately.
For example, a new product manager may require more careful hand-holding (and links to relevant concept or reference material) than a data scientist with many years of experience at Mozilla.

Note that "data engineers" (the maintainers of the Mozilla data platform and tools) are _not_ the target audience for DTMO, though they may find some resources here helpful in the course of the work.
If something is _only_ of interest to a data engineer, it probably belongs elsewhere: see the note below on [implementation-specific articles](#implementation-specific-articles).

## What to write

There are three different types of documentation that are useful as part of a site like DTMO:

- Introductory material: Material intended to help people get their bearings with Mozilla's telemetry system. A set of these articles form the [Getting Started](../concepts/getting_started.md) section on this site.
- Tutorials & Cookbooks: Instructions on how to perform specific tasks using Mozilla's data platform. The focus here is on how to do things, rather than on what they are.
- Reference: Reference material on either [datasets](../datasets/reference.md) or the [data platform itself](../reference/index.md). The focus is on describing how things work or what they do, rather than how to use them.

In general, the most useful documentation for newcomers is usually a cookbook or tutorial as [they often don't know where to begin](https://stevelosh.com/blog/2013/09/teach-dont-tell/). For advanced users, reference material may be more useful.

## What _not_ to write

There are a few types of documentation that are less appropriate for a general-purpose reference like DTMO.

### Implementation-specific articles

Any articles that are specific to the implementation of particular data systems or tools should be published alongside the system or tool itself. Examples of this may include:

- Usage guides for command-line tools
- In-depth documentation on architecture and design choices (beyond a general overview)
- A general usage guide for [specific data tool](../tools/interfaces.md)

In the past, this type of documentation has gone out of date quickly as people update the implementation while forgetting to update what has been written here.
Vast amounts of implementation detail can also be overwhelming to anyone who just wants to get an answer to a data-related question.

That said, it can sometimes be useful to provide a general overview of a topic on DTMO while saving the details for site-specific documentation.
A good example of this is the [gcp-ingestion](https://mozilla.github.io/gcp-ingestion/) documentation: while we maintain [a high-level description of the data pipeline here](../concepts/pipeline/gcp_data_pipeline.md), details on the Beam-specific implementation are stored alongside the source on GitHub.

### Lists of links

Articles which simply link out to other resources are of limited value and tend to go out of date quickly. Instead, consider your motivation for producing the list and think about what your [intended audience](#audience) might need. Concept, reference, or tutorial documentation need not be long to be helpful.

Of course, linking to other resources as part of other documentation is always okay.

## General guidelines

- Articles should be written in Markdown:
  mdBook uses the [CommonMark dialect](https://commonmark.org/help/)
  as implemented by [`pulldown-cmark`](https://github.com/raphlinus/pulldown-cmark),
  which supports certain extensions including GitHub-flavored tables.
- Limit lines to **100 characters** where possible.
  Try to split lines at the end of sentences,
  or use [Semantic Line Breaks](http://rhodesmill.org/brandon/2012/one-sentence-per-line/).
  This makes it easier to reorganize your thoughts later.
- This documentation is almost always read digitally.
  Keep in mind that people read digital content much differently than other media.
  Specifically, readers are going to skim your writing,
  so make it easy to identify important information.
  - Use **visual markup** like **bold text**, `code blocks`, and section headers.
  - Avoid long paragraphs: short paragraphs that describe one concept each makes finding important information easier.
  - When writing longer articles with many sections, use a [table of contents](./index.md#table-of-contents) to help people quickly navigate to a section of interest.

## Writing style

The following is a distillation of common best practices for technical writing in a resource like DTMO. Following these guidelines helps give our documentation a consistent voice and makes it easier to read:

- In general: use a friendly, conversational tone. This makes the documentation more approachable.
- Avoid specifying particular people or teams unless absolutely necessary: change is constant at Mozilla, and the person or people who maintains a system today is not necessarily the same as yesterday.
- If possible, use "you" when describing how to do something. Avoid use of first person (for example: "I", "we", "our") as this emphasizes the writer rather than the reader and it is often unclear who "I", "we" or "our" actually refer to.
- Avoid unnecessary formalities like "please" or "thank you".
- Where it makes sense, use present tense (as opposed to future tense). For example, "You need to perform the following tasks" is preferable to "You will need to perform the following tasks".
- Where possible, avoid the use of the passive voice (identifying the agent of action as the subject of the sentence): active voice sentences are generally clearer and less verbose. For example, "Press OK to confirm changes" is preferable to "The system will confirm changes when you press OK". You can use a tool like [write-good](https://github.com/btford/write-good) to identify uses of passive voice in your own work.

For much more helpful advice on technical writing, you may wish to review the [OpenStack General Writing Guidelines](https://docs.openstack.org/doc-contrib-guide/writing-style/general-writing-guidelines.html), which inspired some of the above.

## Colophon

You can find more context for these guidelines in
[this literature review](http://blog.harterrt.com/lit-review.html) and [this follow-up on organization and audience](https://wlach.github.io/blog/2020/05/a-principled-reorganization-of-docs-telemetry-mozilla-org/).
