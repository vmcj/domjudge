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
#    run ./dj_make_chroot -a $ARCH
#    assert_success
#    assert_partial "Done building chroot in /chroot/domjudge"
#    run ./dj_run_chroot "dpkg --print-architecture"
#    assert_success
#    assert_partial "$ARCH"
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
#    run ./dj_make_chroot -a $ARCH
#    assert_success
#    assert_partial "Done building chroot in /builds/DOMjudge/domjudge/chroot/domjudge"
#    run ./dj_run_chroot "dpkg --print-architecture"
#    assert_success
#    assert_partial "$ARCH"
#}
#
#@test "Test chroot works without architecture given" {
#    if [ -n ${ARCH+x} ]; then
#        skip "Arch set"
#    fi
#    HOSTARCH=$(dpkg --print-architecture)
#    run ./dj_make_chroot
#    assert_success
#    assert_line "Done building chroot in /builds/DOMjudge/domjudge/chroot/domjudge"
#    run ./dj_run_chroot
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
#@test "Test chroot works without architecture given" {
#    if [ -n "${ARCH+x}" ]; then
#        skip "Arch set"
#    fi
#    HOSTARCH=$(dpkg --print-architecture)
#    run ./dj_make_chroot
#    assert_success
#    assert_line "Done building chroot in /builds/DOMjudge/domjudge/chroot/domjudge"
#    run ./dj_run_chroot
#    assert_success
#    if [ -n "${ARCH+x}" ]; then
#        run ./dj_run_chroot "dpkg --print-architecture"
#        assert_partial "$ARCH"
#        assert_success
#    else
#        HOSTARCH=$(dpkg --print-architecture)
#        run ./dj_run_chroot "dpkg --print-architecture"
#        assert_partial "$HOSTARCH"
#        assert_success
#    fi
#}
#@test "help output" {
#    run ./dj_make_chroot -h
#    assert_success
#    assert_regex "^Usage: .* [options]..."
#    assert_line "Available architectures:"
#    assert_line "Environment Overrides:"
#    assert_line "This script must be run as root"
#}
#
#@test "Test chroot works with architecture: $ARCH" {
#    if [ -z ${ARCH+x} ]; then
#        skip "Arch not set"
#    fi
#    run ./dj_make_chroot -a $ARCH
#    assert_success
#    assert_line "Done building chroot in /chroot/domjudge"
#    run ./dj_run_chroot "dpkg --print-architecture"
#    assert_success
#    assert_line "$ARCH"
#}
#
#@test "Test chroot works without architecture given" {
#    if [ -n ${ARCH+x} ]; then
#        skip "Arch set"
#    fi
#    HOSTARCH=$(dpkg --print-architecture)
#    run ./dj_make_chroot
#    assert_success
#    assert_line "Done building chroot in /chroot/domjudge"
#    run ./dj_run_chroot
#    assert_success
#    CHROOTARCH=$(dpkg --print-architecture)
#    assert_equal "$CHROOTARCH" "$HOST$ARCH" 
#}
#

@test "Test chroot fails if unsupported architecture given" {
    if [ -n "${ARCH+x}" ]; then
        skip "Arch set"
    fi
    run ./dj_make_chroot -a dom04
    assert_failure
    assert_line "Error: Architecture dom04 not supported for Ubuntu"
}

@test "Passing the Distro gives a chroot of that Distro" {
    if [ -z "${DISTRO+x}" ]; then
        skip "Distro not set"
    fi
    run ./dj_make_chroot -D $DISTRO
    assert_success
    assert_line "Done building chroot in /builds/DOMjudge/domjudge/chroot/domjudge"
    run ./dj_run_chroot
    run cat /etc/issue
    assert_success
    if [ "Debian" = "$DISTRO" ]; then
        assert_partial "Debian"
    else
        assert_partial "Ubuntu"
    fi
}

@test "Unknown Distro breaks" {
    if [ -n "${DISTRO+x}" ]; then
        skip "Distro set"
    fi
    run ./dj_make_chroot -D "BSD"
    assert_failure
    assert_line "Error: Invalid distribution specified, only 'Debian' and 'Ubuntu' are supported."
}

@test "Unknown Release breaks" {
    if [ -n "${DISTRO+x}" ] || [ -n "${RELEASE+x}" ]; then
        skip "Distro/Release set"
    fi
    run ./dj_make_chroot -R "Olympos"
    assert_failure
    assert_line "E: No such script: /usr/share/debootstrap/scripts/Olympos"
}

#@test "Passing Debian Release 
#@test "contest via parameter overrides environment" {
#    run ./submit -c bestaatniet
#    assert_failure 1
#    assert_partial "error: No (valid) contest specified"
#
#    run ./submit --contest=bestaatookniet
#    assert_failure 1
#    assert_partial "error: No (valid) contest specified"
#}
#
#@test "hello problem id and name are in help output" {
#    run ./submit --help
#    assert_success
#    assert_regex "hello *- *Hello World"
#}
#
#@test "languages and extensions are in help output" {
#    run ./submit --help
#    assert_success
#    assert_regex "C *- *c"
#    assert_regex "C\+\+ *- *c\+\+, cc, cpp, cxx"
#    assert_regex "Java *- *java"
#}
#
#@test "stale file emits warning" {
#    touch -d '2000-01-01' $BATS_TMPDIR/test-hello.c
#    run ./submit -p hello $BATS_TMPDIR/test-hello.c <<< "n"
#    assert_regex "test-hello.c' has not been modified for [0-9]* minutes!"
#}
#
#@test "recent file omits warning" {
#    touch $BATS_TMPDIR/test-hello.c
#    run ./submit -p hello $BATS_TMPDIR/test-hello.c <<< "n"
#    refute_line -e "test-hello.c' has not been modified for [0-9]* minutes!"
#}
#
#@test "binary file emits warning" {
#    cp $(which bash) $BATS_TMPDIR/binary.c
#    run ./submit -p hello $BATS_TMPDIR/binary.c <<< "n"
#    assert_partial "binary.c' is detected as binary/data!"
#}
#
#@test "empty file emits warning" {
#    touch $BATS_TMPDIR/empty.c
#    run ./submit -p hello $BATS_TMPDIR/empty.c <<< "n"
#    assert_partial "empty.c' is empty"
#}
#
#@test "detect problem name and language" {
#    cp ../tests/test-hello.java $BATS_TMPDIR/hello.java
#    run ./submit $BATS_TMPDIR/hello.java <<< "n"
#    assert_line "Submission information:"
#    assert_line "  problem:     hello"
#    assert_line "  language:    Java"
#}
#
#@test "options override detection of problem name and language" {
#    cp ../tests/test-hello.java $BATS_TMPDIR/hello.java
#    run ./submit -p boolfind -l cpp $BATS_TMPDIR/hello.java <<< "n"
#    assert_line "Submission information:"
#    assert_line "  problem:     boolfind"
#    assert_line "  language:    C++"
#}
#
#@test "non existing problem name emits error" {
#    cp ../tests/test-hello.java $BATS_TMPDIR/hello.java
#    run ./submit -p nonexistent -l cpp $BATS_TMPDIR/hello.java <<< "n"
#    assert_failure 1
#    assert_partial "error: No known problem specified or detected"
#}
#
#@test "non existing language name emits error" {
#    cp ../tests/test-hello.java $BATS_TMPDIR/hello.java
#    run ./submit -p boolfind -l nonexistent $BATS_TMPDIR/hello.java <<< "n"
#    assert_failure 1
#    assert_partial "error: No known language specified or detected"
#}
#
#@test "detect entry point Java" {
#    skip "Java does not require an entry point in the default installation"
#    run ./submit -p hello ../tests/test-hello.java <<< "n"
#    assert_line '  entry point: test-hello'
#}
#
#@test "detect entry point Python" {
#    skip "Python does not require an entry point in the default installation"
#    touch $BATS_TMPDIR/test-extra.py
#    run ./submit -p hello ../tests/test-hello.py $BATS_TMPDIR/test-extra.py <<< "n"
#    assert_line '  entry point: test-hello.py'
#}
#
#@test "detect entry point Kotlin" {
#    run ./submit --help
#    if ! echo "$output" | grep 'Kotlin:' ; then
#        skip "Kotlin not enabled"
#    fi
#    run ./submit -p hello ../tests/test-hello.kt <<< "n"
#    assert_line '  entry point: Test_helloKt'
#}
#
#@test "options override entry point" {
#    run ./submit -p hello -e Main ../tests/test-hello.java <<< "n"
#    assert_line '  entry point: Main'
#
#    run ./submit -p hello --entry_point=mypackage.Main ../tests/test-hello.java <<< "n"
#    assert_line '  entry point: mypackage.Main'
#}
#
#@test "accept multiple files" {
#    cp ../tests/test-hello.java ../tests/test-classname.java ../tests/test-package.java $BATS_TMPDIR/
#    run ./submit -p hello $BATS_TMPDIR/test-*.java <<< "n"
#    assert_line "  filenames:   $BATS_TMPDIR/test-classname.java $BATS_TMPDIR/test-hello.java $BATS_TMPDIR/test-package.java"
#}
#
#@test "deduplicate multiple files" {
#    cp ../tests/test-hello.java ../tests/test-package.java $BATS_TMPDIR/
#    run ./submit -p hello $BATS_TMPDIR/test-hello.java $BATS_TMPDIR/test-hello.java $BATS_TMPDIR/test-package.java <<< "n"
#    assert_line "  filenames:   $BATS_TMPDIR/test-hello.java $BATS_TMPDIR/test-package.java"
#}
#
#@test "submit solution" {
#    run ./submit -y -p hello ../tests/test-hello.c
#    assert_success
#    assert_regex "Submission received: id = s[0-9]*, time = [0-9]{2}:[0-9]{2}:[0-9]{2}"
#    assert_regex "Check http[^ ]*/[0-9]* for the result."
#}
##!/usr/bin/env bats
## These tests can be run without a working DOMjudge API endpoint.
#
#load 'assert'
#
#setup() {
#    export SUBMITBASEHOST="domjudge.example.org"
#    export SUBMITBASEURL="https://${SUBMITBASEHOST}/somejudge"
#}
#
#
#@test "baseurl set in environment" {
#    run ./submit
#    assert_failure 1
#    assert_regex "$SUBMITBASEHOST.*/api(/.*)?/contests.*: \[Errno -2\] Name or service not known"
#}
#
#@test "baseurl via parameter overrides environment" {
#    run ./submit --url https://domjudge.example.edu
#    assert_failure 1
#    assert_regex "domjudge.example.edu.*/api(/.*)?/contests.*: \[Errno -2\] Name or service not known"
#
#    run ./submit -u https://domjudge3.example.edu
#    assert_failure 1
#    assert_regex "domjudge3.example.edu.*/api(/.*)?/contests.*: \[Errno -2\] Name or service not known"
#}
#
#@test "baseurl can end in slash" {
#    run ./submit --url https://domjudge.example.edu/domjudge/
#    assert_failure 1
#    assert_regex "domjudge.example.edu.*/api(/.*)?/contests.*: \[Errno -2\] Name or service not known"
#}
#
#@test "display basic usage information" {
#    run ./submit --help
#    assert_success
#    assert_line "usage: submit [--version] [-h] [-c CONTEST] [-p PROBLEM] [-l LANGUAGE] [-e ENTRY_POINT]"
#    assert_line "              [-v [{DEBUG,INFO,WARNING,ERROR,CRITICAL}]] [-q] [-y] [-u URL]"
#    # The help printer does print this differently on versions of argparse for nargs=*.
#    assert_regex "              (filename )?[filename ...]"
#    assert_line "Submit a solution for a problem."
#    assert_success
#    assert_line "The (pre)configured URL is '$SUBMITBASEURL/'"
#    assert_success
#    assert_regex "~/\\.netrc"
#    assert_failure 2
#    assert_line "submit: error: unrecognized arguments: --doesnotexist"
#    assert_failure 1
#    assert_partial "set verbosity to INFO"
