#!/usr/bin/env bash
set -eou pipefail

usage_file=$(mktemp)
trap 'rm -f -- "$usage_file"' EXIT
cat <<USAGE > "$usage_file"
Usage:

NOTE -> You can use <tab> to point the 'specific-dir':
$ $0 <all|index[.yaml]|specific-dir>

Examples:
$ $0 all
$ $0 index
$ $0 src/posts/ha-nove-anos-me-tornei-um-ironman/
USAGE

cd "$(dirname "$0")"

# configure docker-asciidoctor-builder to not use docker
export USE_DOCKER=${USE_DOCKER:-false}

BASE_DIR=../..
src_dir=..; source $src_dir/common.sh

[ $# = 1 ] || { cat "$usage_file"; exit 0; }
if [[ $1 =~ ^index(\.yaml)?$ ]]
then
  echo ./build.$1.sh
  exit $?
fi
selected_post=$1
selected_post=${selected_post%/}
selected_post=${selected_post##*/}

posts=$(find . -maxdepth 1 -type d ! \( -name . -o -name common \))

posts_dir=$(mkdir -p "$BASE_DIR/$html_dir"/posts && cd "$_" && pwd)
for post in $posts
do
  post=${post##./}

  if [ "$selected_post" != all ] && [ "$selected_post" != $post ]
  then
    echo "Skipping $post ..."
    continue
  fi

  cd "$post"

  # fix required directories locations
  if $USE_DOCKER
  then
    rsync -a --delete ../common ./
    rsync -a --delete ../$BASE_DIR/images ./
  else
    rm -rf common images
    ln -s ../common
    ln -s ../$BASE_DIR/images
  fi

  GENERATE_PDF=true docker-asciidoctor-builder -a postdir=$post

  post_title=$(get-post-title) || post_title="$post"
  echo Updating title on build/$post.pdf to \"$post_title\"
  post_title=$(sed 's/,/\\,/g' <<< "$post_title")
  post_title=$(iconv -f UTF-8 -t ISO-8859-15 <<< "$post_title")
  sed -i "s,\(/Title \)\((Untitled)\),\1\($post_title\),g" build/$post.pdf
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
