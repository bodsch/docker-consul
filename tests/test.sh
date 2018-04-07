#!/bin/bash

CURL=$(which curl 2> /dev/null)
NC=$(which nc 2> /dev/null)
NC_OPTS="-z"


inspect() {

  echo "inspect needed containers"
  for d in consul-master consul2 consul3
  do
    # docker inspect --format "{{lower .Name}}" ${d}
    docker inspect --format '{{with .State}} {{$.Name}} has pid {{.Pid}} {{end}}' ${d}
  done
}

api_request() {

  node=$1

  code=$(curl \
    --silent \
    http://localhost:8500/v1/health/node/${node})

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
  fi

}

inspect

api_request consul-master
api_request consul2
api_request consul3

exit 0
