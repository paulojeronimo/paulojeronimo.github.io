# vim: syntax=bash

config=$src_dir/build.conf
[ -r "$config" ] || config=$config.sample
source "$config"
source $src_dir/functions.sh
