#!/bin/sh

set -eux

distro_id=$(grep "^ID=" /etc/os-release)

# Install everything for configure and testing
case $distro_id in
    "ID=fedora")
        dnf install pkg-config make bats autoconf automake util-linux -y ;;
    *)
        apt-get update; apt-get full-upgrade -y
        apt-get install pkg-config make bats autoconf -y ;;
esac

# Build the configure file
make configure

all_commands="$*"
if [ "${all_commands#*"domserver"}" != "$all_commands" ] || [ "${all_commands#*"judgehost"}" != "$all_commands" ]; then
    case $distro_id in
        "ID=fedora")
            dnf install gcc g++ debootstrap libcgroup-devel glibc-static libstdc++-static lsb_release -y ;;
        *)
            apt-get install gcc g++ debootstrap libcgroup-dev lsb-release -y ;;
esac

    ./configure \
        --with-baseurl='http://localhost/domjudge/' \
        --with-judgehost_chrootdir=/chroot/domjudge \
        --with-domjudge-user=root \
        --enable-domserver-build=no
fi
for arg in $@; do
    if [ "$arg" = "domserver" ]; then
        make dist
        make domserver
        make install-domserver
    fi
    if [ "$arg" = "judgehost" ]; then
        make judgehost
        make install-judgehost
        set -x
        mounts=$(mount | grep proc)
        echo $mounts
        mount_list=$(echo $mounts | cut -d ' ' -f3)
        for i in `mount | grep proc | cut -d ' ' -f3`; do
            mount -o remount rw $i || dmesg
        done
        set +x
        /opt/domjudge/judgehost/bin/dj_make_chroot
    fi
done

# Remove the old chroot when it exists
rm -rf /chroot/domjudge

# Install extra assert statements for bots
cp submit/assert.bash .github/jobs/"$1"-checks/

# Run the configure tests for this usecase
test_path="/__w/domjudge/domjudge" bats .github/jobs/"$1"-checks/all.bats
