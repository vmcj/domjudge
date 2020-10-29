#!/bin/bash

set -euxo pipefail
export PS4='(${BASH_SOURCE}:${LINENO}): - [$?] $ '

# https://askubuntu.com/questions/209517/does-diff-exist-for-images
apt update
apt install -y openimageio-tools imagemagick

mkdir failingchanges

for file in `ls screenshotspr`
do
	PR=screenshotspr/$file
	MR=screenshotsmaster/$file
	idiff -warn 100 -fail 0.5 $PR $MR -abs -od -scale 10.0
	# This fails when there is a change in time between the branches
	compare $PR $MR -highlight-color blue failingchanges/$file || true
done
