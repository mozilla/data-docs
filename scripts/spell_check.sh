#!/bin/sh
# file ignores are broken in .spelling, list them in this script instead

mdspell \
    'src/**/*.md' \
    '!src/cookbooks/new_ping_metadata_table.md' \
    --ignore-numbers \
    --en-us \
    --report
