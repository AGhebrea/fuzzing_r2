#!/usr/bin/bash

base="/home/kali/workspace/projects/r2/fuzzing_r2/workdir/targets/vanilla_23_april"
target="${base}/radare2"
lib_dir="${base}/libr"
LD_PRELOAD="${lib_dir}/libr_anal.so:${lib_dir}/libr_arch.so:${lib_dir}/libr_asm.so:${lib_dir}/libr_bin.so:${lib_dir}/libr_bp.so:${lib_dir}/libr_config.so:${lib_dir}/libr_cons.so:${lib_dir}/libr_core.so:${lib_dir}/libr_debug.so:${lib_dir}/libr_egg.so:${lib_dir}/libr_esil.so:${lib_dir}/libr_flag.so:${lib_dir}/libr_fs.so:${lib_dir}/libr_io.so:${lib_dir}/libr_lang.so:${lib_dir}/libr_magic.so:${lib_dir}/libr_main.so:${lib_dir}/libr_muta.so:${lib_dir}/libr_reg.so:${lib_dir}/libr_search.so:${lib_dir}/libr_socket.so:${lib_dir}/libr_syscall.so:${lib_dir}/libr_util.so:${lib_dir}/io_shm.so"

LD_PRELOAD=${LD_PRELOAD} $target -AA -NN -qq $1