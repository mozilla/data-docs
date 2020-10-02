# Documentation Structure

The directory structure should feel comfortable to anyone who is familiar with the data platform:

```
.
|--src
   |--datasets - contains dataset level documentation
   |--tools - contains tool level documentation
   |--concepts - contains tutorials meant to introduce a new concept to the reader
   |--cookbooks - focused code examples for reference
```

This documentation is meant to take the reader from beginner to expert.

- Getting Started: Introduce concepts and provides information on how to perform and complete a simple analysis, so the user understands the amount of work involved and what the data platform feels like. Primarily intended for people new to Mozilla's data platform.
- Tutorials & Cookbooks: Guides on how to perform specific tasks. Intended for all audiences.
- Reference material: In-depth reference material on metrics and the data platform. Intended primarily for more advanced users.

This document's structure is heavily influenced by
[Django's Documentation Style Guide](https://docs.djangoproject.com/en/1.11/internals/contributing/writing-documentation/).
