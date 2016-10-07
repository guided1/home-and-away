#!/usr/bin/env bash

script=`cat ../config/settings.ini | awk '/^might-be-away:/ {print $2}'`;

if [ ! -z "${script}" ]; then
    ../scripts/${script}
fi

