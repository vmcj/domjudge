#!/bin/bash

set -eux

distro_id=$(grep "^ID=" /etc/os-release)

# Install everything for configure and testing
shared="pkg-config make rst2pdf autoconf composer bats"

case $distro_id in
    "ID=fedora")
        dnf install $shared automake util-linux \
                    python3-{yaml,sphinx{,_rtd_theme}} -y ;;
    *)
        apt-get update; apt-get full-upgrade -y
        apt-get install $shared \
                        python3-{yaml,sphinx{,-rtd-theme}} -y ;;
esac

# Build the configure file
make dist

# Install extra assert statements for bots
cp submit/assert.bash .github/jobs/configure-checks/

# Run the configure tests for this usecase
test_path="/__w/domjudge/domjudge" bats .github/jobs/configure-checks/all.bats
