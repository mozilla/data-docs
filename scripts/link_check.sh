#!/bin/bash

if command -v parallel > /dev/null; then
  RUNNER="parallel"
else
  RUNNER="xargs -n1"
fi

find src -name "*.md" |\
  sort |\
  $RUNNER -P 8 npx markdown-link-check --quiet --verbose --config .linkcheck.json
