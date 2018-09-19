#!/bin/bash

if command -v parallel > /dev/null; then
  RUNNER="parallel --will-cite"
else
  RUNNER=xargs
fi

find . -name "*.md" |\
  grep -v "_book" |\
  grep -v "node_modules" |\
  sort |\
  $RUNNER -P 8 markdown-link-check --quiet --verbose --config .linkcheck.json
