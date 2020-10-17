#!/bin/bash

gitlab/base.sh

ADMINPASS=$(cat etc/initial_admin_password.secret)
export COOKIEJAR
COOKIEJAR=$(mktemp --tmpdir)
export CURLOPTS="--fail -sq -m 30 -b $COOKIEJAR"

# Make an initial request which will get us a session id, and grab the csrf token from it
CSRFTOKEN=$(curl $CURLOPTS -c $COOKIEJAR "http://localhost/domjudge/login" 2>/dev/null | sed -n 's/.*_csrf_token.*value="\(.*\)".*/\1/p')
# Make a second request with our session + csrf token to actually log in
curl $CURLOPTS -c $COOKIEJAR -F "_csrf_token=$CSRFTOKEN" -F "_username=admin" -F "_password=$ADMINPASS" "http://localhost/domjudge/login"

cat $COOKIEJAR
sed -i 's/#HttpOnly_//g' $COOKIEJAR
>&2 cat $COOKIEJAR

cp $COOKIEJAR cookies.txt

apt update
apt install httrack -y

wget https://github.com/validator/validator/releases/latest/download/vnu.linux.zip
unzip vnu.linux.zip

mydir=$(pwd)
for url in public jury team
do
	mkdir $url
	cd $url
	httrack http://localhost/$url
	./vnu-runtime-image/bin/vnu $url
	cd $mydir
done

