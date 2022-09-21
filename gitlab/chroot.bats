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
if [ -n "${REPO+x}" ]; then
    COMMANDARGS="-s $REPO $COMMANDARGS"
fi

@test "help output" {
    run ./dj_make_chroot -h
    assert_success
    assert_partial "Usage:"
    assert_partial "Creates a chroot environment with Java JRE support using the"
    assert_partial "Debian or Ubuntu GNU/Linux distribution."
    assert_partial "Options"
    assert_partial "Available architectures:"
    assert_partial "Environment Overrides:"
    assert_partial "This script must be run as root"
}

@test "Test chroot fails if unsupported architecture given" {
    if [ -n "${ARCH+x}" ]; then
        skip "Already an Arch set in the commands."
    fi
    for unsupported_arch in 'dom04' 'arm' '64' 'namd64' 'amd64v2'; do
        run ./dj_make_chroot $COMMANDARGS -a $unsupported_arch
        assert_failure
        assert_partial "Error: Architecture $unsupported_arch not supported for"
    done
}

@test "Test chroot fails if unreadable list is provided" {
    if [ -n "${REPO+x}" ]; then
        skip "Already a repolist set in the commands."
    fi
    for unreadable_file in '/notafile'; do
        run ./dj_make_chroot $COMMANDARGS -a $unreadable_file
        assert_failure
        assert_partial "Error: Repolist can not be read"
    done
}

# Creation of the chroot is slow so we run all tests inside 1 large test to speedup.
@test "Test chroot works with args: $COMMANDARGS" {
    run ./dj_make_chroot $COMMANDARGS
    assert_partial "Done building chroot in $CHROOT"
    assert_success
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
    # We always find the php version packaged with focal
    run ./dj_run_chroot "apt-cache show php7.4"
    assert_success
    assert_partial "Package: php7.4"
    assert_partial "Maintainer: Ubuntu Developers <ubuntu-devel-discuss@lists.ubuntu.com>"
    if [ -n "${REPO+x}" ]; then
        tmp_REPO="${REPO}"
        while [ -n "${tmp_REPO}" ]; do
          case $tmp_REPO in
            *icpc*)
		kotlinc="kotlinc -"
		run ./dj_run_chroot "apt-cache search kotlinc"
                assert_success
		if [ -n "${ARCH+x}" ] && [ "$ARCH" != "amd64"]; then
                    refute_partial "$kotlinc"
                else
                    assert_partial "$kotlinc"
                fi
                tmp_REPO={$tmp_REPO//icpc};;
            *pypy*)
                run ./dj_run_chroot "apt-cache search pypy3"
                assert_success
                assert_partial "+dfsg-1~ppa1~ubuntu20.04"
                tmp_REPO={$tmp_REPO//pypy};;
            *php*)
                run ./dj_run_chroot "apt-cache show php8.1"
                assert_success
                assert_partial "deb.sury.org+1"
                tmp_REPO={$tmp_REPO//php};;
            *) echo "Unknown combination"; exit 1;;
          esac
          tmp_REPO=${tmp_REPO//,,/,}
        done
    else
        run ./dj_run_chroot "apt-cache search kotlinc"
        assert_failure
        run ./dj_run_chroot "apt-cache search php8.1"
        assert_failure
        run ./dj_run_chroot "apt-cache search pypy3-venv"
        assert_failure
    fi
}
