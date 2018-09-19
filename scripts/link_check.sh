#!/bin/bash

if command -v parallel > /dev/null; then
  RUNNER="parallel"
else
  RUNNER="xargs -n1"
fi

find . -name "*.md" |\
  grep -v "_book" |\
  grep -v "node_modules" |\
  sort |\
  $RUNNER -P 8 markdown-link-check --quiet --verbose --config .linkcheck.json
