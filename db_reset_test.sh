#!/usr/bin/env bash

set -x

echo 'drop database domjudge_test' | mysql -uroot -pdomjudge
echo 'create database domjudge_test' | mysql -uroot -pdomjudge
echo 'GRANT ALL PRIVILEGES ON domjudge_test.* TO domjudge@"%";' | mysql -uroot -pdomjudge
export APP_ENV="test"
bin/dj_setup_database -uroot -pdomjudge bare-install
echo "UPDATE user SET teamid = null WHERE userid = 1;" | mysql -uroot -pdomjudge domjudge_test
bin/dj_setup_database -uroot -pdomjudge -q install-examples
echo "UPDATE user SET teamid = 1 WHERE userid = 1;" | mysql -uroot -pdomjudge domjudge_test


#echo 'drop database domjudge_test' | mysql -uroot -pdomjudge
#echo 'create database domjudge_test' | mysql -uroot -pdomjudge
#echo "GRANT ALL ON domjudge_test.* TO 'domjudge'@'%';" | mysql -uroot -pdomjudge
#export DB_FIRST_INSTALL=1
#export DATABASE_URL="mysql://domjudge:domjudge@mariadb:3306/domjudge_test?serverVersion=mariadb-10.5.9"
#webapp/bin/console -q doctrine:migrations:migrate -n
#webapp/bin/console -q domjudge:load-default-data
#webapp/bin/console -q domjudge:load-example-data
#echo "UPDATE user SET teamid = null WHERE userid = 1;" | mysql -udomjudge -pdomjudge domjudge_test
#sed -i 's|3306/domjudge|3306/domjudge_test|g' webapp/.env.local
#cd example_problems/
#yes y | ../bin/import-contest http://localhost/api
#cd ..
#sed -i 's|3306/domjudge_test|3306/domjudge|g' webapp/.env.local
#echo "UPDATE user SET teamid = 1 WHERE userid = 1;" | mysql -udomjudge -pdomjudge domjudge_test
