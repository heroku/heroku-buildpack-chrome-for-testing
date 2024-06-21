#!/usr/bin/env bash

set -euo pipefail

STACK_VERSION="${1:?'Error: The stack version number must be specified as the first argument.'}"

set -x

docker build --progress=plain --build-arg="STACK_VERSION=${STACK_VERSION}" -t heroku-buildpack-chrome-for-testing .

# Note: All of the container commands must be run via a login bash shell otherwise the profile.d scripts won't be run.

# Check the profile.d scripts correctly added the binaries to PATH.
docker run --rm heroku-buildpack-chrome-for-testing bash -l -c 'chrome --version'
docker run --rm heroku-buildpack-chrome-for-testing bash -l -c 'chromedriver --version'

# Check that there are no missing dynamically linked libraries.
docker run --rm heroku-buildpack-chrome-for-testing bash -l -c 'ldd $(which chrome)'
docker run --rm heroku-buildpack-chrome-for-testing bash -l -c 'ldd $(which chromedriver)'

# Check Chrome can fully boot in both new and old headless modes.
docker run --rm heroku-buildpack-chrome-for-testing bash -l -c 'chrome --no-sandbox --headless=new --screenshot https://google.com'
docker run --rm heroku-buildpack-chrome-for-testing bash -l -c 'chrome --no-sandbox --headless=old --screenshot https://google.com'

# Display a size breakdown of the directories added by the buildpack to the app.
docker run --rm heroku-buildpack-chrome-for-testing bash -l -c 'du --human-readable --max-depth=1 /app'
