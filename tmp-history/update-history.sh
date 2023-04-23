#!/usr/bin/env bash
set -o pipefail

[ "$1" ] || { echo A date is required!; exit 1; }

history_dir=${history_repo:-../paulojeronimo.github.io/tmp-history}
cd "$(dirname "$0")"

declare -A history_files
cd "$history_dir"
for f in $(find . -type f ! -name files.txt ); do history_files[$f]=1; done
cd "$OLDPWD"

filter() {
  while IFS= read -r f
  do
    [ "${history_files[$f]}" ] || echo $f
  done
}

for f in ${!history_files[@]}; do cp "$f" "$history_dir"/; done
find . -type f ! -path */.git/* | filter | sort | xargs sha256sum > "$history_dir"/files.txt

cd "$history_dir"
git add .
git commit -m "Updated tmp-history at $1"
