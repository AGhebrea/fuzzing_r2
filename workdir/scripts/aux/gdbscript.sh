
# set exec-wrapper env LD_PRELOAD=/home/kali/workspace/projects/r2/fuzzing_r2/libc_shim/build/libc.so

# directory "/home/kali/workspace/sources/AFLplusplus/"

# can do "continue &" and now breakpoints are per thread (weren't they always ?)
# set non-stop on


# set follow-fork-mode parent
# set detach-on-fork off
# set follow-exec-mode same
# set pagination off

# catch exec
# catch fork
# catch fork
# catch exec
# catch syscall kill
# start
# r
# c &

# add-symbol-file /home/kali/workspace/projects/r2/fuzzing_r2/workdir/targets/fuzzing_4_april/radare2
# add-symbol-file /home/kali/workspace/projects/r2/fuzzing_r2/workdir/targets/fuzzing_4_april/libr/libr_anal.so
# add-symbol-file /home/kali/workspace/projects/r2/fuzzing_r2/workdir/targets/fuzzing_4_april/libr/libr_arch.so
# add-symbol-file /home/kali/workspace/projects/r2/fuzzing_r2/workdir/targets/fuzzing_4_april/libr/libr_asm.so
# add-symbol-file /home/kali/workspace/projects/r2/fuzzing_r2/workdir/targets/fuzzing_4_april/libr/libr_bin.so
# add-symbol-file /home/kali/workspace/projects/r2/fuzzing_r2/workdir/targets/fuzzing_4_april/libr/libr_bp.so
# add-symbol-file /home/kali/workspace/projects/r2/fuzzing_r2/workdir/targets/fuzzing_4_april/libr/libr_config.so
# add-symbol-file /home/kali/workspace/projects/r2/fuzzing_r2/workdir/targets/fuzzing_4_april/libr/libr_cons.so
# add-symbol-file /home/kali/workspace/projects/r2/fuzzing_r2/workdir/targets/fuzzing_4_april/libr/libr_core.so
# add-symbol-file /home/kali/workspace/projects/r2/fuzzing_r2/workdir/targets/fuzzing_4_april/libr/libr_debug.so
# add-symbol-file /home/kali/workspace/projects/r2/fuzzing_r2/workdir/targets/fuzzing_4_april/libr/libr_egg.so
# add-symbol-file /home/kali/workspace/projects/r2/fuzzing_r2/workdir/targets/fuzzing_4_april/libr/libr_esil.so
# add-symbol-file /home/kali/workspace/projects/r2/fuzzing_r2/workdir/targets/fuzzing_4_april/libr/libr_flag.so
# add-symbol-file /home/kali/workspace/projects/r2/fuzzing_r2/workdir/targets/fuzzing_4_april/libr/libr_fs.so
# add-symbol-file /home/kali/workspace/projects/r2/fuzzing_r2/workdir/targets/fuzzing_4_april/libr/libr_io.so
# add-symbol-file /home/kali/workspace/projects/r2/fuzzing_r2/workdir/targets/fuzzing_4_april/libr/libr_lang.so
# add-symbol-file /home/kali/workspace/projects/r2/fuzzing_r2/workdir/targets/fuzzing_4_april/libr/libr_magic.so
# add-symbol-file /home/kali/workspace/projects/r2/fuzzing_r2/workdir/targets/fuzzing_4_april/libr/libr_main.so
# add-symbol-file /home/kali/workspace/projects/r2/fuzzing_r2/workdir/targets/fuzzing_4_april/libr/libr_muta.so
# add-symbol-file /home/kali/workspace/projects/r2/fuzzing_r2/workdir/targets/fuzzing_4_april/libr/libr_reg.so
# add-symbol-file /home/kali/workspace/projects/r2/fuzzing_r2/workdir/targets/fuzzing_4_april/libr/libr_search.so
# add-symbol-file /home/kali/workspace/projects/r2/fuzzing_r2/workdir/targets/fuzzing_4_april/libr/libr_socket.so
# add-symbol-file /home/kali/workspace/projects/r2/fuzzing_r2/workdir/targets/fuzzing_4_april/libr/libr_syscall.so
# add-symbol-file /home/kali/workspace/projects/r2/fuzzing_r2/workdir/targets/fuzzing_4_april/libr/libr_util.so
# directory /home/kali/workspace/projects/r2/fuzzing_r2/radare2

# b __magic_file_check_mem