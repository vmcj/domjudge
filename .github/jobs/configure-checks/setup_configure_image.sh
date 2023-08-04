#!/bin/sh

set -eux

distro_id=$(grep "^ID=" /etc/os-release | cut -c4- | tr -d '"')

# Install everything for configure and testing
case $distro_id in
    "fedora")
        dnf install pkg-config make bats autoconf automake util-linux -y ;;
    opensuse-*)
        zypper install -y bats autoconf automake make shadow ;;
    "alpine")
        apk add bats autoconf automake make pkgconf;;
    "arch")
        pacman --noconfirm -Syu bash-bats autoconf automake make ;;
    "gentoo")
        emerge bats autoconf automake 2>/dev/zero 1>/dev/zero
        cd /domjudge ;;
    *)
        apt-get update; apt-get full-upgrade -y
        apt-get install pkg-config make bats autoconf -y ;;
esac

# Build the configure file
make configure

# Install extra assert statements for bots
cp submit/assert.bash .github/jobs/configure-checks/

# Run the configure tests for this usecase
export test_path="/__w/domjudge/domjudge"
if [ "$distro_id" = "gentoo" ]; then
    test_path="/tmp/domjudge"
fi
bats .github/jobs/configure-checks/all.bats
