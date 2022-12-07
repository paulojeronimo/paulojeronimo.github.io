#!/usr/bin/env bash
set -eou pipefail

BASE_DIR=${BASE_DIR:-`cd "$(dirname "$0")"/..; pwd -P`}
cd "$BASE_DIR"

src_dir=src; source $src_dir/common.sh

####################
# callable functions
####################

_build() {
  echo-and-do "docker-asciidoctor -D $html_dir $doc"
  echo-and-do "asciidoctor -D $html_dir/posts src/posts/index.adoc"
}

_clean() {
  find $html_dir -type f \( \
    -name index.html -o \
    -wholename "$css_dir/asciidoctor.css" -o \
    -wholename "$css_dir/coderay-asciidoctor.css" \) \
    -delete
}

_all() {
  cd src
  for op in links index.{yaml,adoc}
  do
    echo-and-do "./posts/build.sh $op"
  done
  (cd "$BASE_DIR"; _build)
  echo-and-do "./posts/build.sh all"
}

###########
# main code
###########

echo -e "BASE_DIR=$BASE_DIR\n"
op=${1:-build}
type _$op &> /dev/null || exit 1
shift || :
_$op "$@"
