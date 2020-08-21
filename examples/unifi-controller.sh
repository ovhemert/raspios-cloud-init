#!/bin/sh

# change hostname
OLDHOST=`cat /etc/hostname`
NEWHOST=unifi
if [[ "$OLDHOST" != "$NEWHOST" ]]
then
  echo "Changing hostname from $OLDHOST to $NEWHOST..."
  echo $NEWHOST > /etc/hostname
  sed -i "s/127.0.1.1.*$OLDHOST/127.0.1.1\t$NEWHOST/g" /etc/hosts
  reboot
fi

# install Unifi controller
if [ $(dpkg-query -W -f='${Status}' unifi 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "Installing Unifi controller software..."
  echo 'deb http://www.ui.com/downloads/unifi/debian stable ubiquiti' | tee /etc/apt/sources.list.d/100-ubnt-unifi.list
  wget -O /etc/apt/trusted.gpg.d/unifi-repo.gpg https://dl.ubnt.com/unifi/unifi-repo.gpg
  apt-get update 
  apt-get install haveged -y
  apt-get install openjdk-8-jre-headless -y
  apt-get install unifi -y
  systemctl stop mongodb
  systemctl disable mongodb
fi

exit 0
