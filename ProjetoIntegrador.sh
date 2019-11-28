#!/bin/bash

DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=0
WIDTH=0

BASE_PATH=$HOME
FULL_PATH="${BASE_PATH}/pi/"
CPU_PATH="${FULL_PATH}info"
CPU_PATH_AUX="${FULL_PATH}info-aux"
MEM_PATH="${FULL_PATH}mem"
BAR_PATH="${FULL_PATH}bar"
QLQ_PATH="${FULL_PATH}lsdev"
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
	acl block_sites url_regex -i "/etc/squid/sites_proibidos"
	acl users proxy_auth "/etc/squid/users"
	acl sites_users url_regex -i "/etc/squid/sites_permitidos"
	#---- http_access ----#
	#__Default__
	http_access deny !Safe_ports
	http_access deny CONNECT !SSL_ports
	http_access allow localhost manager
	http_access deny manager
	#__Authoral__
	http_access deny block_sites
	http_access allow users sites_users


	#---- Others ----#
	include /etc/squid/conf.d/*

	# Example rule allowing access from your local networks.
	# Adapt localnet in the ACL section to list your (internal) IP networks
	# from where browsing should be allowed
	#http_access allow localnet
	http_access allow localhost

	# And finally deny all other access to this proxy
	http_access allow all

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
		echo "${INPUT}" >> /etc/squid/sites_proibidos
	fi
}
#----Configurações----# 
InstallPackages(){
	STATUS_SQUID="$(dpkg -s squid3 | grep -i status)"
	STATUS_APACHE="$(dpkg -s apache2 | grep -i status)"
	STATUS_APACHE_UTILS="$(dpkg -s apache2-utils | grep -i status)"
	STATUS_SARG="$(dpkg -s sarg | grep -i status)"
	if [ ! "Status: install ok installed" == "$STATUS" ]
	then
		`sudo apt install -y squid3`
		dialog  \
			--title 'Instalação'    \
			--msgbox 'Squid instalado com sucesso!'  \
			0 0
		clear
		#InputACL
		CreateSquidFile
		ConfigSquid
	else
		dialog  \
			--title 'Instalação'    \
			--msgbox 'Squid já foi instalado.'  \
			0 0
		clear
		#InputACL
		CreateSquidFile
		ConfigSquid
	fi
	if [ ! "Status: install ok installed" == "$STATUS_APACHE" ]
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
	if [ ! "Status: install ok installed" == "$STATUS_APACHE_UTILS" ]
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
	if [ ! "Status: install ok installed" == "$STATUS_SARG" ]
	then
		`sudo apt install -y sarg`
		dialog  \
			--title 'Instalação'    \
			--msgbox 'Sarg instalado com sucesso!'  \
			0 0
	else
		dialog  \
			--title 'Instalação'    \
			--msgbox 'Sarg já foi instalado.'  \
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
		dialog  \
			--title 'Aviso'    \
			--msgbox 'SQUID Configurado com sucesso.'  \
			0 0
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
			1 )
				clear
				InstallPackages
				dialog  \
					--title 'Aviso'    \
					--msgbox 'Proxy configurado com sucesso.'  \
					0 0
				;;
			2 ) 
				#  iptables -t nat -A PREROUTING -s SUA_REDE_LOCAL/MASCARA -p tcp --dport 80 -j REDIRECT --to-port 3128
				dialog 
					--title 'Aviso' \
					--textbox "Firewall configurado com sucesso."\
					0 0
			;;
			3 ) 
				if sudo tcpdump -i wlp2s0 -qntt -s0 -c5 > ${TCP_PATH}
				then
					dialog \
						--title "Ultimos 5 pacotes capturados:" \
						--textbox ${TCP_PATH} \
						0 0 
				fi
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
			Menu
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
				#Detalhes sobre IRQS
				echo 'Device  IRQ      Descrição:' >> ${BAR_PATH}
				echo `lsdev | grep -i 'amdgpu'` >> ${BAR_PATH}
				echo `lsdev | grep -i 'ath9k'` >> ${BAR_PATH}
				echo `lsdev | grep -i 'rtc0'` >> ${BAR_PATH}
				echo `lsdev | grep -i 'dmar0'` >> ${BAR_PATH}
				echo `lsdev | grep -i 'dmar1'` >> ${BAR_PATH}
				echo `lsdev | grep -i 'enp3s0'` >> ${BAR_PATH}
				echo `lsdev | grep -i 'mei_me'` >> ${BAR_PATH}
				dialog \
					--title 'Barramento' \
					--textbox ${BAR_PATH} \
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
#----Tela inicial----#
Start_Program(){
	dialog	\
	--title 'ATENÇÂO!'	\
	--yesno	'\nPara o funcionamento correto do programa é necessário a instalação de alguns programas e permissão de root.\nDeseja continuar?\n\n'	\
	0 0 \
	&& Menu \
	|| clear
	return
}

Start_Program
