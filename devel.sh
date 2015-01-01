#!/bin/bash

WORK="$HOME/Dev/aapp"
SERVER="$WORK/server"
APP="$WORK/app"

LOG_SERV="$WORK/server.log"
LOG_APP="$WORK/app.log"


rm $LOG_SERV 2>/dev/null
rm $LOG_APP 2>/dev/null

cd $SERVER
python manage.py runserver 192.168.10.212:8000 >> $LOG_SERV 2>$LOG_SERV &

cd $APP
phonegap serve >> $LOG_APP &
