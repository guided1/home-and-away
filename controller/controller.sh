#!/usr/bin/env bash

myMacAddress="";

function amIHome() {
    currentlyHome=$1;

    if [ ${currentlyHome} = true ]; then
        echo "home";
        # When was the last time I was away
        # If it was longer than 10 minutes ago - I have come home - call home.sh
    else
        echo "away";
        # When was the last time I was home
        # If it was longer than 10 minutes ago - I have come home - call away.sh
    fi
}

currentlyHome=false;

while read -r networkMacAddress; do
    if [ ${networkMacAddress} = ${myMacAddress} ]; then
        currentlyHome=true;
    fi
done

amIHome ${currentlyHome}

