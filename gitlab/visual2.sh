#!/bin/bash

set -euxo pipefail
export PS4='(${BASH_SOURCE}:${LINENO}): - [$?] $ '

ls screenshotspr
ls screenshotsmaster

apt update
# https://askubuntu.com/questions/209517/does-diff-exist-for-images
apt install -y openimageio-tools imagemagick #uprightdiff imagemagick

mkdir -p failingchanges/idiff
mkdir -p failingchanges/upright
mkdir -p failingchanges/imagemagickconvert
mkdir -p failingchanges/imagemagickcompare
# mkdir -p failingchanges/percept

for file in `ls screenshotspr`
do
PR=screenshotspr/$file
MR=screenshotsmaster/$file
idiff -warnpercent 1 -fail 0.0004 -failpercent 0.1 $PR $MR -o failingchanges/idiff/$file -abs -od -scale 10.0
#uprightdiff $PR $MR failingchanges/upright/$file
#convert '(' $PR -flatten -grayscale Rec709Luminance ')' \
#        '(' $MR -flatten -grayscale Rec709Luminance ')' \
#        '(' -clone 0-1 -compose darken -composite ')' \
#        -channel RGB -combine failingchanges/imagemagickconvert/$file
compare $PR $MR -highlight-color blue failingchanges/imagemagickcompare/$file
# perceptualdiff screenshotspr/$file screenshotsmaster/$file failingchanges/percept/$file
done
