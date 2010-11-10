#!/bin/sh

GIT_PROJECT_PATH="$1"
REMOTE_GIT_ORIGIN="$2"
PROJECT_NAME="$3"

if [ "$GIT_PROJECT_PATH" = "" ] ; then
  echo "$0: path_to_new_project remote_git_url [project name]"
  exit 1
fi

if [ "$PROJECT_NAME" = "" ] ; then
  PROJECT_NAME=$(basename "$GIT_PROJECT_PATH")
fi

cpwd=$(pwd)
if [ ! -d "$GIT_PROJECT_PATH/.git" ] ; then
  [ ! -d "$GIT_PROJECT_PATH" ] && mkdir -p "$GIT_PROJECT_PATH"
  cd "$GIT_PROJECT_PATH" || exit 1
  git init || exit 1
fi
cd "$GIT_PROJECT_PATH" || exit 1

git remote add origin "$REMOTE_GIT_ORIGIN"

echo "$(date -R)\n* Initial import\n" >> "$GIT_PROJECT_PATH/CHANGELOG"
echo "Project $PROJECT_NAME" >> "$GIT_PROJECT_PATH/README"
git add .
git commit -a -m "Initial import to remote"
git push origin master:refs/heads/master

echo "git created in $REMOTE_GIT_ORIGIN"

cd "$cpwd"
