#!/bin/bash
# file ignores are broken in .spelling, list them in this script instead
export TERM=xterm-color
export FORCE_COLOR=1

SEARCH_PATH=${@:-'src/**/*.md'}

npx mdspell \
    $SEARCH_PATH \
    '!src/cookbooks/*' \
    --ignore-numbers \
    --en-us \
    --report
