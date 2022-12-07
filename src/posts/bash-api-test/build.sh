#!/usr/bin/env bash

cd "$(dirname "$0")"
GENERATE_PDF=true docker-asciidoctor-builder "$@"

#apt install pandoc
./adoc2md.sh README.adoc

echo Removing \"build/README.xml\" ...
rm -f build/README.xml
