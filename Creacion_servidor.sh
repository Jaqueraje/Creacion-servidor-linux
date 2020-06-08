#!/bin/bash
#Primer actualitzar sistema i repositoris
sudo apt-get update && sudo apt-get upgrade
sudo apt-get install samba krb5-user krb5-config winbind libpam-winbind libnss-winbind
#A continuació hem de parar i enmascarar serveis
systemctl stop smbd nmbd winbind
systemctl disable smbd.service nmbd.service winbind.service
systemctl mask smbd
systemctl mask nmbd
systemctl mask winbind
systemctl unmask samba-ad-dc.service
systemctl enable samba-ad-dc.service
systemctl start samba-ad-dc
#eliminem l'arxiu de configuració de samba i fem backup
mv /etc/samba/smb.conf /etc/samba/smb.old
#Ja podem configurar el domini interactivament
samba-tool domain provision --use-rfc2307 --interactive
#mateix que el smb.conf
mv /etc/krb5.conf /etc/krb5.old
n -s /var/lib/samba/private/krb5.conf /etc/
#tornem a activar el servei samba
systemctl restart samba-ad-dc.service
#comprovar que funciona correctament
samba-tool domain level show
#Així no es modifica el resolv.conf amb reinicis
echo -e "[main]\ndns=none" > /etc/NetworkManager/conf.d/no-dns.conf
systemctl restart NetworkManager.service
 Projecte Grup 02 - ITBComponentes
Institut Tecnològic de Barcelona 58
sudo nano /etc/resolv.conf ##nameserver 127.0.0.1/domain itbcomponentes.org/search
itbcomponentes.org
#comprovem que els dns funcionen correctament
ping -itbcomponentes.org
host -t A itbcomponentes.org
host -t SRV _kerberos._udp.itbcomponentes.org
host -t SRV _ldap._tcp.itbcomponentes.org
#verifiquem autenticació de Kerberos
kinit administrator@ITBCOMPONENTES.ORG
klist
#canviar la password del administrador de domini
samba-tool user setpassword administrator
#modifiquem el arxiu de configuració del smb amb les característiques del servei
cat <<final>/ etc/samba/smb.conf
Global parameters
[global]
dns forwarder = 192.168.15.105
netbios name = DEBIAN
realm = ITBCOMPONENTES.ORG
server role = active directory domain controller
workgroup = ITBCOMPONENTES
idmap_ldb:use rfc2307 = yes
template shell = /bin/bash
winbind use default domain = true
winbind enum users = yes
winbind enum groups = yes
[netlogon]
path = /var/lib/samba/sysvol/itb.org/scripts
read only = No
[sysvol]
path = /var/lib/samba/sysvol
read only = No
final
#Comprova que l'arxiu està correcte i arranquem el servei
testparm
systemctl restart samba-ad-dc.service
#Configurem el pam
pam-auth-update
cat <<final>/etc/nssswitch.conf
passwd: files winbind
group: files winbind
shadow: files
gshadow: files
hosts: files mdns4_minimal [NOTFOUND=return] dns myhostname
networks: files
protocols: db files
services: db files
 Projecte Grup 02 - ITBComponentes
Institut Tecnològic de Barcelona 59
ethers: db files
rpc: db files
netgroup: nis
final
cat <<final>/etc/pam.d/common-password
password [success=2 default=ignore] pam_unix.so obscure sha512
password [success=1 default=ignore] pam_winbind.so try_first_pass
password requisite pam_deny.so
password required pam_permit.so
password optional pam_gnome_keyring.so
final
#Finalment comprovem que els usuaris del domini estan visibles
wbinfo -i administrator
getent passwd | grep ITBCOMPONENTES
getent group | grep ITBCOMPONENTES