#!/bin/sh

GITOSIS_HOST="$1"
PUB_KEY="$2"
TRAC_URL="trac@$GITOSIS_HOST"
if [ "$GITOSIS_HOST" = "" ] ; then
  echo "$0 gitosis_trac_host public_ssh_key"
  echo "ex: $0 ~/.ssh/id_rsa.pub localhost"
  exit 1
fi

[ "$PUB_KEY" = "" ] && PUB_KEY="$HOME/.ssh/id_rsa.pub"

ssh "$TRAC_URL" "[ -d ~./ssh ] || mkdir -p ~/.ssh"
cat "$PUB_KEY" | ssh "$TRAC_URL" 'sh -c "cat - >> ~/.ssh/authorized_keys"'
scp ./trac-add-enviroment.sh "$TRAC_URL":trac-add-enviroment.sh
ssh "$TRAC_URL" "./trac-add-enviroment.sh"

echo "Use add-project.sh git_project_path git_remote_url"
