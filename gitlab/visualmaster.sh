#!/bin/bash

export PS4='(${BASH_SOURCE}:${LINENO}): - [$?] $ '

printenv
git status
git clone --depth=1 https://gitlab-ci-token:${CI_JOB_TOKEN}@gitlab.com/mvasseur/domjudeg.git t -b master
#git checkout master

#./gitlab/visualpr.sh master
