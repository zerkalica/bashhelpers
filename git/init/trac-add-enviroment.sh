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
  mkdir -p "$TRAC_PROJECT_PATH" || exit 1
  chmod 0700 "$TRAC_PROJECT_PATH" || exit 1
  trac-admin "$TRAC_PROJECT_PATH" initenv "$PROJECT_NAME" "$DB" git "$GIT_PROJECT_PATH"

  local T_INI="$TRAC_PROJECT_PATH/conf/trac.ini"

  echo "[components]
tracext.git.* = enabled
tracrpc.* = enabled
tracopt.ticket.commit_updater.committicketreferencemacro = enabled
tracopt.ticket.commit_updater.committicketupdater = enabled
tracopt.ticket.commit_updater.committicketupdater = enabled
acct_mgr.web_ui.LoginModule = enabled
acct_mgr.web_ui.RegistrationModule = enabled
acct_mgr.db.SessionStore = enabled
acct_mgr.admin.AccountManagerAdminPage = enabled
acct_mgr.web_ui.AccountModule = enabled
acct_mgr.pwhash.htdigesthashmethod = enabled
acct_mgr.pwhash.htpasswdhashmethod = enabled
trac.web.auth.LoginModule = disabled" >> "$T_INI"

  sed 's#plugins_dir[ ]*=.*#plugins_dir = /home/trac/base/plugins#
s#templates_dir[ ]*=.*#templates_dir = /home/trac/base/templates#
s#log_type[ ]*=.*#log_type = file#
s#log_level[ ]*=.*#log_level = WARN#
s#\(\[account-manager\]\)#\1\npassword_store = SessionStore\n#
' -i "$T_INI"

  trac-admin "$TRAC_PROJECT_PATH" permission add admin TRAC_ADMIN BROWSER_VIEW CHANGESET_VIEW FILE_VIEW LOG_VIEW MILESTONE_VIEW REPORT_SQL_VIEW REPORT_VIEW ROADMAP_VIEW SEARCH_VIEW TICKET_VIEW TIMELINE_VIEW WIKI_VIEW
  trac-admin "$TRAC_PROJECT_PATH" permission add anonymous TRAC_ADMIN
  echo "#!/bin/sh\ntrac-admin "$TRAC_PROJECT_PATH" $@" > "$TRAC_PROJECT_PATH/ti"

  cd "$TRAC_PROJECT_PATH" || exit 1
  find . -type d -exec chmod 0700 {} \;
  find . -type f -exec chmod 0600 {} \;
  chmod +x "$TRAC_PROJECT_PATH/ti"

  echo "ex: sudo -u gitosis -s tracd --single-env --hostname=127.0.0.1 --port=50999 $TRAC_PROJECT_PATH"
}


trac_scan_and_add() {
  echo "Trac: scanning for new projects in repositories"
  local GITOSIS_DIR="$1"
  local TRAC_ROOT="$2"
  local PROJECT_NAME
  local GITOSIS_REPS_DIR=$GITOSIS_DIR/repositories
  cd "$GITOSIS_REPS_DIR" || exit 1
  for PROJECT_NAME in * ; do
    PROJECT_NAME=$(basename "$PROJECT_NAME")
    PROJECT_NAME=$(echo "$PROJECT_NAME" | sed 's/\.git$//')
    [ "$PROJECT_NAME" = "gitosis-admin" ] && continue
    local GIT_PROJECT_REMOTE_PATH="$GITOSIS_REPS_DIR/$PROJECT_NAME.git"
    local TRAC_PROJECT_PATH="$TRAC_ROOT/$PROJECT_NAME"
    if [ ! -e "$TRAC_PROJECT_PATH" ] ; then
      echo "Creating new trac enviroment in $TRAC_PROJECT_PATH $GIT_PROJECT_REMOTE_PATH $PROJECT_NAME"
      trac_add "$TRAC_PROJECT_PATH" "$GIT_PROJECT_REMOTE_PATH" "$PROJECT_NAME"
    fi
  done
}

trac_scan_and_add "/home/git" "/home/trac/www"
