#!/usr/bin/env bash

cd "$(dirname "$0")"

rm -rf .git

git init -b gh-pages
git add -A
git remote add origin git@github.com:paulojeronimo/tmp.git
git commit -m "Published at $(date -Is)"
git push -f -u origin gh-pages
