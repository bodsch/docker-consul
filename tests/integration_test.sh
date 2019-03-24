#!/bin/bash

CURL=$(which curl 2> /dev/null)
NC=$(which nc 2> /dev/null)
NC_OPTS="-z"


inspect() {

  echo ""
  echo "inspect needed containers"
  for d in $(docker ps | tail -n +2 | awk  '{print($1)}')
  do
    # docker inspect --format "{{lower .Name}}" ${d}
    c=$(docker inspect --format '{{with .State}} {{$.Name}} has pid {{.Pid}} {{end}}' ${d})
    s=$(docker inspect --format '{{json .State.Health }}' ${d} | jq --raw-output .Status)

    printf "%-40s - %s\n"  "${c}" "${s}"
  done
}


ui_request() {

  curl \
    --silent \
    --head \
    --location \
    http://localhost/consul
}

api_request() {

  node=$1

  code=$(curl \
    --silent \
    --location \
    http://localhost/v1/health/node/${node})

  if [[ $? -eq 0 ]]
  then
    echo -n "api request are successfull"

    node=$(echo "${code}" | jq --raw-output .[].Node)
    status=$(echo "${code}" | jq --raw-output .[].Status)
    output=$(echo "${code}" | jq --raw-output .[].Output)

    echo "  ${node} ${status} ${output}"
  else
    echo ${code}
    echo "api request failed"
    exit 1
  fi
}

inspect

ui_request

api_request consul-master
api_request consul2
api_request consul3

exit 0
