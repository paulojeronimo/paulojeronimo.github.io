#!/usr/bin/env bash
set -eou pipefail

BASE_DIR=${BASE_DIR:-`cd "$(dirname "$0")"/..; pwd -P`}
cd "$BASE_DIR"

src_dir=src; source $src_dir/common.sh

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

_all() {
  echo_and_do() {
    echo '----- BEGIN' \"$1\" -----
    eval "$1"
    echo '-----   END' \"$1\" -----
    echo
  }
  cd src
  for op in links index.{yaml,adoc}
  do
    echo_and_do "./posts/build.sh $op"
  done
  echo_and_do $0
  echo_and_do "./posts/build.sh all"
}

###########
# main code
###########

op=${1:-build}
type _$op &> /dev/null || exit 1
shift || :
_$op "$@"
