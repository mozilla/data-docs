# Slicing Dimensions

Here we provide definitions and information about our standard slicing dimensions.

Note: the canonical, maintained dimension definitions now live as `[dimensions.*]` TOML blocks in the [metric-hub](https://github.com/mozilla/metric-hub) repository (see `definitions/*.toml` and `opmon/*.toml`), consumed programmatically by OpMon and Looker; Jetstream uses a parallel `[segments.*]` mechanism (not dimensions) for segmenting experiment populations. This page remains a stub template and does not reflect current practice.

In OpMon, a project's `[project.population.dimensions]` list of slugs (in `opmon/<project>.toml`) is matched by slug against the `[dimensions.*]` blocks defined in `definitions/<platform>.toml` (or locally overridden in the project file) to build per-project dashboard filters. Looker does not consume the `[dimensions]` section directly; filterable fields there come from data source columns (see below).

Table of contents with links to dimensions.

---

## {{Dimension Name}}

TL;DR: two sentence max.

- Overview:
- What segmentation do we want to capture
- Calculation:
- Definitions of what user has to do to qualify
- Definitions of what telemetry must be sent to qualify.
- At least one working definition
- Link to the dimension's `[dimensions.*]` TOML block (data source and `select_expression`) in [metric-hub](https://github.com/mozilla/metric-hub)
- Possibly an API-linked graph from STMO
- Common Issues: Failures and Gotchas
- Resources
- Similar dimensions

---

## {{Next Dimension Name}}
