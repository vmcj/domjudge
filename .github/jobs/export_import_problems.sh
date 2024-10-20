#!/bin/bash

. .github/jobs/ci_settings.sh

set -euxo pipefail

DIR="$PWD"
PROBLEM="$1"
STATE="$2"
DJ_URL="http://localhost/domjudge"
API_URL="$DJ_URL/api"
CONTEST_URL="$DJ_URL/api/contests/demo"
WEBAPP_DIR="/opt/domjudge/domserver/webapp"

cd /opt/domjudge/domserver

section_start "Revert to inital backup"
/opt/domjudge/domserver/bin/dj_setup_database load "initial"
section_end

section_start "Setup the test user"
ADMINPASS=$(cat etc/initial_admin_password.secret)
export COOKIEJAR
COOKIEJAR=$(mktemp --tmpdir)
export CURLOPTS="--fail -sq -m 30 -b $COOKIEJAR"

# Make an initial request which will get us a session id, and grab the csrf token from it
CSRFTOKEN=$(curl $CURLOPTS -c $COOKIEJAR "$DJ_URL/login" 2>/dev/null | sed -n 's/.*_csrf_token.*value="\(.*\)".*/\1/p')
# Make a second request with our session + csrf token to actually log in
# shellcheck disable=SC2086
curl $CURLOPTS -c "$COOKIEJAR" -F "_csrf_token=$CSRFTOKEN" -F "_username=admin" -F "_password=$ADMINPASS" "$DJ_URL/login"

# Move back to the default directory
cd "$DIR"

cp "$COOKIEJAR" cookies.txt
sed -i 's/#HttpOnly_//g' cookies.txt
sed -i 's/\t0\t/\t1999999999\t/g' cookies.txt
section_end

section_start "Import the problem into DOMjudge"
# We use the steps from the manual to test those as a side effect.
cd /opt/domjudge/domserver/example_problems

if [ "$STATE" = "original" ]; then
    # Contest yaml
    /opt/domjudge/domserver/example_problems/generate-contest-yaml
    cat /opt/domjudge/domserver/etc/initial_admin_password.secret
    cat ~/.netrc
    ls
    pwd
    http --version
    http --check-status "$API_URL/contests"
    http --check-status -b -f POST "$API_URL/contests" "yaml@contest.yaml"
    ## Problems in contest
    #grep fltcmp -A4 example_problems/problems.yaml > example_problems/problems.yml
    #mv example_problems/problems.y{,a}ml
    #http --check-status -b -f POST "$CONTEST_URL/problems" data@problems.yaml
    ## Problem content
    #(cd "$PROBLEM"; zip -r "../problem$PROBLEM.zip" .)
    #http --check-status -b -f POST "$CONTEST_URL/problems" zip@problem"$PROBLEM".zip problem="$PROBLEM"
else
    true
    #"$WEBAPP_DIR"/bin/console api:call -m POST -f yaml=contest.yaml contests
    #"$WEBAPP_DIR"/bin/console api:call -m POST -f data=problems.yaml contests/demo/problems
    #"$WEBAPP_DIR"/bin/console api:call -m POST -d problem="$PROBLEM" -f zip="problem$PROBLEM.zip" contest/demo/problems
fi

cd "$DIR"
section_end

exit 0

section_start "Export the problem archive from DOMjudge"
STORAGE_DIR="${STATE}zips"
rm -rf "$STORAGE_DIR"
mkdir -p "$STORAGE_DIR"

wget \
  --load-cookies cookies.txt \
  -O "/tmp/$PROBLEM-$STATE.zip" \
  "$DJ_URL/jury/problems/1/export"
RET="$?"
section_end

section_start "Analyse failures"
#https://www.gnu.org/software/wget/manual/html_node/Exit-Status.html
# Exit code 4 is network error which we can ignore
# Exit code 8 can also be because of HTTP404 or 400
if [ $RET -ne 4 ] && [ $RET -ne 0 ] && [ $RET -ne 8 ]; then
    exit $RET
fi

EXPECTED_HTTP_CODES="200\|302"
set +e
NUM_ERRORS=$(grep -v "HTTP/1.1\" \($EXPECTED_HTTP_CODES\)" /var/log/nginx/domjudge.log | grep -v "robots.txt" -c; if [ "$?" -gt 1 ]; then exit 127; fi)
set -e
echo "$NUM_ERRORS"

if [ "$NUM_ERRORS" -ne 0 ]; then
    grep -v "HTTP/1.1\" \($EXPECTED_HTTP_CODES\)" /var/log/nginx/domjudge.log | grep -v "robots.txt"
    exit 1
fi
section_end

section_start "Compare the archives"
unzip "/tmp/$PROBLEM-$STATE.zip" -d "$STORAGE_DIR"

python3 "$DIR"/.github/jobs/compare_problem_package.py "$PROBLEM" "$STATE"
RET="$?"

/opt/domjudge/domserver/bin/dj_setup_database dump "$PROBLEM-$STATE"
section_end

exit "$RET"
