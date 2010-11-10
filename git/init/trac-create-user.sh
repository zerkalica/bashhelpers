#!/bin/sh

USER="trac"
PUB_KEY="$1"
[ "$PUB_KEY" = "" ] && PUB_KEY="$HOME/.ssh/id_rsa.pub"

deluser --remove-home "$USER"
delgroup "$USER"
adduser --shell /bin/sh --gecos 'trac user' --home "/home/$USER" "$USER"
usermod  -a -G "git" "$USER"

cp ./trac-add-enviroment.sh "/home/$USER/trac-add-enviroment.sh"
[ -d /home/$USER/.ssh ] || mkdir -p /home/$USER/.ssh
touch "/home/$USER/.ssh/authorized_keys"
if [ "$PUB_KEY" != "" ] ; then
  cat $PUB_KEY >> "/home/$USER/.ssh/authorized_keys"
fi

mkdir -p "/home/$USER/base/templates"
mkdir -p "/home/$USER/base/plugins"
mkdir -p "/home/$USER/www"

chown -R $USER:$USER "/home/$USER"
cd "/home/$USER" && \
find . -type d -exec chmod 0700 {} \; && \
find . -type f -exec chmod 0600 {} \;
chmod 0700 "/home/$USER/trac-add-enviroment.sh"

