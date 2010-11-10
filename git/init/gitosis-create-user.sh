#!/bin/sh

USER="git"
PUB_KEY="$1"

deluser --remove-home "$USER"
delgroup "$USER"
adduser --system --shell /bin/sh --group --disabled-password --gecos 'git version control' --home "/home/$USER" "$USER"

[ "$PUB_KEY" = "" ] && PUB_KEY="$HOME/.ssh/id_rsa.pub"

sudo -H -u $USER gitosis-init < "$PUB_KEY"
