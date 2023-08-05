#!/bin/sh

set -eux

distro_id=$(grep "^ID=" /etc/os-release | cut -c4- | tr -d '"')

# Install everything for configure and testing
case $distro_id in
    "fedora")
        dnf install pkg-config make bats autoconf automake util-linux -y ;;
    opensuse-*)
        zypper install -y bats autoconf automake make apache ;;
    "alpine")
        apk add bats autoconf automake make pkgconf;;
    "arch")
        # Based on: https://www.tecmint.com/install-yay-aur-helper-in-arch-linux-and-manjaro/
        pacman --noconfirm -Syu --needed base-devel bash-bats autoconf automake make git sudo
        useradd -m packageuser; chown packageuser:packageuser /opt
        echo "packageuser ALL = (ALL) NOPASSWD: ALL" > /etc/sudoers.d/packageuser
        su packageuser -c "cd /opt; git clone https://aur.archlinux.org/yay-git.git; \
        cd yay-git; makepkg --noconfirm -si"
        sudo -u packageuser yay --noconfirm -Rs base-devel || true
        sudo -u packageuser yay --noconfirm -Rs gcc || true
        sudo -u packageuser yay --noconfirm -Syu gcc || true
        sudo -u packageuser yay --noconfirm -Rs gcc || true
        sudo -u packageuser yay --noconfirm -Syu gcc || true
        sudo -u packageuser yay --noconfirm -Syu libcgroup
        ;;
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
