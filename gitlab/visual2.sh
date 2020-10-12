#!/bin/bash

git checkout master

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

apt update
apt install firefox cutycapt xvfb wkhtmltopdf -y
firefox -screenshot screenshots/public-ff-mstr.png http://localhost/public
xvfb-run --server-args="-screen 0, 1024x768x24" cutycapt --url=http://localhost/public --out=screenshots/public-capt-mstr.png --min-width=1366 --min-height=768
xvfb-run --server-args="-screen 0, 1024x768x24" wkhtmltoimage http://localhost/public screenshots/public-wiki-mstr.png
ls screenshots

apt install -y openimageio-tools perceptualdiff uprightdiff
idiff -warnpercent 1 -fail 0.0004 -failpercent 0.1 screenshots/public-ff.png screenshots/public-ff-mstr.png -o screenshots/ff.tif -abs -od -scale 10.0
idiff -warnpercent 1 -fail 0.0004 -failpercent 0.1 screenshots/public-capt.png screenshots/public-capt-mstr.png -o screenshots/capt.tif -abs -od -scale 10.0
idiff -warnpercent 1 -fail 0.0004 -failpercent 0.1 screenshots/public-wiki.png screenshots/public-wiki-mstr.png -o screenshots/wiki.tif -abs -od -scale 10.0
uprightdiff screenshots/public-ff.png screenshots/public-ff-mstr.png screenshots/ff_upright.png
uprightdiff screenshots/public-wiki.png screenshots/public-capt-mstr.png screenshots/capt_upright.png
uprightdiff screenshots/public-capt.png screenshots/public-wiki-mstr.png screenshots/wiki_upright.png
