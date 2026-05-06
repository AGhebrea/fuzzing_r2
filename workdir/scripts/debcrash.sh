#!/usr/bin/sh

TARGET=$1
if [[ $2 == "-l" ]]; then
    VARIABLE="-l"
else
    VARIABLE="-a -AA -qq -NN $2"
fi
LD_LIBRARY_PATH="${AFLR2_ROOT}/workdir/targets/${TARGET}/libr/" rrrr.sh -c -t ${AFLR2_ROOT}/workdir/targets/${TARGET}/radare2 ${VARIABLE} -- -x "${AFLR2_ROOT}/workdir/aux/gdbscript.sh"