#!/usr/bin/env bash
set -eou pipefail

usage_file=$(mktemp)
trap 'rm -f -- "$usage_file"' EXIT
cat <<USAGE > "$usage_file"
Usage:

$ # NOTE -> You can use <tab> to point to the 'specific-dir'
$ $0 <all [links]|index.[yaml|adoc]|specific-dir>

Examples:

$ # generates all posts:
$ $0 all

$ # generates the index.adoc for all posts:
$ $0 index.adoc

$ # generates the existing post in the current directory:
$ $0 . # generates the post in the current directory

$ # generates the post in a specific directory:
$ $0 src/posts/ha-nove-anos-me-tornei-um-ironman/
USAGE

START_DIR=$PWD
cd "$(dirname "$0")"

# configure docker-asciidoctor-builder to not use docker
export USE_DOCKER=${USE_DOCKER:-false}

BASE_DIR=../..
src_dir=..; source $src_dir/common.sh

[ $# = 1 -o $# = 2 ] || { cat "$usage_file"; exit 0; }
if [[ $1 =~ ^index\.(yaml|adoc)?$ ]]
then
  ! [ "$1" = index.adoc ] || ./generate-mini.sh
  ./$1.sh
  exit $?
elif [[ $1 =~ ^\.$ ]]
then
  set -- "$START_DIR"
fi
selected_post=$1
selected_post=${selected_post%/}
selected_post=${selected_post##*/}

posts=$(find . -maxdepth 1 -type d ! \( \
  -name . -o \
  -name common -o \
  -name test-data \))

posts_dir=$(mkdir -p "$BASE_DIR/$html_dir"/posts && cd "$_" && pwd)
for post in $posts
do
  post=${post##./}

  if [ "$selected_post" != all ] && [ "$selected_post" != $post ]
  then
    echo "Skipping $post ..."
    continue
  fi

  echo "Building $post ..."
  cd "$post"

  # fix required directories locations
  if $USE_DOCKER
  then
    rsync -a --delete ../common ./
    rsync -a --delete ../$BASE_DIR/images ./
  else
    rm -rf common images
    ln -sf ../common
    ln -sf ../$BASE_DIR/images
  fi

  ! [ "${2:-}" = links ] || { cd ..; continue; }

  if [ -x build.sh ]
  then
    ./build.sh -a baseuri=${baseuri} \
      -a postdir=$post -a og-description="'$(<abstract.txt)'"
  else
    GENERATE_PDF=true docker-asciidoctor-builder -a baseuri=${baseuri} \
      -a postdir=$post -a og-description="'$(<abstract.txt)'"
  fi
  if [ $? = 0 ]
  then
    images_dir=$(grep -e '^:imagesdir:' common/header.adoc | head -1 | cut -d: -f3 | xargs)
    js_dir=../$BASE_DIR/js
    mkdir -p $js_dir
    js=copy-to-clipboard.js
    sed "s,\$images_dir,$images_dir,g" common/$js > $js_dir/$js
  fi

  cd ..

  # post artifacts copy
  mkdir -p "$posts_dir"/$post
  rsync -a --exclude images $post/build/ "$posts_dir"/$post/
  f="$posts_dir"/$post/$post.pdf
  if [ -f "$f" ]
  then
    mv "$f" "$posts_dir"
  fi

  # fix the behaviour of copycss (wich is not working)
  rm -f "$posts_dir"/$post/asciidoctor.css

  echo
done
