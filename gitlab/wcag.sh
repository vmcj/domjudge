#!/bin/bash

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
echo "INSERT INTO userrole (userid, roleid) VALUES (1, 2);" | mysql domjudge

if [ "$1" == "team" ]; then
# Add team to admin user
echo "INSERT INTO userrole (userid, roleid) VALUES (1, 3);" | mysql domjudge
echo "UPDATE user SET teamid = 1 WHERE userid = 1;" | mysql domjudge
fi

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

cd $DIR

STANDARDS="WCAG2A WCAG2AA WCAG2AAA Section508"

if [ "$1" == "team" ]; then
	STANDARDS="WCAG2A WCAG2AA"
	export COOKIEJAR
	COOKIEJAR=$(mktemp --tmpdir)
	export CURLOPTS="--fail -sq -m 30 -b $COOKIEJAR"

	# Make an initial request which will get us a session id, and grab the csrf token from it
	CSRFTOKEN=$(curl $CURLOPTS -c $COOKIEJAR "http://localhost/domjudge/login" 2>/dev/null | sed -n 's/.*_csrf_token.*value="\(.*\)".*/\1/p')
	# Make a second request with our session + csrf token to actually log in
	curl $CURLOPTS -c $COOKIEJAR -F "_csrf_token=$CSRFTOKEN" -F "_username=admin" -F "_password=$ADMINPASS" "http://localhost/domjudge/login"
	cp $COOKIEJAR cookies.txt
	sed -i 's/#HttpOnly_//g' cookies.txt
	sed -i 's/\t0\t/\t1999999999\t/g' cookies.txt
fi


apt update
apt install -y npm
apt -y install libx11-xcb-dev libxtst-dev libnss3-dev libxss-dev libasound2-dev libatk-bridge2.0-dev libgtk-3-dev
npm install -g pa11y

FOUNDERR=0
ACCEPTEDERRTOTAL=0
ACCEPTEDERR=5

SCRAPEURL=public
URL=$SCRAPEURL$1
mkdir $URL
cd $URL
if [ "$1" == "team" ]; then
	cp $DIR/cookies.txt ./
fi
httrack http://localhost/domjudge/$SCRAPEURL --assume html=text/html -*jury* -*doc* -*login* -*logout*

cd $DIR
for file in `find $URL -name *.html`
do
	section_start ${file//\//} $file
	# T is reasonable amount of errors to allow to not break
	# if [ "$1" == "public" ]; then
	su domjudge -c "pa11y --runner axe -T $ACCEPTEDERR --ignore color-contrast --ignore page-has-heading-one -E '#menuDefault > a' --reporter json ./$file" | python -m json.tool
        ERR=`su domjudge -c "pa11y --runner axe --ignore page-has-heading-one --ignore color-contrast -T $ACCEPTEDERR -E '#menuDefault > a' --reporter csv ./$file" | wc -l`
	FOUNDERR=$((ERR+FOUNDERR-1)) # Remove header row
	# fi
	for standard in $STANDARDS
	do
		su domjudge -c "pa11y -s $standard -T $ACCEPTEDERR -E '#menuDefault > a' -i WCAG2AAA.Principle1.Guideline1_4.1_4_6.G17.Fail --reporter json ./$file" | python -m json.tool
        	ERR=`su domjudge -c "pa11y -s $standard -T $ACCEPTEDERR -E '#menuDefault > a' -i WCAG2AAA.Principle1.Guideline1_4.1_4_6.G17.Fail --reporter csv ./$file" | wc -l`
		FOUNDERR=$((ERR+FOUNDERR-1)) # Remove header row
	done
	section_end $file
done
# Do not hard error yet
echo "Found: " $FOUNDERR
[ "$FOUNDERR" -le "$ACCEPTEDERRTOTAL" ]
