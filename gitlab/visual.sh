#!/bin/bash

mkdir screenshots
apt update;
apt install firefox cutycapt xvfb wkhtmltopdf -y 

shopt -s expand_aliases
alias trace_on='set -x'
alias trace_off='{ set +x; } 2>/dev/null'

function section_start_internal() {
	echo -e "section_start:`date +%s`:$1\r\e[0K$2"
	trace_on
}

function section_end_internal() {
	echo -e "section_end:`date +%s`:$1\r\e[0K"
	trace_on
}

alias section_start='trace_off ; section_start_internal '
alias section_end='trace_off ; section_end_internal '

set -euxo pipefail

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

curl http://localhost/domjudge/public >> curpage.html
cat curpage.html

firefox -screenshot screenshots/public-ff.png http://localhost/domjudge/public
xvfb-run --server-args="-screen 0, 1024x768x24" cutycapt --url=http://localhost/domjudge/public --out=screenshots/public-capt.png --min-width=1366 --min-height=768
xvfb-run --server-args="-screen 0, 1024x768x24" wkhtmltoimage http://localhost/domjudge/public screenshots/public-wk.png

ls screenshots
