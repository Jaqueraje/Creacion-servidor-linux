#Instal·lem els packages necessaris
sudo apt update
sudo apt-get -y install realmd sssd sssd-tools samba-common krb5-user packagekit samba-common-bin
samba-libs adcli ntp
#Ens unim al realm
sudo realm join my.domain -U 'Administrator@ITBCOMPONENTES.ORG’ -v
#Configurem l’arxiu realm.conf
cat <<final>/etc/ realmd.conf
sudo vi /etc/
[users]
default-home = /home/%D/%U
default-shell = /bin/bash
[active-directory]
default-client = sssd
os-name = Ubuntu Desktop Linux
os-version = 18.10
[service]
automatic-install = no
[itbcomponentes.org]
fully-qualified-names = no
automatic-id-mapping = yes
user-principal = yes
manage-system = no
final
#Demanem ticket a kinit
sudo kinit Administrator@ITBCOMPONENTES.ORG
 Projecte Grup 02 - ITBComponentes
Institut Tecnològic de Barcelona 60
#Finalment configurem la creació de la home i el login
cat <<final>/etc/pam.d/common-session
session required pam_unix.so
session optional pam_winbind.so
session optional pam_sss.so
session optional pam_systemd.so
session required pam_mkhomedir.so skel=/etc/skel/ umask=0077
final