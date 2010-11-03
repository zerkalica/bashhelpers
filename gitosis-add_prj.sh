#!/bin/sh
APP="testapp"
MEMBERS="nexor@buben3000"

WORKPLACE=~/public_html/git
GITUSER="gitosis"
GHOME="$GITUSER@localhost"

git_first_init() {
#server side:
#	sudo deluser --remove-home $GITUSER
#	sudo delgroup $GITUSER
#	sudo adduser --shell /bin/sh --gecos 'git version control' --home /home/$GITUSER $GITUSER

#client side
	scp ~/.ssh/id_rsa.pub $GHOME:id_rsa.pub
	ssh $GHOME "gitosis-init < ~/id_rsa.pub && rm ~/id_rsa.pub"

#server side
#	sudo usermod -p "*" $GITUSER
}

git_add_project() {
	mkdir -p "$WORKPLACE" && cd "$WORKPLACE"
	git clone $GHOME:gitosis-admin.git
	cd "$WORKPLACE/gitosis-admin"
	echo "
[group ${APP}_team]
writable = $APP
members = $MEMBERS" >> "./gitosis.conf"
	git commit -a -m "Allow $MEMBERS access to $APP.git"
	git push
}

git_init_project() {
	mkdir -p $WORKPLACE/$APP && cd $WORKPLACE/$APP && git init && git remote add origin $GHOME:$APP.git
	echo "$(date -R)\n* Initial import\n" > CHANGELOG
	git add .
	git commit -a -m "Initial import" && git push origin master:refs/heads/master
}

#git_first_init
git_add_project
git_init_project
