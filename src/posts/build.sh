#!/usr/bin/env bash
cd $(dirname $0)

BASE_DIR=../..
config_dir=..

config=$config_dir/build.conf
[ -r $config ] || config=$config.sample
source $config

posts=$(find . -maxdepth 1 -type d ! -name .)

posts_dir=$(mkdir -p $BASE_DIR/$html_dir/posts && cd $_ && pwd)
for post in $posts
do
  # post build
  post=${post##./}
  mkdir -p $post/build
  rsync -a $BASE_DIR/images $post/build
  cd $post
  GENERATE_PDF=true docker-asciidoctor-builder
  cd ..

  # post artifacts copy
  mkdir -p "$posts_dir"/$post
  rsync -a --exclude images $post/build/ "$posts_dir"/$post/
  f="$posts_dir"/$post/$post.pdf
  if [ -f "$f" ]
  then
    mv "$f" "$posts_dir"
  fi
done
