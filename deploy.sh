#!/bin/sh

# Depends on https://github.com/davisp/ghp-import
gitbook build && \
ghp-import -b gh-pages _book/ && git push origin gh-pages
