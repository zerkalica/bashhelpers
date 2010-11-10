#!/bin/sh

GIT_PROJECT_PATH="$1"
GITOSIS_HOST="$2"
MEMBERS="$3"
if [ "$MEMBERS" = "" ] ; then
  echo "$0 git_project_path gitosis_trac_host members"
  echo "ex: $0 ~/my-projects/testproject localhost \"vasia@booben3000, user1, user2\""
  exit 1
fi

GITOSIS_URL="git@$GITOSIS_HOST"
TRAC_URL="trac@$GITOSIS_HOST"

PROJECT_NAME="$3"


if [ "$GIT_PROJECT_PATH" = "" ] ; then
  echo "$0: path_to_new_project remote_git_url [project name]"
  exit 1
fi

[ "$PROJECT_NAME" = "" ] && PROJECT_NAME=$(basename "$GIT_PROJECT_PATH")

GIT_URL="$GITOSIS_URL:$PROJECT_NAME.git"

./git-add.sh "$GIT_PROJECT_PATH" "$GIT_URL" "$PROJECT_NAME"

./gitosis-add.sh "$PROJECT_NAME" "$MEMBERS" "$GITOSIS_URL:gitosis-admin.git"

ssh "$TRAC_URL" "sh ./add-trac-enviroment.sh"
