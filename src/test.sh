#!/usr/bin/env bash
set -eou pipefail

BASE_DIR=${BASE_DIR:-`cd "$(dirname "$0")"/..; pwd -P`}
cd "$BASE_DIR"

src_dir=src; source $src_dir/common.sh
source $src_dir/test-functions.sh

###########
# main code
###########

echo -e "BASE_DIR=$BASE_DIR\n"
op=${1:-get-iso-date}
type _test-$op &> /dev/null || exit 1
shift || :
_test-$op "$@"
