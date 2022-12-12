#!/usr/bin/env bash

# https://github.com/yt-dlp/yt-dlp/wiki/Installation#with-pip
#yes | pkg install python
#pip install -U yt-dlp

# https://github.com/termux/termux-docker
query='# yt-dlp'
hosts=/system/etc/static-dns-hosts.txt
if ! grep -qe "^$query$" $hosts
then
	cat <<-EOF>>$hosts

	$query
	www.youtube.com
	rr8---sn-b8u-cnc6.googlevideo.com
	EOF
	/system/bin/update-static-dns
else
	echo static-dns for yt-dlp is already configured!
	exit
fi

if yt-dlp -F 'https://www.youtube.com/watch?v=he_o9LmXYwg'
then
	echo static-dns for yt-dlp was successfuly configured!
fi
