#!/bin/sh

USER="trac"
deluser --remove-home "$USER"
delgroup "$USER"
adduser --shell /bin/sh --gecos 'trac user' --home "/home/$USER" "$USER"
usermod  -a -G "gitosis" "$USER"
id "$USER"
