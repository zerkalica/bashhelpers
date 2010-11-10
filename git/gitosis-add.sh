#!/bin/sh

PROJECT_NAME="$1"
MEMBERS="$2"
GITOSIS_HOST="$3"
WORKPLACE="$HOME/workspace"

if [ "$GITOSIS_HOST" = "" ] ; then
  echo "$0: project_name members gitosis_host"
  echo "Ex: $0 testapp \"nexor@buben3000 vasiya@somehost petya\" localhost"
  exit 1
fi

GITOSIS_URL="git@$GITOSIS_HOST"

[ -d "$WORKPLACE" ] || mkdir -p "$WORKPLACE"
echo git clone "$GITOSIS_URL:gitosis-admin.git"

cpwd=$(pwd)
cd "$WORKPLACE" || exit 1
if [ -d "$WORKPLACE/gitosis-admin/.git" ] ; then
  cd "$WORKPLACE/gitosis-admin"
  git pull || exit 1
else
  git clone "$GITOSIS_URL:gitosis-admin.git" || exit 1
fi

cd "$WORKPLACE/gitosis-admin" && \
echo "
[group ${PROJECT_NAME}_team]
writable = $PROJECT_NAME
members = $MEMBERS" >> "./gitosis.conf" && \
git commit -a -m "Allow $MEMBERS access to $PROJECT_NAME.git" &&
git push && \
echo "admin: configure gitosis.conf in admin git: $WORKPLACE/gitosis-admin, git members: $MEMBERS" && \
echo "member: cd your_project && git init && git remote add origin $GITOSIS_URL:$PROJECT_NAME.git"
cd "$cpwd"
