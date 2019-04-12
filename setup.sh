echo -e "Spray Setup Started!\n"
apt-get -y update
apt-get -y install curl samba samba-common libcups2 samba-client
chmod 777 ./startspray.sh
chmod 777 ./spray.sh
echo -e "Spray Setup Completed!\n"