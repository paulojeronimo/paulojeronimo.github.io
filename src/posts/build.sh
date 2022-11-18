#!/usr/bin/env bash
: <<'USAGE'
$ pwd
/home/pj/paulojeronimo.github.io

# using <tab> completion:
$ ./src/posts/build.sh src/posts/ha-nove-anos-me-tornei-um-ironman/
USAGE

set -eou pipefail
cd $(dirname $0)

# configure docker-asciidoctor-builder to not use docker
export USE_DOCKER=${USE_DOCKER:-false}

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

  cd $post

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

  post_title=$(grep '^:PostTitle:' README.adoc | cut -d: -f3 | xargs) || \
    post_title="$post"
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
