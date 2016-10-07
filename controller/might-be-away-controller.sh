#!/usr/bin/env bash


script=`cat ../config/settings.ini | awk '/^might_be_away:/ {print $2}'`;

if [ ! -z "${script}" ]; then
    ../scripts/${script}
fi

