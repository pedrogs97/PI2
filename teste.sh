#!/bin/bash
echo 'Entrando na Pasta.'
cd /var/spool/
echo 'Removendo arquivos antigos.'
rm -rf squidold
echo 'Parando Squid.'
service squid stop
echo 'Re-criando arquivos.'
rename squid squidold squid
mkdir squid
chmod 777 squid
echo 'Criando Swap.'
squid -z
echo 'Iniciando servico!'
service squid start
service squid status
echo 'Processo concluido com sucesso!'
exit 0