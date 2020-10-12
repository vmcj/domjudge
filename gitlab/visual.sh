#!/bin/bash

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

mkdir screenshots

export PS4='(${BASH_SOURCE}:${LINENO}): - [$?] $ '

DIR=$(pwd)
GITSHA=$(git rev-parse HEAD || true)

# Set up
"$( dirname "${BASH_SOURCE[0]}" )"/base.sh

apt install firefox cutycapt xvfb wkhtmltopdf
firefox -screenshot screenshots/public-ff.png http://localhost/public
xvfb-run --server-args="-screen 0, 1024x768x24" cutycapt --url=http://localhost/public --out=screenshots/public-capt.png --min-width=1366 --min-height=768
wkhtmltoimage http://localhost/public google.png
