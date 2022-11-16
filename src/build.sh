#!/usr/bin/env bash
set -eou pipefail
BASE_DIR=${BASE_DIR:-`cd "$(dirname "$0")"/..; pwd -P`}
BASE_NAME=`basename "$BASE_DIR"`
cd "$BASE_DIR"

config=src/build.conf
[ -r $config ] || config=$config.sample
source $config

####################
# internal functions
####################

# TODO: write a better implementation using a map
get-pt-month() {
  local pt_months=(
    'janeiro' 'fevereiro' 'março' 'abril'
    'maio' 'junho' 'julho' 'agosto'
    'setembro' 'outubro' 'novembro' 'dezembro'
  )
  local pt_month=${1,,}
  month=1
  while (( month <= 12 ))
  do
    [ "${pt_months[((month-1))]}" = "$pt_month" ] && break
    (( month++ ))
  done
  (( $month <= 12 )) && echo -n $month || echo -n '??'
}

get-iso-date() {
  local input_regex='^([0-9]{1,2})\ de\ ([a-zA-Z]{4,8})\ de\ ([0-9]{4})$'
  local day
  local month
  local year

  if [[ "$1" =~ $input_regex ]]
  then
    day=${BASH_REMATCH[1]}
    month=$(get-pt-month ${BASH_REMATCH[2]})
    year=${BASH_REMATCH[3]}
    printf '%04d-%02d-%02d' $year $month $day
  else
    echo \"$1\" is invalid!
  fi
}

create-post-yaml() {
  local posts_yaml_file=$1
  local post_id=$(cut -d: -f1 <<< "$2" | cut -d/ -f3)
  local post_date=$(cut -d: -f4 <<< "$2" | xargs)

  cat <<EOF | tee -a $posts_yaml_file
$post_id:
  date: $(get-iso-date "$post_date")
EOF
}

####################
# callable functions
####################

_build() {
  # https://github.com/paulojeronimo/dotfiles/blob/master/.scripts/docker/docker-asciidoctor
  docker-asciidoctor -D $html_dir $doc

  # blog posts page:
  asciidoctor -D $html_dir/posts src/posts/index.adoc
}

_clean() {
  find $html_dir -type f \( \
    -name index.html -o \
    -wholename "$css_dir/asciidoctor.css" -o \
    -wholename "$css_dir/coderay-asciidoctor.css" \) \
    -delete
}

_generate-posts-index() {
  local posts_txt_file=$tmp_dir/posts.txt
  local posts_yaml_file=$tmp_dir/posts.yaml

  find src/posts -type f -name README.adoc | xargs grep '^:PostDate:' > $posts_txt_file
  > $posts_yaml_file
  while read line
  do
    create-post-yaml $posts_yaml_file "$line"
  done < $posts_txt_file
}

################
# test functions
################

_test-get-iso-date() {
  while read input_date
  do
    get-iso-date "$input_date"
    echo
  done < src/test-data/get-iso-date.txt
}

_test-get-pt-month() {
  get-pt-month "$1" 
}

###########
# main code
###########

mkdir -p $tmp_dir
op=${1:-build}
type _$op &> /dev/null || exit 1
shift || :
_$op "$@"
