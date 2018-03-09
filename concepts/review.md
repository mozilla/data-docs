# Getting Analysis Review

The current process for getting analysis review has not been optimized.
If you run into problems, feel free to ask in the `#datapipeline` channel on IRC.

## Table of Contents

<!-- toc -->

# Finding a Reviewer

There are two major types of review for most analyses:
**Data review** and **Methodology review**.

A **data reviewer** has **expert understanding of the dataset** your analysis is based upon.
During data review, your reviewer will try to identify
any issues with your analysis that come from misapplying the data.
For example, sampling issues or data collection oddities.

**Methodology review** primarily covers **statistical concepts**.
For example, if you're training regressions, forecasting data, or doing complex
statistical tests, you should probably get Methodology review.
Many (most?) analyses at Mozilla use simple aggregations and little to no statistical inference.
These analyses only require data review.

Accordingly, we suggest you **first find a data reviewer for your analysis**.
Your data reviewer will tell you if you should get methodology review
and will help you find a reviewer.

## Data Reviewers

To get review for your analysis,
contact one of the data reviewers listed for the dataset your analysis is based upon:

| Dataset           | Reviewers   |
| :---              | :---        |
| Longitudinal      |             |
| Cross Sectional   |             |
| Main Summary      |             |
| Crash Summary     |             |
| Crash Aggregate   |             |
| Events            |             |
| Sync Summary      |             |
| Addons            |             |
| Client Count      |             |

# Jupyter Notebooks

It's difficult to review Jupyter notebooks on Github.
The notebook is stored as a JSON object, with python code stored in strings.
This makes **commenting on particular lines very difficult**.
Because the output is stored next to the code,
it's also very **difficult to review the diff** for a given notebook.

## RTMO

For simple notebooks, the best way to get review is through the
[knowledge repo](https://github.com/mozilla/mozilla-reports).
The knowledge repo renders your Jupyter notebooks to markdown
while keeping the original source code next to the document.
This gives your reviewer an **easy-to-review markdown file**.
Your analysis will also be available at
[RTMO](http://reports.telemetry.mozilla.org/feed).
This will aid discoverability and help others find your analysis.
Note that RTMO is public so your **analysis will also be public**.

## Start a Repository

Notebooks are great for presenting information,
but are not a good medium for storing code.
If your notebook contains complicated logic or a significant amount of custom code,
you should consider moving most of the logic to a python package.
Your reviewer may ask you for tests,
which also requires moving the code out of a notebook.

### Where to store the package

The data platform team maintains a python repository of analyses and ETL called
[`python_mozetl`](https://github.com/mozilla/python_mozetl).
Feel free to file a pull request against that repository.
Your reviewer will provide analysis review during the code review.
You'll need review for each commit to `python_mozetl`'s master branch.

If you are still prototyping your job but want to move out of a Jupyter notebook,
take a look at
[`cookiecutter-python-etl`](https://github.com/harterrt/cookiecutter-python-etl).
This tool will help you configure a new python repository
so you can hack quickly without getting review.

### nbconvert

The easiest way to get your code out of a Jupyter notebook
is to use `nbconvert` command from Jupyter.
If you have a notebook called `analysis.ipynb`
you can dump your analysis to a python script using the following command:

```python
jupyter nbconvert --to python analysis.ipynb
```

You'll need to clean up some formatting in the resulting `analysis.py` file,
but most of the work has been done for you.

