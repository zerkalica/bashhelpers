#!/bin/sh

GIT_PROJECT_PATH="$1"
GITOSIS_HOST="$2"
MEMBERS="$3"
PROJECT_NAME="$4"
GITOSIS_URL="git@$GITOSIS_HOST"
TRAC_URL="trac@$GITOSIS_HOST"

if [ "$MEMBERS" = "" ] ; then
  echo "$0 git_project_path gitosis_trac_host members [project name]"
  echo "ex: $0 ~/my-projects/testproject localhost \"vasia@booben3000, user1, user2\""
  exit 1
fi

[ "$PROJECT_NAME" = "" ] && PROJECT_NAME=$(basename "$GIT_PROJECT_PATH")

GIT_URL="$GITOSIS_URL:$PROJECT_NAME.git"

./gitosis-add.sh "$PROJECT_NAME" "$MEMBERS" "$GITOSIS_HOST" && \
./git-add.sh "$GIT_PROJECT_PATH" "$GIT_URL" "$PROJECT_NAME"

ssh "$TRAC_URL" "sh ./trac-add-enviroment.sh"
