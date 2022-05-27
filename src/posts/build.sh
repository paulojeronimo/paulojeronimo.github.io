#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

BASE_DIR=../..
config_dir=..

selected_post=${1:-all}
selected_post=${selected_post%/}
selected_post=${selected_post##*/}

config=$config_dir/build.conf
[ -r $config ] || config=$config.sample
source $config

posts=$(find . -maxdepth 1 -type d ! \( -name . -o -name common \))

posts_dir=$(mkdir -p $BASE_DIR/$html_dir/posts && cd $_ && pwd)
for post in $posts
do
  post=${post##./}

  if [ "$selected_post" != all ] && [ "$selected_post" != $post ]
  then
    echo "Skipping $post ..."
    continue
  fi

  # rsync common files
  rsync -a --delete common/ $post/common/
  rsync -a --delete $BASE_DIR/images/ $post/images/

  # post build
  cd $post
  GENERATE_PDF=true docker-asciidoctor-builder -a postdir=$post
  cd ..

  # post artifacts copy
  mkdir -p "$posts_dir"/$post
  rsync -a --exclude images $post/build/ "$posts_dir"/$post/
  f="$posts_dir"/$post/$post.pdf
  if [ -f "$f" ]
  then
    mv "$f" "$posts_dir"
  fi

  echo
done
