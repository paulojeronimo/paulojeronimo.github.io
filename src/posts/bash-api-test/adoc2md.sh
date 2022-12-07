#!/usr/bin/env bash
set -eou pipefail

adoc_file=${1:-}
md_from_adoc=${md_from_adoc:-true}
md_from_html=${md_from_html:-false}
build_dir=${build_dir:-build}

if ! [ -f "$adoc_file" ]
then
  echo "File? "
  exit 1
fi

base_file=${adoc_file%.adoc}
html_file=$build_dir/index.html
xml_file=$build_dir/$base_file.xml
md_file=$build_dir/$base_file.md
md_from_html_file=$build_dir/$base_file.from-html.md

mkdir -p "$build_dir"

echo Generating \"$xml_file\" ...
asciidoctor -b docbook "$adoc_file" -D "$build_dir"

if $md_from_adoc
then
  echo Generating \"$md_file\" ...
  iconv -t utf-8 "$xml_file" | \
    pandoc -f docbook -t gfm --wrap=none | \
    iconv -f utf-8 > "$md_file"
fi

if $md_from_html
then
  echo Generating \"$md_from_html_file\" ...
  iconv -t utf-8 "$html_file" | \
    pandoc -f html -t gfm --wrap=none | \
    iconv -f utf-8 > "$md_from_html_file"
fi
