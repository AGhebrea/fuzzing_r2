#!/usr/bin/bash

TESTCASE_DIR="${2}"
TARGET_BASE="${AFLR2_ROOT}/workdir/targets/${1}"
TARGET="${TARGET_BASE}/radare2"
TARGET_LIB="${TARGET_BASE}/libr"
LIBC_PRELOAD="${AFLR2_ROOT}/libc_shim/build/libc.so"
AFL_PRELOAD="${LIBC_PRELOAD}:${TARGET_LIB}/libr_anal.so:${TARGET_LIB}/libr_arch.so:${TARGET_LIB}/libr_asm.so:${TARGET_LIB}/libr_bin.so:${TARGET_LIB}/libr_bp.so:${TARGET_LIB}/libr_config.so:${TARGET_LIB}/libr_cons.so:${TARGET_LIB}/libr_core.so:${TARGET_LIB}/libr_debug.so:${TARGET_LIB}/libr_egg.so:${TARGET_LIB}/libr_esil.so:${TARGET_LIB}/libr_flag.so:${TARGET_LIB}/libr_fs.so:${TARGET_LIB}/libr_io.so:${TARGET_LIB}/libr_lang.so:${TARGET_LIB}/libr_magic.so:${TARGET_LIB}/libr_main.so:${TARGET_LIB}/libr_muta.so:${TARGET_LIB}/libr_reg.so:${TARGET_LIB}/libr_search.so:${TARGET_LIB}/libr_socket.so:${TARGET_LIB}/libr_syscall.so:${TARGET_LIB}/libr_util.so:${TARGET_LIB}/io_shm.so"
# AFL_PRELOAD="${AFL_PRELOAD}" afl-showmap -t 5000 -i ${TESTCASE_DIR} -o /tmp/map -- ${TARGET} -AA -NN -qq @@
export AFL_NO_FORKSRV=1
export AFL_DEBUG=1
# export AFL_FORKSRV_INIT_TMOUT=99999
AFL_PRELOAD="${AFL_PRELOAD}" afl-showmap -t 99999 -i ${TESTCASE_DIR} -o /tmp/map -- ${TARGET} -AA -NN -qq @@