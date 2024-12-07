#!/bin/bash

. .github/jobs/ci_settings.sh

DIR="$PWD"

export version=$1
unittest=$2
[ "$version" = "8.1" ] && CODECOVERAGE=1 || CODECOVERAGE=0

show_phpinfo $version

# Set up
export unit=1

# Add team to admin user
echo "UPDATE user SET teamid = 1 WHERE userid = 1;" | mysql domjudge_test

# Copy the .env.test file, as this is normally not done during
# installation and we need it.
cp webapp/.env.test /opt/domjudge/domserver/webapp/

# We also need the composer.json for PHPunit to detect the correct directory.
cp webapp/composer.json /opt/domjudge/domserver/webapp/

cd /opt/domjudge/domserver

# Run phpunit tests.
pcov=""
phpcov=""
if [ "$CODECOVERAGE" -eq 1 ]; then
    phpcov="-dpcov.enabled=1 -dpcov.directory=webapp/src"
    pcov="--coverage-html=${DIR}/coverage-html --coverage-clover coverage.xml"
fi
set +e
echo "unused:sqlserver:domjudge:domjudge:domjudge:3306" > /opt/domjudge/domserver/etc/dbpasswords.secret
php $phpcov webapp/bin/phpunit -c webapp/phpunit.xml.dist webapp/tests/$unittest --log-junit ${ARTIFACTS}/unit-tests.xml --colors=never $pcov > "$ARTIFACTS"/phpunit.out
UNITSUCCESS=$?

# Store the unit tests also in the root for the GHA
cp $ARTIFACTS/unit-tests.xml $DIR/

# Make sure the log exists before copy
touch ${DIR}/webapp/var/log/test.log
cp ${DIR}/webapp/var/log/*.log "$ARTIFACTS"/

set -e
CNT=0
THRESHOLD=32
if [ $CODECOVERAGE -eq 1 ]; then
    CNT=$(sed -n '/Generating code coverage report/,$p' "$ARTIFACTS"/phpunit.out | grep -v DoctrineTestBundle | grep -cv ^$)
    FILE=deprecation.txt
    sed -n '/Generating code coverage report/,$p' "$ARTIFACTS"/phpunit.out > ${DIR}/$FILE
    if [ $CNT -le $THRESHOLD ]; then
        STATE=success
    else
        STATE=failure
    fi
    ORIGINAL="gitlab.com/DOMjudge"
    REPLACETO="domjudge.gitlab.io/-"
    # Copied from CCS
    curl https://api.github.com/repos/domjudge/domjudge/statuses/$CI_COMMIT_SHA \
      -X POST \
      -H "Authorization: token $GH_BOT_TOKEN_OBSCURED" \
      -H "Accept: application/vnd.github.v3+json" \
      -d "{\"state\": \"$STATE\", \"target_url\": \"${CI_JOB_URL/$ORIGINAL/$REPLACETO}/artifacts/$FILE\", \"description\":\"Symfony deprecations ($version)\", \"context\": \"Symfony deprecation ($version)\"}"
fi
if [ $UNITSUCCESS -eq 0 ]; then
    STATE=success
else
    STATE=failure
fi

curl https://api.github.com/repos/domjudge/domjudge/statuses/$CI_COMMIT_SHA \
    -X POST \
    -H "Authorization: token $GH_BOT_TOKEN_OBSCURED" \
    -H "Accept: application/vnd.github.v3+json" \
    -d "{\"state\": \"$STATE\", \"target_url\": \"${CI_PIPELINE_URL}/test_report\", \"description\":\"Unit tests\", \"context\": \"unit_tests ($version)\"}"
if [ $UNITSUCCESS -ne 0 ] || [ $CNT -gt $THRESHOLD ]; then
    exit 1
fi

if [ $CODECOVERAGE -eq 1 ]; then
    section_start "Upload code coverage"
    # Only upload when we got working unit-tests.
    set +u # Uses some variables which are not set
    # shellcheck disable=SC1090
    . $DIR/.github/jobs/uploadcodecov.sh &>> "$ARTIFACTS"/codecov.log
    section_end
fi
