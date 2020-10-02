#!/bin/bash
# file ignores are broken in .spelling, list them in this script instead

npx mdspell \
    'src/**/*.md' \
    '!src/cookbooks/new_ping_metadata_table.md' \
    --ignore-numbers \
    --en-us \
    --report
