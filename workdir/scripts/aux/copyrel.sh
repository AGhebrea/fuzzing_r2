#!/usr/bin/bash

SOURCE="${AFLR2_ROOT}/radare2/"
if [[ "$#" == 2 ]]; then
    SOURCE="${2}"
fi
TARGET="${AFLR2_ROOT}/workdir/targets/${1}"
if [ ! -d "${TARGET}" ]; then
    mkdir ${TARGET}
fi
if [ ! -d "${TARGET}/libr" ]; then
    mkdir ${TARGET}/libr
fi

cp -f ${SOURCE}/binr/radare2/radare2 $TARGET
cp -f ${SOURCE}/libr/anal/libr_anal.so $TARGET/libr/
cp -f ${SOURCE}/libr/arch/libr_arch.so $TARGET/libr/
cp -f ${SOURCE}/libr/asm/libr_asm.so $TARGET/libr/
cp -f ${SOURCE}/libr/bin/libr_bin.so $TARGET/libr/
cp -f ${SOURCE}/libr/bp/libr_bp.so $TARGET/libr/
cp -f ${SOURCE}/libr/config/libr_config.so $TARGET/libr/
cp -f ${SOURCE}/libr/cons/libr_cons.so $TARGET/libr/
cp -f ${SOURCE}/libr/core/libr_core.so $TARGET/libr/
cp -f ${SOURCE}/libr/debug/libr_debug.so $TARGET/libr/
cp -f ${SOURCE}/libr/egg/libr_egg.so $TARGET/libr/
cp -f ${SOURCE}/libr/esil/libr_esil.so $TARGET/libr/
cp -f ${SOURCE}/libr/flag/libr_flag.so $TARGET/libr/
cp -f ${SOURCE}/libr/fs/libr_fs.so $TARGET/libr/
cp -f ${SOURCE}/libr/io/libr_io.so $TARGET/libr/
cp -f ${SOURCE}/libr/io/p/io_shm.so $TARGET/libr/
cp -f ${SOURCE}/libr/lang/libr_lang.so $TARGET/libr/
cp -f ${SOURCE}/libr/magic/libr_magic.so $TARGET/libr/
cp -f ${SOURCE}/libr/main/libr_main.so $TARGET/libr/
cp -f ${SOURCE}/libr/muta/libr_muta.so $TARGET/libr/
cp -f ${SOURCE}/libr/reg/libr_reg.so $TARGET/libr/
cp -f ${SOURCE}/libr/search/libr_search.so $TARGET/libr/
cp -f ${SOURCE}/libr/socket/libr_socket.so $TARGET/libr/
cp -f ${SOURCE}/libr/syscall/libr_syscall.so $TARGET/libr/
cp -f ${SOURCE}/libr/util/libr_util.so $TARGET/libr/