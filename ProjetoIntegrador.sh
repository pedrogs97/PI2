#!/bin/bash

DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=0
WIDTH=0

BASE_PATH=$HOME
FULL_PATH="${BASE_PATH}/pi/"
STATUS_UFW="${FULL_PATH}status"
CPU_PATH="${FULL_PATH}info"
CPU_PATH_AUX="${FULL_PATH}info-aux"
MEM_PATH="${FULL_PATH}mem"
BAR_PATH="${FULL_PATH}bar/"
BAR_PLUS_PATH="${BAR_PATH}bar"
USB_PATH="${BAR_PATH}usb"
SATA_PATH="${BAR_PATH}sata"
PCI_PATH="${BAR_PATH}pci"
MEMORY_PATH="${BAR_PATH}memory"
DISPLAY_PATH="${BAR_PATH}display"
NET_PATH="${BAR_PATH}net"
ETH_PATH="${BAR_PATH}eth"
VGA_PATH="${BAR_PATH}vga"
AUDIO_PATH="${BAR_PATH}audio"
QLQ_PATH="${FULL_PATH}lsdev"
GRAPH_PATH="${FULL_PATH}graph"
TCP_PATH="${FULL_PATH}dump"
SQUID_PATH="${FULL_PATH}squid-pi"
BLOCK_SITES="/etc/squid/sites_proibidos"


#----Criação de Arquivos----#
CreateSquidFile(){
	if [ -e ${SQUID_PATH} ]
	then
		clear
		rm ${SQUID_PATH}
	fi

	echo "	# Configuração Squid
	# Configurado por: Equipe 4 - Barramento

	# Mensagens de erro em Português
	error_directory /usr/share/squid/errors/Portuguese
	#---- Auth ----#
	auth_param basic program /usr/lib/squid3/basic_ncsa_auth /etc/squid/passwd
	auth_param basic children 5 
	auth_param basic realm Proxy PI - Login
	auth_param basic credentialsttl 2 hours
	auth_param basic casesensitive off
	#--- ACL ----#
	#__Default__
	acl localnet src 0.0.0.1-0.255.255.255	# RFC 1122 "this" network (LAN)
	acl localnet src 10.0.0.0/8		# RFC 1918 local private network (LAN)
	acl localnet src 100.64.0.0/10		# RFC 6598 shared address space (CGN)
	acl localnet src 169.254.0.0/16 	# RFC 3927 link-local (directly plugged) machines
	acl localnet src 172.16.0.0/12		# RFC 1918 local private network (LAN)
	acl localnet src 192.168.0.0/16		# RFC 1918 local private network (LAN)
	acl localnet src fc00::/7       	# RFC 4193 local private network range
	acl localnet src fe80::/10      	# RFC 4291 link-local (directly plugged) machines

	acl SSL_ports port 443
	acl Safe_ports port 80		# http
	acl Safe_ports port 21		# ftp
	acl Safe_ports port 443		# https
	acl Safe_ports port 70		# gopher
	acl Safe_ports port 210		# wais
	acl Safe_ports port 1025-65535	# unregistered ports
	acl Safe_ports port 280		# http-mgmt
	acl Safe_ports port 488		# gss-http
	acl Safe_ports port 591		# filemaker
	acl Safe_ports port 777		# multiling http
	acl CONNECT method CONNECT
	#__Authorial__
	acl block_sites url_regex -i '/etc/squid/sites_proibidos'
	acl users proxy_auth '/etc/squid/users'
	#---- http_access ----#
	#__Default__
	http_access deny !Safe_ports
	http_access deny CONNECT !SSL_ports
	http_access allow localhost manager
	http_access deny manager
	#__Authoral__
	http_access deny block_sites
	http_access allow users all


	#---- Others ----#
	include /etc/squid/conf.d/*

	# Example rule allowing access from your local networks.
	# Adapt localnet in the ACL section to list your (internal) IP networks
	# from where browsing should be allowed
	#http_access allow localnet
	http_access allow localhost

	# And finally deny all other access to this proxy
	

	# Squid normally listens to port 3128
	http_port 3128

	# Leave coredumps in the first cache dir
	coredump_dir /var/spool/squid

	#
	# Add any of your own refresh_pattern entries above these.
	#
	refresh_pattern ^ftp:		1440	20%	10080
	refresh_pattern ^gopher:	1440	0%	1440
	refresh_pattern -i (/cgi-bin/|\?) 0	0%	0
	refresh_pattern \/(Packages|Sources)(|\.bz2|\.gz|\.xz)$ 0 0% 0 refresh-ims
	refresh_pattern \/Release(|\.gpg)$ 0 0% 0 refresh-ims
	refresh_pattern \/InRelease$ 0 0% 0 refresh-ims
	refresh_pattern \/(Translation-.*)(|\.bz2|\.gz|\.xz)$ 0 0% 0 refresh-ims
	# example pattern for deb packages
	#refresh_pattern (\.deb|\.udeb)$   129600 100% 129600
	refresh_pattern .		0	20%	4320" >> ${SQUID_PATH}
}

CreateCPUInfoFile(){
	if [ -e ${CPU_PATH} ]
	then
		clear
		rm ${CPU_PATH}
	fi
	mhz=$(cat /proc/cpuinfo | grep --max-count=4 -i 'cpu mhz' > ${CPU_PATH_AUX})
	i=1
	while IFS= read -r line
	do
		if [ -e ${CPU_PATH}${i} ]
		then
			`sudo rm ${CPU_PATH}${i}`
		fi
		echo ${line} >> ${CPU_PATH}${i}
		i=$(( i+1 ))
	done < ${CPU_PATH_AUX}

	model=$(cat /proc/cpuinfo | grep --max-count=4 -i 'model name' > ${CPU_PATH_AUX})
	i=1
	while IFS= read -r line
	do
		echo ${line} >> ${CPU_PATH}${i}
		i=$(( i+1 ))
	done < ${CPU_PATH_AUX}

	core=$(cat /proc/cpuinfo | grep --max-count=4 -i 'cpu cores' > ${CPU_PATH_AUX})
	i=1
	while IFS= read -r line
	do
		echo ${line} >> ${CPU_PATH}${i}
		i=$(( i+1 ))
	done < ${CPU_PATH_AUX}

	id=$(cat /proc/cpuinfo | grep --max-count=4 -i 'vendor_id' > ${CPU_PATH_AUX})
	i=1
	while IFS= read -r line
	do
		echo ${line} >> ${CPU_PATH}${i}
		i=$(( i+1 ))
	done < ${CPU_PATH_AUX}

	family=$(cat /proc/cpuinfo | grep --max-count=4 -i 'cpu family' > ${CPU_PATH_AUX})
	i=1
	while IFS= read -r line
	do
		echo ${line} >> ${CPU_PATH}${i}
		i=$(( i+1 ))
	done < ${CPU_PATH_AUX}
	i=1
	while true
	do
		if [ -e ${CPU_PATH}${i} ]
		then
			echo "CPU ${i}" >> ${CPU_PATH}
			cat=$(cat ${CPU_PATH}${i} >> ${CPU_PATH})
			i=$(( i+1 ))
		else
			break
		fi
	done
}

InputACL(){
	dialog \
		--title 'Configuração' \
		--yesno '\nDeseja adicionar um nova ACL?\n' \
		0 0
	if [ $? = 0 ]
	then
		INPUT=$(dialog \
					--stdout \
					--title 'Site para ser bloqueado na ACL.' \
					--inputbox 'Digite o site:'\
					0 0 )

		echo "${INPUT}" | sudo tee -a /etc/squid/sites_proibidos
		CreateSquidFile
		ConfigSquid
	fi
}
#----Configurações----# 
InstallPackages(){
	STATUS_SQUID="$(dpkg -s squid3 | grep -i 'status')"
	STATUS_APACHE="$(dpkg -s apache2 | grep -i 'status')"
	STATUS_APACHE_UTILS="$(dpkg -s apache2-utils | grep -i 'status')"
	if [[ ! "Status: install ok installed" == *"$STATUS_SQUID"* ]]
	then
		`sudo apt install -y squid3`
		dialog  \
			--title 'Instalação'    \
			--msgbox 'Squid instalado com sucesso!'  \
			0 0
		clear
	else
		dialog  \
			--title 'Instalação'    \
			--msgbox 'Squid já foi instalado.'  \
			0 0
		clear
	fi
	if [[ ! "Status: install ok installed" == *"$STATUS_APACHE"* ]]
	then
		`sudo apt install -y apache2`
		dialog  \
			--title 'Instalação'    \
			--msgbox 'Apache instalado com sucesso!'  \
			0 0
	else
		dialog  \
			--title 'Instalação'    \
			--msgbox 'Apache já foi instalado.'  \
			0 0
	fi
	if [[ ! "Status: install ok installed" == *"$STATUS_APACHE_UTILS"* ]]
	then
		`sudo apt install -y apache2-utils`
		dialog  \
			--title 'Instalação'    \
			--msgbox 'Apache2-utils instalado com sucesso!'  \
			0 0
	else
		dialog  \
			--title 'Instalação'    \
			--msgbox 'Apache2-utils já foi instalado.'  \
			0 0
	fi
}

ConfigSquid(){
	`sudo cp /etc/squid/squid.conf /etc/squid/squid-ori` 
	`sudo cp ${SQUID_PATH} /etc/squid/squid.conf`
	CONFIG="$(sudo squid -k reconfigure | grep -i fatal)" 
	if [ "" == "$CONFIG" ]
	then
		`service squid restart`
		`/etc/init.d/squid restart`
	else
		dialog  \
			--title 'Aviso'    \
			--msgbox 'Não foi possível configurar o SQUID.'  \
			0 0
		return
	fi
}
#----Menus---#
Menu_Install(){
	while true; do
		STATUS_UNRAR="$(dpkg -s unrar | grep -i status)"
		STATUS_VIM="$(dpkg -s vim| grep -i status)"
		exec 3>&1
		selection=$(dialog \
			--backtitle "Instalação/Desinstalação de Programas" \
			--title "Programas" \
			--clear \
			--cancel-label "Voltar" \
			--menu "Selecione uma opção:" $HEIGHT $WIDTH 4 \
			"1" "Instalar VIM" \
			"2" "Instalar UnRAR" \
			"3" "Desinstalar VIM" \
			"4" "Desinstalar UnRAR" \
			2>&1 1>&3)
		exit_status=$?
		exec 3>&-
		case $exit_status in
			$DIALOG_CANCEL)
			echo "MenuPrincipal."
			return
			;;
		$DIALOG_ESC)
			clear
			echo "programa abortado.">&2
			return
			;;
		esac
		case $selection in
			0 )
				clear
				echo "programa encerrado"
				return
				;;
			1 )	#Instalar vim
				if [ ! "Status: install ok installed" == "$STATUS_VIM" ]
				then
					`sudo apt install -y vim`
					clear
					dialog  \
						--title 'Instalação'    \
						--msgbox 'VIM instalado com sucesso!'  \
						0 0
					clear
				else
					dialog  \
						--title 'Instalação'    \
						--msgbox 'VIM já foi instalado.'  \
						0 0
					clear
				fi
				;;
			
			2 ) #Instalar unrar
				if [ ! "Status: install ok installed" == "$STATUS_UNRAR" ]
				then
					`sudo apt install -y unrar`
					clear
					dialog  \
						--title 'Instalação'    \
						--msgbox 'UnRAR instalado com sucesso!'  \
						0 0
					clear
				else
					dialog  \
						--title 'Instalação'    \
						--msgbox 'UnRAR já foi instalado.'  \
						0 0
					clear
				fi
				;;
			3 ) #Desinstalar vim
				if [ "Status: install ok installed" == "$STATUS_VIM" ]
				then
					`sudo apt remove -y vim`
					clear
					`sudo apt autoremove -y`
					clear
					dialog  \
						--title 'Desinstalação'    \
						--msgbox 'VIM desinstalado com sucesso!'  \
						0 0
					clear
				else
					dialog  \
						--title 'Desinstalação'    \
						--msgbox 'VIM não foi instalado.'  \
						0 0
					clear
				fi	
				;;

			4 )	#Desinstalar unrar
				if [ "Status: install ok installed" == "$STATUS_UNRAR" ]
				then
					`sudo apt remove -y unrar`
					clear
					`sudo apt autoremove -y`
					clear
					dialog  \
						--title 'Desinstalação'    \
						--msgbox 'UnRAR desinstalado com sucesso!'  \
						0 0
					clear
				else
					dialog  \
						--title 'Desinstalação'    \
						--msgbox 'UnRAR não foi instalado.'  \
						0 0
					clear
				fi		
				;;
			esac
		done			
}

Menu_ConfigServer(){
	while true; do
		exec 3>&1
		selection=$(dialog \
			--backtitle "Configuração da Maquina" \
			--title "Opcões" \
			--clear \
			--cancel-label "Voltar" \
			--menu "Selecione uma opção:" $HEIGHT $WIDTH 4 \
			"1" "Configuração de Proxy" \
			"2" "Configuração de Firewall" \
			"3" "Capturar Trafego" \
			2>&1 1>&3)
		exit_status=$?
		exec 3>&-
		case $exit_status in
			$DIALOG_CANCEL)
			return
			;;
		$DIALOG_ESC)
			clear
			return
			;;
		esac
		case $selection in
			0 )
				clear
				return
				;;
			1 )
				clear
				InstallPackages
				InputACL
				dialog  \
					--title 'Aviso'    \
					--msgbox 'Proxy configurado com sucesso.'  \
					0 0
				;;
			2 ) 
				while true; do
					exec 3>&1
					selection=$(dialog \
						--title "Opcões" \
						--cancel-label "Voltar" \
						--menu "Selecione uma opção:" $HEIGHT $WIDTH 4 \
						"1" "Status do Firewall" \
						"2" "Ativar/Desativar o Firewall" \
						"3" "Aplicar uma regra a uma porta" \
						"4" "Listar Regras"	\
						2>&1 1>&3)
					exit_status=$?
					exec 3>&-
					case $exit_status in
						$DIALOG_CANCEL)
						echo "MenuPrincipal."
						return
						;;
					$DIALOG_ESC)
						clear
						echo "programa abortado.">&2
						return
					esac
					case $selection in
						0 )
							clear
							return
							;;
						1 )
							S=$(`sudo ufw status verbose > ${STATUS_UFW}`)
							dialog 							\
								--title 'Status do Firewall' \
								--textbox ${STATUS_UFW} 		 \
								0 0
							;;
						2 )
							if grep -q "inactive" "$STATUS_UFW"
							then
								dialog	\
									--title 'Aviso'	\
									--yesno '\nDeseja ativar o firewall?\n'	\
									0 0 \
									&& `sudo ufw enable`
									ShowEnableFW \
									|| clear
							elif grep -q "active" "$STATUS_UFW"
							then
								dialog	\
									--title 'Aviso'	\
									--yesno '\nDeseja desativar o firewall?\n'	\
									0 0 \
									&& `sudo ufw disable`
									ShowDisableFW \
									|| clear
							else
								dialog	\
									--title 'Aviso' \
									--msgbox 'UFW não instalado!'	\
									0 0
							fi
							;;
						3 )	
							Menu_FW
							;;
						4 ) 
							S=$(`sudo ufw status numbered > ${STATUS_UFW}`)
							dialog 							\
								--title 'Status do Firewall' \
								--textbox ${STATUS_UFW} 		 \
								0 0
							;;

					esac
				done
				;;
			3 ) 
				echo $(date) > ${TCP_PATH}
				if sudo tcpdump -i wlp2s0 -qntt -s0 -c10 >> ${TCP_PATH}
				then
					dialog \
						--title "Ultimos 10 pacotes capturados:" \
						--textbox ${TCP_PATH} \
						0 0 
				fi
				;;	
		esac
		done			
}

Menu_FW(){
	while true; do
		exec 3>&1
		selection=$(dialog \
			--backtitle "Configuração do Firewall" \
			--title "Opcões" \
			--cancel-label "Voltar" \
			--menu "Selecione uma opção:" $HEIGHT $WIDTH 2 \
			"1" "Allow" \
			"2" "Deny" \
			2>&1 1>&3)
		exit_status=$?
		exec 3>&-
		case $exit_status in
			$DIALOG_CANCEL)
			clear
			return
			;;
		$DIALOG_ESC)
			clear
			return
			;;
		esac
		case $selection in
			0 )
				return
				;;
			1 )
				port=$(dialog --stdout --inputbox 'Digite [<porta>/<opcional: protocolo>]:' 0 0 )
				`sudo ufw allow ${port}`
				dialog	\
					--title 'Aviso' \
					--msgbox 'Regra ativada!'	\
					0 0
				;;
			2 )
				port=$(dialog --stdout --inputbox 'Digite [<porta>/<opcional: protocolo>]:' 0 0 )
				`sudo ufw deny ${port}`
				dialog	\
					--title 'Aviso' \
					--msgbox 'Regra ativada!'	\
					0 0
				;;
		esac
	done
}

Menu_InfoComputer(){
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
			return
			;;
		$DIALOG_ESC)
			clear
			return
			;;
		esac
		case $selection in
			0 )
				Menu
				;;

			1 )
				CreateCPUInfoFile
				dialog --title 'CPU' \
					--textbox ${CPU_PATH} \
				0 0
				;;
			2 )
				if [ -e ${MEM_PATH} ]
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
				if [ ! -d ${BAR_PATH} ]
				then
					clear
					mkdir ${BAR_PATH}
				fi
				#Versão dos USB`s
				# `cat /proc/devices | grep -i 'bcdusb' >> ${BAR_PATH}` 
				# #Caso tenha um dispositivo motorola conectado a alguma USB exibe algumas informações
				# `cat /proc/devices >> ${BAR_PATH}`
				#Informações da placa de video
				`lspci | grep -i 'usb' > ${USB_PATH}`
				`lspci | grep -i 'sata' > ${SATA_PATH}`
				`lspci | grep -i 'pci' > ${PCI_PATH}`
				`lspci | grep -i 'memory' > ${MEMORY_PATH}`
				`lspci | grep -i 'display' > ${DISPLAY_PATH}`
				`lspci | grep -i 'network' > ${NET_PATH}`
				`lspci | grep -i 'ethernet' > ${ETH_PATH}`
				`lspci | grep -i 'VGA' > ${VGA_PATH}`
				#Detalhes da Fabricação do Audio
				`lspci -v | grep -i 'audio' > ${AUDIO_PATH}` 

				#Deixar mais legível o lsusb
				`lsusb -v | egrep '\<(Bus|iProduct|bDeviceClass|bDeviceProtocol)' >> ${USB_PATH}`
				#Detalhes sobre IRQS
				echo 'Device		IRQ		I/O Port' > ${BAR_PLUS_PATH}
				echo 'GPU:' >> ${BAR_PLUS_PATH}
				`lsdev | grep -i 'amdgpu' >> ${BAR_PLUS_PATH}`
				echo 'Rede Wireless:' >> ${BAR_PLUS_PATH}
				`lsdev | grep -i 'ath9k' >> ${BAR_PLUS_PATH}` 
				echo 'Realm Time Clock:' >> ${BAR_PLUS_PATH}
				`lsdev | grep -i 'rtc0' >> ${BAR_PLUS_PATH}` 
				echo 'DMA RAM:' >> ${BAR_PLUS_PATH}
				`lsdev | grep -i 'dmar0' >> ${BAR_PLUS_PATH}`
				`lsdev | grep -i 'dmar1' >> ${BAR_PLUS_PATH}`
				echo 'Rede Wired:' >> ${BAR_PLUS_PATH}
				`lsdev | grep -i 'enp3s0' >> ${BAR_PLUS_PATH}` 
				echo 'Módulo de configuração do kernel:' >> ${BAR_PLUS_PATH}
				`lsdev | grep -i 'mei_me' >> ${BAR_PLUS_PATH}`

				FILE=$(dialog \
						--stdout \
						--title 'Escolha a informação'  \
						--fselect ${BAR_PATH} \
						7 0)
				if [ $? != $DIALOG_CANCEL ]
				then
					Show_File ${FILE}
				fi
				
				
				;;	  
			4 )
				`sudo lshw -C display > ${GRAPH_PATH}` 
				dialog \
					--title 'Informação Gráfica' \
					--textbox ${GRAPH_PATH} \
					0 0
				;;
			
		esac
		done			
}

Menu(){
	if [ ! -d ${FULL_PATH} ]
	then
		clear
		mkdir ${FULL_PATH}
	fi 

	while true; do
	exec 3>&1
	selection=$(dialog \
		--backtitle "Opções do Sistemas" \
		--title "Menu" \
		--clear \
		--cancel-label "Sair" \
		--menu "Selecione uma opção:" $HEIGHT $WIDTH 4 \
		"1" "Verificar especificações do computador." \
		"2" "Opções do servidor." \
        "3" "Instalar/Desinstalar Programas." \
		2>&1 1>&3)
	exit_status=$?
	exec 3>&-
	case $exit_status in
		$DIALOG_CANCEL)
		clear
		echo "programa encerrado."
		return
		;;
	$DIALOG_ESC)
		clear
		echo "programa abortado.">&2
		return
		;;
	esac
	case $selection in
		0 )
		   clear
		   echo "programa encerrado"
		   return
		   ;;
		1 )
			dialog --title 'Informações' --infobox 'Buscando informações sobre a máquina...'\
			0 0
			sleep 2
			Menu_InfoComputer
			;;
		2 ) 
			Menu_ConfigServer
			;;
        3 ) 
		  	Menu_Install
		   	;;
		esac
    done		
}
#----Telas----#
Start_Program(){
	dialog	\
	--title 'ATENÇÂO!'	\
	--yesno	'\nPara o funcionamento correto do programa é necessário a instalação de alguns programas e permissão de root.\nDeseja continuar?\n\n'	\
	0 0 \
	&& Menu \
	|| clear
	return
}

Show_File(){


	if [ ${1} == ${AUDIO_PATH} ]
	then
		dialog \
			--title 'Informações de Áudio' \
			--textbox ${1} \
			0 0
	elif [ ${1} == ${USB_PATH} ]
	then
		dialog \
			--title 'Informações de USB' \
			--textbox ${1} \
			0 0
	elif [ ${1} == ${SATA_PATH} ]
	then
		dialog \
			--title 'Informações de SATA' \
			--textbox ${1} \
			0 0
	elif [ ${1} == ${PCI_PATH} ]
	then
		dialog \
			--title 'Informações de PCI' \
			--textbox ${1} \
			0 0
	elif [ ${1} == ${MEMORY_PATH} ]
	then
		dialog \
			--title 'Informações de Memory' \
			--textbox ${1} \
			0 0
	elif [ ${1} == ${DISPLAY_PATH} ]
	then
		dialog \
			--title 'Informações de Display' \
			--textbox ${1} \
			0 0
	elif [ ${1} == ${NET_PATH} ]
	then
		dialog \
			--title 'Informações de Network' \
			--textbox ${1} \
			0 0
	elif [ ${1} == ${ETH_PATH} ]
	then
		dialog \
			--title 'Informações de Ethernet' \
			--textbox ${1} \
			0 0
	elif [ ${1} == ${VGA_PATH} ]
	then
		dialog \
			--title 'Informações de VGA' \
			--textbox ${1} \
			0 0
	elif [ ${1} == ${BAR_PLUS_PATH} ]
	then
		dialog \
			--title 'Informação de Interrupção' \
			--textbox ${1} \
			0 0
	else
		dialog \
			--title 'Arquivo não encontrado' \
			--msgbox 'Não foi possível encontrar o arquivo.' \
			0 0
	fi
}

ShowDisableFW(){
	dialog	\
		--title 'Aviso' \
		--msgbox 'Desativado!'	\
		0 0
}

ShowEnableFW(){
	dialog	\
		--title 'Aviso' \
		--msgbox 'Ativado!'	\
		0 0
}

Start_Program
