#!/bin/bash

adduser $DEVELOPER
gpasswd -a $DEVELOPER wheel
PASSWD=$(pwqgen)
echo -e "$PASSWD\n$PASSWD" | (passwd --stdin $DEVELOPER)
echo "######################################"
echo "## user password: $PASSWD"
echo "######################################"
mkdir /home/$DEVELOPER/.ssh
echo $KEY >> /home/$DEVELOPER/.ssh/authorized_keys
chmod og-w /home/$DEVELOPER/.ssh
echo "$DEVELOPER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

cp /root/.bashrc /home/$DEVELOPER/
cp /root/.bash_profile /home/$DEVELOPER/
mkdir /home/$DEVELOPER/volumes/workspace
ln -s /srv/www /home/$DEVELOPER/volumes/www
ln -s /etc/nginx/conf.d /home/$DEVELOPER/volumes/conf.d
chown $DEVELOPER.$DEVELOPER -r /home/$DEVELOPER/volumes
