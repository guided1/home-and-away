#!/usr/bin/env bash

myMacAddress=`cat ../config/settings.ini | awk '/mac_address/{print $2}'`;

function amIHome() {
    threshold=`cat ../config/settings.ini | awk '/^threshold/{print $2}'`
    resetThreshold=`cat ../config/settings.ini | awk '/^reset_threshold/{print $2}'`

    isHome=$1;
    lastRun=`cat ../log/log.txt | awk '/LASTRUN/{print $2}'`
    currentTime=$(date +%s);
    updateLastRunTime

    if [ $((currentTime-lastRun)) -gt ${resetThreshold} ]; then
        resetLog ${currentTime}
    fi

    homeTheWholeTime=`cat ../log/log.txt | awk '/CURRENTLYHOME/{print $2}'`

#    echo "is home ${isHome}";
#    echo "was home ${homeTheWholeTime}";


    if [ ${isHome} = true ]; then
        # Tell the log I am home
        logTime ${isHome} ${currentTime}
        # Network says I am home - have I been here the whole time?
        if [ ${homeTheWholeTime} -le 0 ]; then
            # Log says I've not been at home - I have just come home
            # run action
            actuallyHome
        else
            ./still-home-controller.sh
        fi
    else
        # Network says I am away - have I been away the whole time?
        if [ ${homeTheWholeTime} -eq -1 ]; then
            # Log says it that it ain't no snitch and it ain't telling us shit - So we don't tell the log shit neither
            # Wait till I've been away for more than threshold to run
            lastAway=`cat ../log/log.txt | awk '/LASTAWAY/{print $2}'`
            if [ $((currentTime-lastAway)) -gt ${threshold} ]; then
                logTime ${isHome} ${currentTime}
                actuallyAway
            else
                ./might-be-away-controller.sh
            fi
        elif [ ${homeTheWholeTime} -eq 1 ]; then
            # Tell the log I am away
            logTime ${isHome} ${currentTime}
            # Log says I was just here a second ago - Wait till I've not been seen for longer than threshold to run
            lastHome=`cat ../log/log.txt | awk '/LASTHOME/{print $2}'`
            if [ $((currentTime-lastHome)) -gt ${threshold} ]; then
                actuallyAway
            else
                ./might-be-away-controller.sh
            fi
        else
            logTime ${isHome} ${currentTime}
            ./still-away-controller.sh
        fi

    fi
}



function resetLog {
    currentTime=$1;
#    echo "resetting log at ${currentTime}"
    sed -i "s/\(TIME: \).*/\1${currentTime}/" ../log/log.txt
    setHome "-1"
}

function updateLastRunTime {
    sed -i "s/^\(LASTRUNTIME: \).*/\1${currentTime}/" ../log/log.txt
}

# Logs the last time we were home, away and last time the script was run
function logTime {
    isHome=$1;
    currentTime=$2;
    logLine="LASTAWAYTIME"
    if [ ${isHome} = true ]; then
        logLine="LASTHOMETIME"
    fi
#    echo "logging ${isHome} at ${currentTime}";
    sed -i "s/^\(${logLine}: \).*/\1${currentTime}/" ../log/log.txt
}


function actuallyHome {
    setHome "1"
    ./home-controller.sh
}

function actuallyAway {
    setHome "0"
    ./away-controller.sh
}

function setHome {
    value=$1
#    echo "setting home with value ${value}";
    sed -i "s/^\(CURRENTLYHOME: \).*/\1${value}/" ../log/log.txt
}

isHome=false;

while read -r networkMacAddress; do
    if [ ${networkMacAddress} = ${myMacAddress} ]; then
        isHome=true;
    fi
done

amIHome ${isHome}

