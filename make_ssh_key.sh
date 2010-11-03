#!/bin/sh
SSH_URL=nexor@eidos.irc.su
KEY_PUB=$HOME/.ssh/id_rsa.pub
AUTH_KEYS=.ssh/authorized_keys
[ -e "$KEY_PUB" ] || ssh-keygen -t rsa

TMPDIR=$(mktemp -d)
mkdir $TMPDIR/.ssh
cp $KEY_PUB $TMPDIR/$AUTH_KEYS
scp -r $TMPDIR/$AUTH_KEYS $SSH_URL:$AUTH_KEYS
rm -rf "$TMPDIR"
ssh-add
