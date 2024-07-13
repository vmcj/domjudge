#!/bin/bash

. .github/jobs/ci_settings.sh

set -euxo pipefail

function finish() {
    echo -e "\\n\\n=======================================================\\n"
    echo "Storing artifacts..."
    trace_on
    set +e
    cp /proc/cmdline "$ARTIFACTS/cmdline"
    cp /chroot/domjudge/etc/apt/sources.list "$ARTIFACTS/sources.list"
    cp /chroot/domjudge/debootstrap/debootstrap.log "$ARTIFACTS/debootstrap.log"
}
trap finish EXIT

section_start "Setup and install"
lsb_release -a

# configure, make and install (but skip documentation)
make configure
./configure --with-baseurl='http://localhost/domjudge/' --with-domjudge-user=domjudge --with-judgehost_chrootdir=${DIR}/chroot/domjudge |& tee "$ARTIFACTS/configure.log"
make judgehost |& tee "$ARTIFACTS/make.log"
sudo make install-judgehost |& tee -a "$ARTIFACTS/make.log"
section_end

section_start "Configure chroot"

if [ -e ${DIR}/chroot/domjudge ]; then
    rm -rf ${DIR}/chroot/domjudge
fi

cd ${DIR}/misc-tools || exit 1
section_end

section_start "Test chroot contents"
cp ${DIR}/submit/assert.bash ./
cp ${DIR}/.github/jobs/data/chroot.bats ./
bats ./chroot.bats
echo $?
section_end
