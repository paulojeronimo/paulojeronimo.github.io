# vim: syntax=bash

_test-get-iso-date() {
  while read input_date
  do
    get-iso-date "$input_date"
    echo
  done < ./test-data/get-iso-date.txt
}

_test-get-pt-month() {
  get-pt-month "$1" 
}
