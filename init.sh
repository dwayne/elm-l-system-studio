#!/usr/bin/env bash

#
# Usage: . init.sh
#

build="${build:?}"
project="${project:?}"


# ENVIRONMENT VARIABLES


export build_development="$build/development"
export build_production="$build/production"


# FUNCTIONS


clean () {
  cd "$project" && rm -rf .build elm-stuff
}

check-scripts () {
  shellcheck --norc --shell bash "$project/bin/"* "$project/init.sh"
  #
  # --no-rc = Don't look for .shellcheckrc files
  # --shell = Specify dialect (sh, bash, dash, ksh, busybox)
  #
}

format () {
  cd "$project" && elm-format review/src src tests "${@:---yes}"
}

test-elm () {
  cd "$project" && elm-test "$@"
}

test-elm-main () {
  test-elm make src/Main.elm
}

review () {
  cd "$project" && elm-review review/src src tests
}

build-development () {
  build "$build_development"
}

build-production () {
  build -s -z -e -zz "$build_production"
}

serve-development () {
  serve "$build_development"
}

serve-production () {
  serve -p 3001 "$build_production"
}

deploy-production () {
  deploy "$@" "$build_production" release/production
}

export -f \
  clean \
  check-scripts format test-elm test-elm-main review \
  build-development build-production \
  serve-development serve-production \
  deploy-production


# ALIASES


alias c=check
alias f=format
alias t=test-elm
alias r=review
alias b=build-development
alias s=serve-development
