#!/bin/sh

# change hostname
OLDHOST=`cat /etc/hostname`
NEWHOST=mypi
if [[ "$OLDHOST" != "$NEWHOST" ]]
then
  echo "Changing hostname from $OLDHOST to $NEWHOST..."
  echo $NEWHOST > /etc/hostname
  sed -i "s/127.0.1.1.*$OLDHOST/127.0.1.1\t$NEWHOST/g" /etc/hosts
  reboot
fi

exit 0
