#/usr/bin/env bash

cd $(dirname $0)
for d in ../../images/posts/*
do
  convert -resize 15% $d/capa.png $d/capa.mini.png
done
