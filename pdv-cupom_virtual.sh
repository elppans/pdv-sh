#!/bin/bash

sleep 55
setsid nohup xterm -d :0 -geometry 58x46+800+0 -fg black -bg Cornsilk1 -e sh -c "sleep 5 ; tail -f /Zanthus/Zeus/pdvJava/Q91Q0001.XXX" &>>/dev/null &
