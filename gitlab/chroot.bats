#!/usr/bin/env bats

load 'assert'

CHROOT="/chroot/domjudge"
if [ -n "${CI_JOB_ID+x}" ]; then
    CHROOT="/builds/DOMjudge/domjudge${CHROOT}"
fi
# Cleanup old dir
rm -rf $CHROOT

COMMANDARGS=""
if [ -n "${ARCH+x}" ]; then
    COMMANDARGS="-a $ARCH $COMMANDARGS"
fi
if [ -n "${MIRROR+x}" ]; then
    COMMANDARGS="-m $MIRROR $COMMANDARGS"
fi
if [ -n "${FORCEDOWNLOAD+x}" ]; then
    if [ $FORCEDOWNLOAD = 1 ]; then
        COMMANDARGS="-f $COMMANDARGS"
    else
        apt-get remove -y debootstrap
    fi
fi
if [ -n "${FORCEYES+x}" ]; then
    COMMANDARGS="-y $COMMANDARGS"
fi

expect_help () {
    assert_partial "Usage:"
    assert_partial "Creates a chroot environment with Java JRE support using the"
    assert_partial "Debian or Ubuntu GNU/Linux distribution."
    assert_partial "Options"
    assert_partial "Available architectures:"
    assert_partial "Environment Overrides:"
    assert_partial "This script must be run as root"
}

@test "help output" {
    run ./dj_make_chroot -h
    expect_help
    assert_success
}

@test "No arguments on non Debian/Ubuntu" {
    if [ -f /etc/debian_release ]; then
        skip "Debian based system detected"
    fi
    run ./dj_make_chroot
    assert_line "Defaulting to 'stable' release for Debian"
    assert_line "Error: No architecture given or detected."
    expect_help
    assert_failure
}

@test "Test chroot fails if unsupported architecture given" {
    if [ -n "${ARCH+x}" ]; then
        skip "Already an Arch set in the commands."
    fi
    run ./dj_make_chroot $COMMANDARGS -a dom04
    assert_failure
    assert_partial "Error: Architecture dom04 not supported for"
}

@test "Test confirmation on deletion of old chroot" {
    # Create old chroot folder
    mkdir $CHROOT
    run ./dj_make_chroot $COMMANDARGS
    assert_partial "$CHROOT already exists, remove? (y/N)"
    assert_failure
    rm -rf $CHROOT
}

@test "Test confirmation on installing debootstrap" {
    if [ -f /etc/debian_release ]; then
        skip "Non Debian based system"
    fi
    if [ -z "${FORCEDOWNLOAD+x}" ]; then
        skip "Debootstrap already installed"
    fi
    run ./dj_make_chroot $COMMANDARGS
    assert_partial "Do you want to install debootstrap using apt-get? (y/N)"
    assert_failure
}

# Creation of the chroot is slow so we run all tests inside 1 large test to speedup.
@test "Test chroot works with args: $COMMANDARGS" {
    if [ ! -f /etc/debian_release && -z "${ARCH+x}" ]; then
        skip "Non Debian based system detected, so we result in 'No arguments on non Debian/Ubuntu'"
    fi
    run ./dj_make_chroot $COMMANDARGS
    assert_partial "Done building chroot in $CHROOT"
    assert_success
    if [ -n "${FORCEDOWNLOAD+x}" || ! -f /etc/debian_release ]; then
        assert_partial "Downloading debootstrap to temporary directory at"
        run find /tmp/*/usr/sbin/ -name debootstrap
        assert_partial "usr/sbin/debootstrap"
        assert_success
        run find /tmp/*/usr/share/debootstrap/scripts/ -name bookworm
        assert_partial "usr/share/debootstrap/scripts/bookworm"
        assert_success
    fi
    if [ -n "${ARCH+x}" ]; then
        run ./dj_run_chroot "dpkg --print-architecture"
        assert_partial "$ARCH"
        assert_success
    else
        HOSTARCH=$(dpkg --print-architecture)
        run ./dj_run_chroot "dpkg --print-architecture"
        assert_partial "$HOSTARCH"
        assert_success
    fi
}
