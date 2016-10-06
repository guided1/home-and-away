#!/usr/bin/env bash

nmap -sn 192.168.0.0/24 | sed -n '/MAC/p' | awk '{print $3}' | ../controller/controller.sh
