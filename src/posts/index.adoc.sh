#!/usr/bin/env bash
set -eou pipefail

cd $(dirname $0)

:<<'TEST_CODE_1'
declare -a posts
x=abcd
y=efgh
declare -A $x
declare -A $y

eval "$x[date]=2022"
eval "$x[title]='Título abc'"

eval "$y[date]=2021"
eval "$y[title]='Título def'"

posts[0]=$x
posts[1]=$y

#echo posts=${posts[@]}
#echo abcd=${abcd[@]}
#echo 'abcd[date]=' $(eval "echo \${$x[date]}")

for e in ${posts[@]}
do
  echo 'e[date] =' $(eval "echo \${$e[date]}")
  echo 'e[title] =' $(eval "echo \${$e[title]}")
done
exit
TEST_CODE_1

input_file=index.yaml
if ! [ -f $input_file ]
then
  echo File \"$input_file\" not found. Aborting!
  exit 1
fi

declare -a posts
yq_pipes='sort_by(.date)|reverse|map([.id,.date,.language,.title,.abstract]|join("|"))|.[]'
: << 'TEST_CODE_YQ_PIPES'
yq "$yq_pipes" $input_file
exit
TEST_CODE_YQ_PIPES

i=0
while read -r line
do
  while IFS='|' read -r id date language title abstract
  do
    post_idx=$(printf "post_%04d" $i)
    posts[$i]=$post_idx
    declare -A $post_idx
    eval "$post_idx[id]=$id"
    eval "$post_idx[date]=$date"
    eval "$post_idx[language]=$language"
    eval "$post_idx[title]='$title'"
    eval "$post_idx[abstract]='$abstract'"
  done <<< "$line"
  (( i=i+1 ))
done < <(yq "$yq_pipes" $input_file)

: <<'TEST_CODE_2'
echo ----
for post in ${posts[@]}
do
  echo post = $post
  echo 'post[id] =' $(eval "echo \${$post[id]}")
  echo 'post[date] =' $(eval "echo \${$post[date]}")
  echo 'post[title] =' $(eval "echo \${$post[title]}")
  echo 'post[abstract] =' $(eval "echo \${$post[abstract]}")
  echo ----
done
exit
TEST_CODE_2

foreach-post() {
  # https://stackoverflow.com/a/18226613
  content=$(cat; echo -n ';')
  content="${content%;}"

  for post in "${posts[@]}"
  do
    sed "s/__post__/${post}/" <<< "$content"
  done
}

. mo

: <<'TEST_CODE_3'
tmp_dir=test-data/tmp
mkdir -p $tmp_dir
mo < test-data/test_code_3.mo | tee $tmp_dir/test_code_3.txt
exit
TEST_CODE_3

generated_file=${generated_file:-$(basename $0 .sh)}
echo Building \"$generated_file\" ...
mo < index.adoc.mo > $generated_file
