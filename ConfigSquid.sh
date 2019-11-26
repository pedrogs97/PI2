#!/bin/bash

STATUS="$(dpkg -s squid3 | grep -i status)"
if [ ! "Status: install ok installed" == "$STATUS" ]
then
    `sudo apt install squid3`
else
    dialog  \
        --title 'Instalação'    \
        --msgbox 'Squid já foi instalado.'  \
        25 25
fi

sleep(2)