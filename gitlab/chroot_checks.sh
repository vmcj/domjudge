#!/bin/bash

. gitlab/ci_settings.sh

function finish() {
    echo -e "\\n\\n=======================================================\\n"
    echo "Storing artifacts..."
    trace_on
    set +e
    cp /proc/cmdline "$GITLABARTIFACTS/cmdline"
    cp /chroot/domjudge/etc/apt/sources.list "$GITLABARTIFACTS/sources.list"
    cp /chroot/domjudge/debootstrap/debootstrap.log "$GITLABARTIFACTS/debootstrap.log"
}
trap finish EXIT

section_start setup "Setup and install"
if [ -f /etc/fedora-release ]; then
    dnf install -y redhat-lsb-core make pkgconfig sudo libcgroup-devel lsof php-cli \
        php-mbstring php-xml php-process procps-ng gcc g++ bats
fi

lsb_release -a

# configure, make and install (but skip documentation)
make configure
FLAGS="--with-webserver-group=root --with-domjudge-user=domjudge"
if [ -n "${CI+x}" ]; then
    FLAGS="$FLAGS --with-judgehost_chrootdir=${DIR}/chroot/domjudge"
fi
./configure $FLAGS |& tee "$GITLABARTIFACTS/configure.log"
make judgehost |& tee "$GITLABARTIFACTS/make.log"
sudo make install-judgehost |& tee -a "$GITLABARTIFACTS/make.log"
section_end setup

section_start mount "Show runner mounts"
# Currently gitlab has some runners with noexec/nodev,
# This can be removed if we have more stable runners.
if [ -n "${CI+x}" ]; then
    mount -o remount,exec,dev /builds
fi
section_end mount

section_start chroot "Configure chroot"

if [ -e ${DIR}/chroot/domjudge ]; then
    rm -rf ${DIR}/chroot/domjudge
fi

cd ${DIR}/misc-tools || exit 1
section_end chroot

section_start chroottest "Test chroot contents"
cp ${DIR}/submit/assert.bash ./
cp ${DIR}/gitlab/chroot.bats ./
bats ./chroot.bats
section_end chroottest
#for arch in amd64,arm64,""
#for dir in "/chroot","/builds/chroot","/notadir/chroot"
#for dist in "Debian","Ubuntu","notLinux"
#for rel in "buster","wheeze","focal","bionic","notarelease"
#for incdeb in "zip","nano"
#for remdeb in "gcc","pypy3"
#for locdeb in "vim.deb","helloworld.deb"
#for mirror in "http://mirror.yandex.ru/debian","http://mirror.yandex.ru/debian"
#for overwrite in "1","0"
#for force in "1","0"
#for help in "1","0"

#ARGS=""
#if [ -n "${ARCH+x}" ]; then
#    ARGS="$ARGS -a ${ARCH}"
#fi
#if [ -n "${DISTRO+x}" ]; then
#    ARGS="$ARGS -D ${DISTRO}"
#fi
#if [ -n "${RELEASE+x}" ]; then
#    ARGS="$ARGS -R ${RELEASE}"
#fi
#sudo ./dj_make_chroot ${ARGS} |& tee "$GITLABARTIFACTS/dj_make_chroot.log"
#section_end chroot
#
#section_start chroottest "Test chroot contents"
#cp submit/assert.bash ./
#bats ./chroot_tests.bats
#sudo ./dj_run_chroot "pypy3"
