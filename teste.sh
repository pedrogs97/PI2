#!/bin/bash
DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=0
WIDTH=0

BASE_PATH=$HOME
FULL_PATH="${BASE_PATH}/pi/"
CPU_PATH="${FULL_PATH}info"
MEM_PATH="${FULL_PATH}mem"
BAR_PATH="${FULL_PATH}bar"


if [ ! -d ${FULL_PATH} ]
then
	clear
        sudo mkdir ${FULL_PATH}
fi


Menu_Configuracao(){
while true; do
	exec 3>&1
	selection=$(dialog \
		--backtitle "Verifica" \
		--title "Menu" \
		--clear \
		--cancel-label "Voltar" \
		--menu "Selecione uma opção:" $HEIGHT $WIDTH 4 \
		"1" "Informações da CPU" \
		"2" "Informações da Memoria" \
		"3" "Informações do Barramento" \
       		"4" "Informações da GPU" \
		2>&1 1>&3)
	exit_status=$?
	exec 3>&-
	case $exit_status in
		$DIALOG_CANCEL)
		echo "Inicio do Programa."
		Menu_Configuracao
		exit
		;;
	$DIALOG_ESC)
		clear
		echo "programa abortado.">&2
		exit 1
		;;
	esac
	case $selection in
		0 )
			clear
			echo "programa encerrado"
			;;
		1 )
			if [ -e ${CPU_PATH} ]
               	  	then
            			clear
                		rm ${CPU_PATH}
            	   	fi
            		echo `cat /proc/cpuinfo | grep -i 'cpu mhz'` >> ${CPU_PATH}
            		echo `cat /proc/cpuinfo | grep -i 'model name'` >> ${CPU_PATH}
            		echo `cat /proc/cpuinfo | grep -i 'cpu cores'` >> ${CPU_PATH}
            		echo `cat /proc/cpuinfo | grep -i 'vendor_id'` >> ${CPU_PATH}
            		echo `cat /proc/cpuinfo | grep -i 'cpu family'` >> ${CPU_PATH}
                	dialog --title 'CPU' \
                    	--textbox ${CPU_PATH} \
                	0 0
            		;;
		2 ) 
			if [ -e ${MEM_PATH}]
            		then
            			clear
                		rm ${MEM_PATH}
            		fi
			echo `cat /proc/meminfo | grep -i 'memtotal'` >> ${MEM_PATH}
			echo `cat /proc/meminfo | grep -i 'memfree'` >> ${MEM_PATH}
			echo `cat /proc/meminfo | grep -i -w 'cached'` >> ${MEM_PATH}
			echo `cat /proc/meminfo | grep -i 'swaptotal'` >> ${MEM_PATH}
			echo `cat /proc/meminfo | grep -i 'swapfree'` >> ${MEM_PATH}
                	dialog --title 'RAM' \
                    	--textbox ${MEM_PATH} \
                	0 0
		   	;;
		3 ) 
			if [ -e ${BAR_PATH} ]
			then
				clear
				rm ${BAR_PATH}
			fi
			#Versão dos USB`s
			echo `cat /proc/devices | grep -i 'bcdusb'` >> ${BAR_PATH}
			#Caso tenha um dispositivo motorola conectado a alguma USB exibe algumas informações
			echo `cat /proc/devices` >> ${BAR_PATH}
			#Informações da placa de video
			echo `lspci | grep -i 'VGA'` >> ${BAR_PATH}
			#Detalhes da Fabricação do Audio
			echo `lspci -v | grep -i 'audio'` >> ${BAR_PATH}
			#Deixar mais legível o lsusb
			echo `lsusb -v | egrep '\<(Bus|iProduct|bDeviceClass|bDeviceProtocol)'` >> ${BAR_PATH}
			dialog --title 'Barramento' \
			--textbox ${BAR_PATH}\
			0 0
			;;	  
   		
	esac
done			
}

 Menu_Configuracao
