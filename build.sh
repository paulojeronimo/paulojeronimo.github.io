#!/usr/bin/env bash
set -e

DEBUG=${DEBUG:-false}
$DEBUG && set -x || set +x

BASE_DIR=${BASE_DIR:-`cd "$(dirname "$0")"; pwd`}
BASE_NAME=`basename "$BASE_DIR"`

config=build.conf
[ -r $config ] || config=$config.sample
source "$BASE_DIR/$config"

_build() {
  asciidoctor -D $html_dir $doc
}

_clean() {
  find $html_dir -type f -name '*.html' -delete
}

op=${1:-build}
cd "$BASE_DIR"
type _$op &> /dev/null || exit 1
_$op
