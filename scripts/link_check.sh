#!/bin/bash

# If there are any failures along the way, exit nonzero.
EXIT_CODE=0
for f in $(find . -name "*.md" | grep -v "_book" | grep -v "node_modules" | sort); do
    markdown-link-check --quiet --config .linkcheck.json $f
    RC=$?
    if [ "$RC" -ne "0" ]; then
        EXIT_CODE=$RC
    fi
done

exit $EXIT_CODE
