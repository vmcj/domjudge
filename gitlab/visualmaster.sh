#!/bin/bash

git branch -l
git branch -a
git status
git clone --depth=1 https://gitlab-ci-token:${CI_JOB_TOKEN}@gitlab.com/mvasseur/domjudeg.git t -b master
#git checkout master

#./gitlab/visualpr.sh master
