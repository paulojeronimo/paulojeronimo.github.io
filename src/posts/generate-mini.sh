#/usr/bin/env bash
set -eou pipefail

cd $(dirname $0)
images_posts_dir=../../images/posts
echo Generating miniatures for files named \"capa.png\" found in \"$images_posts_dir\"
for d in $images_posts_dir/*
do
  echo Generating \"$d/capa.mini.png\" ...
  convert -resize 15% $d/capa.png $d/capa.mini.png
done

#find images/ -type f -name capa.png | xargs identify
