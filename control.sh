#!/bin/bash

function try_stop(){
  echo "stopping FRONTEND server..."
  FE_PID=$(ps aux | grep phonegap | grep -v grep | awk '{print $2}')
  FE_PREV=$(cat $FE_LCK 2>/dev/null)
  if [[ "$FE_PID" == "" ]]; then
    echo "-- NO Frontend server running"
  else
    kill $FE_PID
    kill $FE_PREV 2>/dev/null
    echo "-- Frontend server, PIDs" $FE_PID "(previous: "$FE_PREV") killed."
  fi
  rm $FE_LOG 2>/dev/null
  rm $FE_LCK 2>/dev/null

  echo "stopping BACKEND server..."
  BE_PID=$(ps aux | grep manage.py | grep -v grep | awk '{print $2}')
  BE_PREV=$(cat $BE_LCK 2>/dev/null)
  if [[ "$BE_PID" == "" ]]; then
    echo "-- NO Backend server running"
  else
    kill $BE_PID
    kill $FE_PREV 2>/dev/null
    echo "-- Backend server, PID" $BE_PID "(previous: "$BE_PREV") killed."
  fi
  rm $BE_LOG 2>/dev/null
  rm $BE_LCK 2>/dev/null

}

function try_start(){
  echo
  BE_PREV=$(cat $BE_LCK 2>/dev/null) 
  if [ ! -e $BE_LCK ] || [ "$BE_PREV" == "" ]; then
    rm $BE_LOG 2>/dev/null
    rm $BE_LCK 2>/dev/null
    cd $BE_FOLDER
    python manage.py runserver "$BE_SERVER" >> $BE_LOG 2>$BE_LOG &
    echo $! > $BE_LCK
    echo "Backend started, with PID "$(cat $BE_LCK)
  else
    echo "ERROR! Either another Backend is running, or the Lockfile is not up-to-date"
    echo "------- Running Backends: --------------"
    ps aux | grep manage.py | grep -v grep
    echo "----------------------------------------"
    echo 
    echo "Option A) If no result was shown above, feel free to run:"
    echo "rm "$BE_LCK
    echo "Option B) Just run:"
    echo $0" stop"
    echo 
  fi

  FE_PREV=$(cat $FE_LCK 2>/dev/null)
  if [ ! -e $FE_LCK ] || [ "$FE_PREV" == "" ]; then
    rm $FE_LOG 2>/dev/null
    cd $FE_FOLDER
    phonegap serve --no-autoreload >> $FE_LOG 2>$FE_LOG &
    echo $! > $FE_LCK
    echo "Frontend started, with PID "$(cat $FE_LCK)
  else
    echo "ERROR! Either another Frontend is running, or the Lockfile is not up-to-date"
    echo "------- Running Frontends: --------------"
    ps aux | grep phonegap | grep -v grep
    echo "----------------------------------------"
    echo 
    echo "If no result was shown above, feel free to run:"
    echo "rm "$FE_LCK
    echo "Option B) Just run:"
    echo $0" stop"
  fi
  echo
}

BE_SERVER="192.168.10.212:8000"
FE_SERVER="192.168.10.212:3000"

WORK_FOLDER="$HOME/Dev/aapp"

BE_FOLDER="$WORK_FOLDER/server"
FE_FOLDER="$WORK_FOLDER/app"

BE_LCK="$WORK_FOLDER/backend.pid"
FE_LCK="$WORK_FOLDER/frontend.pid"

BE_LOG="$WORK_FOLDER/backend.log"
FE_LOG="$WORK_FOLDER/frontend.log"

case $1 in
  stop)
    try_stop
  ;;
  restart)
    try_stop
    try_start
  ;;
  start|"")
    try_start
  ;;
esac 

