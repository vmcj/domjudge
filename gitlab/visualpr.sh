#!/bin/bash

shopt -s expand_aliases
alias trace_on='set -x'
alias trace_off='{ set +x; } 2>/dev/null'

function section_start_internal() {
	echo -e "section_start:`date +%s`:$1[collapsed=true]\r\e[0K$2"
	trace_on
}

function section_end_internal() {
	echo -e "section_end:`date +%s`:$1\r\e[0K"
	trace_on
}

alias section_start='trace_off ; section_start_internal '
alias section_end='trace_off ; section_end_internal '

mkdir screenshots$1
set -euxo pipefail

section_start fixup "Remove later"
apt update
apt install firefox -y
section_end fixup

section_start setup "Setup and install"

export PS4='(${BASH_SOURCE}:${LINENO}): - [$?] $ '

DIR=$(pwd)
GITSHA=$(git rev-parse HEAD || true)

# Set up
"$( dirname "${BASH_SOURCE[0]}" )"/base.sh

# Add jury to dummy user
echo "INSERT INTO userrole (userid, roleid) VALUES (3, 2);" | mysql domjudge

# Add netrc file for dummy user login
echo "machine localhost login dummy password dummy" > ~/.netrc

LOGFILE="/opt/domjudge/domserver/webapp/var/log/prod.log"

function log_on_err() {
	echo -e "\\n\\n=======================================================\\n"
	echo "Symfony log:"
	if sudo test -f "$LOGFILE" ; then
		sudo cat "$LOGFILE"
	fi
}

trap log_on_err ERR

cd /opt/domjudge/domserver

# This needs to be done before we do any submission.
# 8 hours as a helper so we can adjust contest start/endtime
TIMEHELP=$((8*60*60))
# Database changes to make the REST API and event feed match better.
cat <<EOF | mysql domjudge
DELETE FROM clarification;
UPDATE contest SET starttime  = UNIX_TIMESTAMP()-$TIMEHELP WHERE cid = 2;
UPDATE contest SET freezetime = UNIX_TIMESTAMP()+15        WHERE cid = 2;
UPDATE contest SET endtime    = UNIX_TIMESTAMP()+$TIMEHELP WHERE cid = 2;
UPDATE team_category SET visible = 1;
EOF

ADMINPASS=$(cat etc/initial_admin_password.secret)

# configure and restart php-fpm
sudo cp /opt/domjudge/domserver/etc/domjudge-fpm.conf "/etc/php/7.2/fpm/pool.d/domjudge-fpm.conf"
sudo /usr/sbin/php-fpm7.2

section_end setup

ADMINPASS=$(cat etc/initial_admin_password.secret)
export COOKIEJAR
COOKIEJAR=$(mktemp --tmpdir)
export CURLOPTS="--fail -sq -m 30 -b $COOKIEJAR"
date -s "18 May 2004 12:05:57"
# Make an initial request which will get us a session id, and grab the csrf token from it
CSRFTOKEN=$(curl $CURLOPTS -c $COOKIEJAR "http://localhost/domjudge/login" 2>/dev/null | sed -n 's/.*_csrf_token.*value="\(.*\)".*/\1/p')
# Make a second request with our session + csrf token to actually log in
curl $CURLOPTS -c $COOKIEJAR -F "_csrf_token=$CSRFTOKEN" -F "_username=admin" -F "_password=$ADMINPASS" "http://localhost/domjudge/login"

cd $DIR

STORAGEDIR=screenshots$1
mkdir $STORAGEDIR

cp $COOKIEJAR cookies.txt
sed -i 's/#HttpOnly_//g' cookies.txt
sed -i 's/\t0\t/\t1999999999\t/g' cookies.txt
for url in public
do
	mkdir $url
	cd $url
    cp $DIR/cookies.txt ./
	httrack http://localhost/domjudge/$url --assume html=text/html -*doc* -*/team/* -*/jury/* -*logout*
	cd $DIR
    mkdir /var/www/html/$url/
    cp -r $url/localhost/domjudge/* /var/www/html/$url/
    #ls /var/www/html/$url/
    #cat /etc/nginx/nginx.conf
    #ls /etc/nginx/sites-enabled/
    #cat /etc/nginx/sites-enabled/default
    #ls /etc/nginx
    # configure and restart nginx
    #sudo rm -f /etc/nginx/sites-enabled/*
    cp $DIR/gitlab/default-nginx /etc/nginx/sites-enabled/default
    service nginx restart
    #/usr/sbin/nginx &
    #firefox -screenshot $STORAGEDIR/nginx-ff.png http://localhost/index.html
    #firefox -screenshot $STORAGEDIR/$urlpart-ff.png http://localhost/$urlpublic/public.html
    #firefox -screenshot $STORAGEDIR/2-ff.png http://localhost/public/
    #for file in `find $url -type f -name "*.html"`
    #do
    #    echo $file
    #done
    for file in `find $url -type f -name "*.html"`
    do
        prefix="^$url\/localhost\/domjudge\/"
        urlpath=$(sed "s/$prefix//g"<<<$file)
        #echo $file $urlpath
        # Small risk of collision
        storepath=$(sed "s/\//_s_/g"<<<$urlpath)
        #echo $file $urlpath $storepath
        firefox -screenshot $STORAGEDIR/$storepath-ff.png http://localhost/$url/$urlpath
        #xvfb-run --server-args="-screen 0, 1024x768x24" cutycapt --url=http://localhost/$urlpath --out=$STORAGEDIR/$storepath-cc.png --min-width=1366 --min-height=768
        #xvfb-run --server-args="-screen 0, 1024x768x24" wkhtmltoimage http://localhost/$urlpath $STORAGEDIR/$storepath-wk.png
    done
done
