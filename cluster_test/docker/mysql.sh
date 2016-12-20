#!/bin/bash

# Get real haproxy host port.
addr=$(docker-compose port haproxy 4000)
host_port=(${addr//:/ })

# If we don't pass -h or --host, use default.
host="127.0.0.1"

args=("$@")
args+=("-P${host_port[1]}")

for i in "$@"
do
    case $i in
        -h*|--host=*)
        host=""
        ;;
        *)     
        ;;
    esac
done

if [ ! -z $host ]; then
    args+=("-h$host")
fi

mysql "${args[@]}"