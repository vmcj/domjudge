#!/bin/bash

export PS4='(${BASH_SOURCE}:${LINENO}): - [$?] $ '

./gitlab/visualpr.sh master
