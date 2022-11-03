#!/usr/bin/env bash
set -eo pipefail
port=${port:-5000}

cd $(dirname $0)
if [[ $# = 1 && $1 = stop ]]
then
  if [ -f serve.pid ]
  then
    if kill $(cat serve.pid)
    then
      rm -f serve.pid
    fi
  else
    echo "File serve.pid not found!"
  fi
  exit 0
fi
ruby -run -e httpd .. -p $port &> serve.log &
echo $! > serve.pid
