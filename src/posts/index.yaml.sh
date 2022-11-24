#!/usr/bin/env bash
set -eou pipefail

BASE_DIR=${BASE_DIR:-`cd "$(dirname "$0")"; pwd -P`}
cd "$BASE_DIR"

####################
# internal functions
####################

src_dir=..; source $src_dir/common.sh

####################
# callable functions
####################

_generate-index() {
  local index_yaml_file=index.yaml

  ./build.sh all links

  echo Building \"$index_yaml_file\" ...
  > $index_yaml_file

  while IFS= read -r line
  do
    create-yaml $index_yaml_file "$line"
  done < <(find . -type f -name uris-and-attributes.adoc | \
    xargs grep '^:PostDate:')
}

source $src_dir/test-functions.sh

###########
# main code
###########

op=${1:-generate-index}
type _$op &> /dev/null || exit 1
shift || :
_$op "$@"
