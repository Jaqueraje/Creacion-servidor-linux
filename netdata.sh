#!/bin/bash
# Instal·lació de paquets necessaris per Netdata
sudo apt-get install zlib1g-dev uuid-dev libmnl-dev gcc make git autoconf-archive autogen automake pkgconfig curl -y
# Descarreguem Netdata
git clone https://github.com/firehol/netdata.git --depth=1
# Entrem a la carpeta /netdata i executem l’instal·lador
cd /netdata
sudo ./netdata-installer.sh
# Ens assegurem que Netdata s’engegarà al encendre el server.
sudo killall netdata
sudo cp system/netdata.service.in /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable netdata
sudo systemctl start netdata
sudo systemctl status netdata
# Ara entrem via web a veure els nostres recursos
echo “Entra a http://localhost:19999 per veure la monitorització del teu sistema”