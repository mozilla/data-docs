#!/bin/sh

build_dir='book'

# Depends on https://github.com/davisp/ghp-import
mdbook build . --dest-dir $build_dir && \
touch $build_dir/.nojekyll && \
ghp-import \
    -b gh-pages \
    -c docs-origin.telemetry.mozilla.org \
    $build_dir && \
git push origin gh-pages
