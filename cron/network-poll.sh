#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${DIR}/../controller" && nmap -sn 192.168.0.0/24 | sed -n '/MAC/p' | awk '{print $3}' | ./main-controller.sh
