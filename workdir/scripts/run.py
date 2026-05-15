#!/usr/bin/python
import argparse, sys, os, pexpect

# TODO: do some predefined configs.
# e.g debug config:
#   ./workdir/scripts/run.py -l LD_LIBRARY_PATH -c 'gdb --args' -t vanilla_31_march -i '-AA -NN /usr/bin/ls'
#   ./workdir/scripts/run.py -l LD_LIBRARY_PATH -c 'gdb -x /home/kali/workspace/projects/r2/fuzzing_r2/workdir/scripts/aux/gdbscript.sh --args' -t fuzzing_asan_23_april -i '-AA -NN -qq /home/kali/workspace/projects/r2/fuzzing_r2/workdir/output/crashes/id:000000,sig:11,src:000575,time:79368519,execs:489622,op:havoc,rep:2'
# e.g strace config, etc..
# ASAN /usr/lib/libasan.so
root_dir = os.getenv("AFLR2_ROOT")
TARGET_DIR = f"{root_dir}/workdir/targets"

def parse_args():
    parser = argparse.ArgumentParser(
        prog=sys.argv[0],
        description="Run custom r2 with libraries"
    )
    # todo:
    # parser.add_argument("--config", required=False, type=str, help="Load predefined config.");
    parser.add_argument("-l", "--libs", required=False, default="LD_PRELOAD", type=str, help="Pass libs with LD_PRELOAD or LD_LIBRARY_PATH.")
    parser.add_argument("-c", "--command", required=False, default="", type=str, help="Prepend command to invocation, must be quoted")
    parser.add_argument("-t", "--target", required=True, type=str, help="Custom R2 target taken from targets dir")
    parser.add_argument("-s", "--shim", action="store_true", required=False, default=False, help="Load libc shim")
    parser.add_argument("-i", "--inferior", required=False, nargs='...', default="", type=str, help="R2 arguments, must be last")
    parser.add_argument("-p", "--preload", required=False, default="", type=str, help="Extra libraries to preload")
    args = parser.parse_args()
    if args.preload != "" and args.preload[-1] != ":":
        args.preload += ":"
    return args

def prepare_env(args):
    env = os.environ.copy()
    env["R2_DEBUG_NOLANG"] = "1"
    lib_dir=f"{TARGET_DIR}/{args.target}/libr"
    env["LD_PRELOAD"] = ""
    if args.shim:
        env["LD_PRELOAD"] += f"{os.getenv("AFLR2_LIBC_SHIM")}/libc_print.so:"
    if args.libs == "LD_LIBRARY_PATH":
        env["LD_LIBRARY_PATH"] = lib_dir
    else:
        env["LD_PRELOAD"] += f"{args.preload}{lib_dir}/libr_anal.so:{lib_dir}/libr_arch.so:{lib_dir}/libr_asm.so:{lib_dir}/libr_bin.so:{lib_dir}/libr_bp.so:{lib_dir}/libr_config.so:{lib_dir}/libr_cons.so:{lib_dir}/libr_core.so:{lib_dir}/libr_debug.so:{lib_dir}/libr_egg.so:{lib_dir}/libr_esil.so:{lib_dir}/libr_flag.so:{lib_dir}/libr_fs.so:{lib_dir}/libr_io.so:{lib_dir}/libr_lang.so:{lib_dir}/libr_magic.so:{lib_dir}/libr_main.so:{lib_dir}/libr_muta.so:{lib_dir}/libr_reg.so:{lib_dir}/libr_search.so:{lib_dir}/libr_socket.so:{lib_dir}/libr_syscall.so:{lib_dir}/libr_util.so:{lib_dir}/io_shm.so"
    return env

def normalize(arr):
    # remove empty strings that can come from non mandatory args
    arr = [s for s in arr if s != ""]

    flattened = []
    for item in arr:
        if isinstance(item, list):
            flattened.extend(item)
        else:
            flattened.append(item)
    s = ""
    for el in flattened:
        s+=el
        s+=" "
    return s

def main():
    args = parse_args()
    env = prepare_env(args)
    target = f"{TARGET_DIR}/{args.target}/radare2"
    command = normalize([args.command, target, args.inferior])
    p = pexpect.spawn(command=command, env=env)
    if sys.stdout.isatty():
        p.interact()
        p.close()
    else:
        p.logfile_read = sys.stdout.buffer
        p.expect(pexpect.EOF)
    p.wait()

    # debug
    print(f"$ {command}")
    print(f"exitstatus:     {p.exitstatus}")
    print(f"signalstatus:   {p.signalstatus}")

    # propagate signal or exitcode
    status = p.exitstatus
    if p.signalstatus != None:
        status = 128 + p.signalstatus
    exit(status)

if __name__ == "__main__":
    main()