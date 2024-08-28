#!/bin/bash
# Note: System ruby no longer installed in Cedar-22 onwards,
# In order to be executed after Ruby buildpack,
# this file's name has to be later than "ruby.sh"
# in alphabetical order.
# https://devcenter.heroku.com/articles/heroku-22-stack#system-ruby-is-no-longer-installed

# Debug, echo every command
#set -x

exists() {
    [ -e "$1" ]
}

shopt -s globstar

# Each bundle is generated with a unique hash name to bust browser cache.
# Use shell `*` globbing to fuzzy match.
# create-react-app v2 with Webpack v4 splits the bundle, so process all *.js files.
js_bundle_filenames="${JS_RUNTIME_TARGET_BUNDLE:-/app/build/static/js/*.js}"

if ! exists $js_bundle_filenames
then
  echo "Error injecting runtime env: bundle not found '$js_bundle_filenames'. See: https://github.com/mars/create-react-app-buildpack/blob/master/README.md#user-content-custom-bundle-location"
fi

# Fail immediately on non-zero exit code.
set -e

for js_bundle_filename in $js_bundle_filenames
do
  echo "Injecting runtime env into $js_bundle_filename (from .profile.d/z_inject_react_app_env.sh)"

  # Render runtime env vars into bundle.
  ruby -E utf-8:utf-8 \
   -r /app/.heroku/create-react-app/injectable_env.rb \
   -e "InjectableEnv.replace('$js_bundle_filename')"
done
