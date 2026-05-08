#!/usr/bin/python
import os, subprocess, threading, shutil
from pathlib import Path

# TODO: we could try to run valgrind with -q

THREADS = 64
TARGET = "vanilla_31_march"
NO_ERRORS = "ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)"
root_dir = os.getenv("AFLR2_ROOT")
TARGET_DIR = f"{root_dir}/workdir/targets"
LINK_DIR = Path(f"{root_dir}/workdir/output/queue_ln");
OUT_DIR= f"{root_dir}/workdir/output/valgrind"
links = []

def prepare_env():
    env = os.environ.copy()
    lib_dir=f"{TARGET_DIR}/{TARGET}/libr"
    target = f"{TARGET_DIR}/{TARGET}/radare2"
    env["LD_PRELOAD"] = f"{lib_dir}/libr_crypto.so:{lib_dir}/libr_anal.so:{lib_dir}/libr_arch.so:{lib_dir}/libr_asm.so:{lib_dir}/libr_bin.so:{lib_dir}/libr_bp.so:{lib_dir}/libr_config.so:{lib_dir}/libr_cons.so:{lib_dir}/libr_core.so:{lib_dir}/libr_debug.so:{lib_dir}/libr_egg.so:{lib_dir}/libr_esil.so:{lib_dir}/libr_flag.so:{lib_dir}/libr_fs.so:{lib_dir}/libr_io.so:{lib_dir}/libr_lang.so:{lib_dir}/libr_magic.so:{lib_dir}/libr_main.so:{lib_dir}/libr_muta.so:{lib_dir}/libr_reg.so:{lib_dir}/libr_search.so:{lib_dir}/libr_socket.so:{lib_dir}/libr_syscall.so:{lib_dir}/libr_util.so:{lib_dir}/io_shm.so"
    return env, target

def do_work(arr, tid):
    env, target = prepare_env()
    logfile = f"/tmp/valgrind_out_{tid}_.txt";
    for file in arr:
        args = [
            "valgrind", "--leak-check=full", "--show-leak-kinds=all", "--track-origins=yes", f"--log-file={logfile}",
            target, "-AA", "-qq", "-NN", file
        ]
        sp = subprocess.Popen(args=args, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        sp.wait()
        args = [
            "grep", NO_ERRORS, logfile
        ]
        sp = subprocess.Popen(args=args, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout, stderr = sp.communicate()
        if len(stdout) == 0:
            shutil.copy(logfile, f"{OUT_DIR}/{file.name}.valgrind-out.txt", follow_symlinks=True)
        os.remove(file)

def main():
    for file in LINK_DIR.iterdir():
        links.append(file)
    l = len(links)
    if l == 0:
        MSG = f"{LINK_DIR} has no links. Run './workdir/scripts/aux/makelns.sh'"
        raise ValueError(MSG)
    l1 = l // THREADS
    l1rem = l % THREADS
    pos = 0
    for tid in range(THREADS - 1):
        arr = links[pos:l1+pos]
        pos += l1
        threading.Timer(0.0, do_work, args=[arr, tid]).start()
    arr = links[pos:l1+l1rem+pos]
    threading.Timer(0.0, do_work, args=[arr, tid]).start()

if __name__ == "__main__":
    main()