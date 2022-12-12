# vim: syntax=bash

_test-get-iso-date() {
  while read input_date
  do
    get-iso-date "$input_date"
    echo " - $post_language"
  done < <(cat <<'EOF'
1 de Janeiro de 2020
31 de Dezembro de 2021
December 12, 2022
EOF
)
}
