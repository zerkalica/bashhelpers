#!/bin/sh
#Remote part for trac user
#run as trac:trac

trac_install() {
  sudo apt-get install cherokee trac-git python-flup trac-accountmanager
}

trac_add() {
  local TRAC_PROJECT_PATH="$1"
  local GIT_PROJECT_PATH="$2"
  local PROJECT_NAME="$3"
  if [ "$GIT_PROJECT_PATH" = "" ] ; then
    echo "$0: path_to_trac_project path_to_git_project/.git [project name]"
    return
  fi

  if [ "$PROJECT_NAME" = "" ] ; then
    PROJECT_NAME=$(basename "$TRAC_PROJECT_PATH")
  fi

  local DB="sqlite:db/trac.db"

  track-admin "$TRAC_PROJECT_PATH" initenv "$PROJECT_NAME" "$DB" git "$GIT_PROJECT_PATH"

  local T_INI="$TRAC_PROJECT_PATH/conf/trac.ini"

  echo "[components]
tracext.git.* = enabled
tracopt.ticket.commit_updater.committicketreferencemacro = enabled
tracopt.ticket.commit_updater.committicketupdater = enabled
tracopt.ticket.commit_updater.committicketupdater = enabled
acct_mgr.* = enabled
tracrpc.* = enabled
trac.web.auth.LoginModule = disabled" >> "$T_INI"
#tracgitosis.* = enabled
  trac-admin "$TRAC_PROJECT_PATH" permission add admin TRAC_ADMIN

  echo "ex: sudo -u gitosis -s tracd --single-env --hostname=127.0.0.1 --port=50999 $TRAC_PROJECT_PATH"
}


trac_scan_and_add()
  echo "Trac: scanning for new projects in repositories"
  local GITOSIS_DIR="$1"
  local TRAC_ROOT="$2"
  local PROJECT_NAME
  local GITOSIS_REPS_DIR="$GITOSIS_DIR/repositories"

  for PROJECT_NAME in $GITOSIS_REPS_DIR/* ; do
    PROJECT_NAME=$(echo "$PROJECT_NAME" | sed 's/\.git$//')
    local GIT_PROJECT_REMOTE_PATH="$GITOSIS_REPS_DIR/$PROJECT_NAME.git"
    local TRAC_PROJECT_PATH="$TRAC_ROOT/$PROJECT_NAME"
    if [ ! -e "$TRAC_PROJECT_PATH" ] ;
      echo "Creating new trac enviroment in $TRAC_PROJECT_PATH"
      trac_add "$TRAC_PROJECT_PATH" "$GIT_PROJECT_REMOTE_PATH" "$PROJECT_NAME"
    fi
  done
}

trac_scan_and_add "/home/gitosis" "/home/trac/www"
