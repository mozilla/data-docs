#!/bin/bash
export TERM=xterm-color

SEARCH_ARR=(${@:-})

if [[ -z $SEARCH_ARR ]]; then
  SEARCH_ARR=(`find src -name "*.md"`)
fi

LINKCHECK_CMD="npx markdown-link-check --quiet --verbose --config .linkcheck.json"

if command -v parallel > /dev/null; then
  parallel -P 8 $LINKCHECK_CMD ::: "${SEARCH_ARR[@]}"
else
  echo "${SEARCH_ARR[*]}" | xargs -n1 $LINKCHECK_CMD
fi
