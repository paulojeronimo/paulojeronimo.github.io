# vim: syntax=bash

get-post-title() {
  local f=${1:-README.adoc}
  grep '^:PostTitle:' $f | cut -d: -f3 | xargs
}

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

create-yaml() {
  local index_yaml_file=$1
  local index_txt_line=$2
  local readme_adoc_file=$(cut -d: -f1 <<< "$index_txt_line")
  local post_id=$(cut -d/ -f2 <<< "$readme_adoc_file")
  local post_date=$(cut -d: -f4 <<< "$index_txt_line" | xargs)
  local post_title=$(get-post-title "$readme_adoc_file") || :

  if [ "$post_title" ]
  then
    post_title="title: $post_title"
  fi

  cat <<EOF | tee -a $index_yaml_file
$post_id:
  date: $(get-iso-date "$post_date")
  $post_title
EOF
}
