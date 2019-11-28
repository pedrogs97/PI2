#!/bin/bash
BASE_PATH=$HOME
FULL_PATH="${BASE_PATH}/pi/"
CPU_PATH="${FULL_PATH}info"
CPU_PATH_AUX="${FULL_PATH}info-aux"


qualquer=$(cat /proc/cpuinfo | grep --max-count=4 -i 'cpu mhz' > ${CPU_PATH_AUX})

i=1
while IFS= read -r line
do
    echo ${CPU_PATH}${i}
    echo ${i}
    echo ${line} > ${CPU_PATH}${i}
    i=$(( i+1 ))
done < ${CPU_PATH_AUX}