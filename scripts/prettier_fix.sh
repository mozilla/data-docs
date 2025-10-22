#!/bin/bash
export TERM=xterm-color

SEARCH_PATH=${@:-'src/**/*.md'}

npx prettier --write --log-level warn $SEARCH_PATH
