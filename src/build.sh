#!/usr/bin/env bash
set -eou pipefail

BASE_DIR=${BASE_DIR:-`cd "$(dirname "$0")"/..; pwd -P`}
cd "$BASE_DIR"

config=src/build.conf
[ -r $config ] || config=$config.sample
source $config

####################
# callable functions
####################

_build() {
  # https://github.com/paulojeronimo/dotfiles/blob/master/.scripts/docker/docker-asciidoctor
  docker-asciidoctor -D $html_dir $doc

  # blog posts page:
  asciidoctor -D $html_dir/posts src/posts/index.adoc
}

_clean() {
  find $html_dir -type f \( \
    -name index.html -o \
    -wholename "$css_dir/asciidoctor.css" -o \
    -wholename "$css_dir/coderay-asciidoctor.css" \) \
    -delete
}

###########
# main code
###########

op=${1:-build}
type _$op &> /dev/null || exit 1
shift || :
_$op "$@"
