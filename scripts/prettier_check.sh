#!/bin/bash
export TERM=xterm-color

SEARCH_PATH=${@:-'src/**/*.md'}

npx prettier --write --loglevel warn $SEARCH_PATH

git --no-pager diff --color --exit-code src/ README.md
