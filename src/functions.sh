# vim: syntax=bash

echo-and-do() {
  echo '----- BEGIN' \"$1\" -----
  eval "$1"
  echo '-----   END' \"$1\" -----
  echo
}

get-post-title() {
  local f=${1:-uris-and-attributes.adoc}
  grep '^:PostTitle:' $f | cut -d: -f3 | xargs
}

get-pt-month() {
  declare -r -A months=(
    [janeiro]=1 [fevereiro]=2 [março]=3 [abril]=4
    [maio]=5 [junho]=6 [julho]=7 [agosto]=8
    [setembro]=9 [outubro]=10 [novembro]=11 [dezembro]=12)
  local month=${1,,}
  local result=${months[$month]}
  [ "$result" ] && echo -n $result || echo -n '??'
}

get-en-month() {
  declare -r -A months=(
    [january]=1 [february]=2 [march]=3 [april]=4
    [may]=5 [june]=6 [july]=7 [august]=8
    [september]=9 [october]=10 [november]=11 [december]=12)
  local month=${1,,}
  local result=${months[$month]}
  [ "$result" ] && echo -n $result || echo -n '??'
}

get-date-and-language() {
  local pt_br_date='^([0-9]{1,2})\ de\ ([a-zA-Z]{4,8})\ de\ ([0-9]{4})$'
  local en_date='^([a-zA-Z]{3,9}) ([0-9]{1,2}), ([0-9]{4})$'
  local day
  local month
  local year

  if [[ "$1" =~ $pt_br_date ]]
  then
    day=${BASH_REMATCH[1]}
    month=$(get-pt-month ${BASH_REMATCH[2]})
    year=${BASH_REMATCH[3]}
    printf '%04d-%02d-%02d,pt_br' $year $month $day
  elif [[ "$1" =~ $en_date ]]
  then
    month=$(get-en-month ${BASH_REMATCH[1]})
    day=${BASH_REMATCH[2]}
    year=${BASH_REMATCH[3]}
    printf '%04d-%02d-%02d,en' $year $month $day
  else
    echo \"$1\" is invalid!
  fi
}

get-mo() {
  if $get_mo
  then
    if ! [ -x mo ]
    then
      echo Downloading \"mo\" script from \"$get_mo_link\" ...
      if ! curl -sSL $get_mo_link -o mo
      then
        echo Fail! Aborting.
        exit 1
      fi
      chmod +x mo
    fi
  else
    if ! [ -x mo ]
    then
      echo Script \"mo\" no found in \"$PWD\"! Aborting.
      exit 1
    fi
  fi
}

create-abstract-doc() {
  cat<<'EOF' > $1
include::common/header.adoc[]

include::abstract.adoc[]
EOF
}

create-yaml() {
  local index_yaml_file=$1
  local index_txt_line=$2
  local readme_adoc_file=$(cut -d: -f1 <<< "$index_txt_line")
  local post_id=$(cut -d/ -f2 <<< "$readme_adoc_file")
  local date_and_language=$(get-date-and-language "$(cut -d: -f4 <<< "$index_txt_line" | xargs)")
  local post_date=$(cut -d, -f1 <<< "$date_and_language")
  local post_language=$(cut -d, -f2 <<< "$date_and_language")
  local post_title=$(get-post-title "$readme_adoc_file")
  local abstract_doc_adoc_file=$post_id/abstract-doc.adoc

  create-abstract-doc $abstract_doc_adoc_file

  local post_abstract=$(asciidoctor --no-header -o - $abstract_doc_adoc_file \
    | sed -e 's/<[^>]*>//g' | xargs)

  echo Generating file \"$post_id/abstract.txt\" ...
  echo "$post_abstract" > $post_id/abstract.txt

  get-mo; . mo
  mo < index.yaml.mo >> $index_yaml_file

  rm -f $abstract_doc_adoc_file
}
