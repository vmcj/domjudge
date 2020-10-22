#!/bin/bash

apt update
apt install firefox cutycapt xvfb wkhtmltopdf -y

. gitlab/bashrc

set -euxo pipefail

"$( dirname "${BASH_SOURCE[0]}" )"/base.sh

#section_start setup "Setup and install"

# Set up
#"$( dirname "${BASH_SOURCE[0]}" )"/base.sh

# Add jury to dummy user
#echo "INSERT INTO userrole (userid, roleid) VALUES (3, 2);" | mysql domjudge

# Add netrc file for dummy user login
#echo "machine localhost login dummy password dummy" > ~/.netrc

#LOGFILE="/opt/domjudge/domserver/webapp/var/log/prod.log"


#trap log_on_err ERR

#cd /opt/domjudge/domserver

#ADMINPASS=$(cat etc/initial_admin_password.secret)

# configure and restart php-fpm
#sudo cp /opt/domjudge/domserver/etc/domjudge-fpm.conf "/etc/php/7.2/fpm/pool.d/domjudge-fpm.conf"
#sudo /usr/sbin/php-fpm7.2

#section_end setup

section_start visual "Run visual checks"
section_end visual
