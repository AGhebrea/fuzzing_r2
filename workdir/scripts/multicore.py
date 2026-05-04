#!/usr/bin/python
# example taken from https://gamozolabs.github.io/fuzzing/2018/09/16/scaling_afl.html

import subprocess, threading, os, sys, copy
from dataclasses import dataclass

_global_cpu = 0
class CPUConfig:
    cpu:int = None
    asan:bool = None
    arg:str = None
    power:str = None

    def __init__(self, asan: bool, arg: str, power: str):
        global _global_cpu
        self.cpu = _global_cpu
        _global_cpu += 1
        self.asan = asan
        self.arg = arg
        self.power = power

@dataclass
class Environment:
    target:str = None
    env:dict = None
    memory_max:str = None

class ConfigArray:
    cpu_configs: list = []

    def setConfig(self, cfg: CPUConfig, times):
        self.cpu_configs.append(cfg)
        for _ in range(times-1):
            self.cpu_configs.append(
                CPUConfig(
                    asan = cfg.asan,
                    arg = cfg.arg,
                    power = cfg.power
                )
            )

ca = ConfigArray()
ca.setConfig(CPUConfig(asan=False,  arg="-M", power="explore"),     1)
ca.setConfig(CPUConfig(asan=False,  arg="-S", power="explore"),     3)
ca.setConfig(CPUConfig(asan=False,  arg="-S", power="quad"),        8)
ca.setConfig(CPUConfig(asan=False,  arg="-S", power="rare"),        8)
ca.setConfig(CPUConfig(asan=False,  arg="-S", power="coe"),         10)
ca.setConfig(CPUConfig(asan=False,  arg="-S", power="exploit"),     4)
ca.setConfig(CPUConfig(asan=False,  arg="-S", power="fast"),        16)
ca.setConfig(CPUConfig(asan=False,  arg="-S", power="mopt"),        2)
ca.setConfig(CPUConfig(asan=False,  arg="-S", power="mmopt"),       6)
ca.setConfig(CPUConfig(asan=True,   arg="-S", power="explore"),     2)
ca.setConfig(CPUConfig(asan=True,   arg="-S", power="fast"),        1)
ca.setConfig(CPUConfig(asan=True,   arg="-S", power="coe"),         1)
ca.setConfig(CPUConfig(asan=True,   arg="-S", power="rare"),        1)
ca.setConfig(CPUConfig(asan=True,   arg="-S", power="exploit"),     1)

asan_env:Environment = None
vanilla_env:Environment = None
setup_print = False;
VERSION_NAME="fuzzing_23_april"
VERSION_NAME_ASAN="fuzzing_asan_23_april"
root_dir = os.getenv("AFLR2_ROOT")
INPUT_DIR  = f"{root_dir}/workdir/output/input_ramdisk"
OUTPUT_DIR_BASE = f"{root_dir}/workdir/output/output_ramdisks"
libc_shim_dir = os.getenv("AFLR2_LIBC_SHIM")
mockfile = os.getenv("AFLR2_MOCKFILE")
LIBC_PRELOAD=f"{libc_shim_dir}/libc.so"
LIBC_NOPRINT_PRELOAD=f"{libc_shim_dir}/libc_noprint.so"
LIBC_PRINT_PRELOAD=f"{libc_shim_dir}/libc_print.so"
OUTPUT_RAMDISKS = 8
NORMALIZE = _global_cpu // OUTPUT_RAMDISKS

def _init_env(env, asan) -> Environment:
    if asan:
        vname = VERSION_NAME_ASAN
        memory_max = "20"
    else:
        vname =  VERSION_NAME
        memory_max = "3"

    local_env = copy.deepcopy(env)
    LIBR_PATH=f"{root_dir}/workdir/targets/{vname}/libr/"
    AFL_PRELOAD=f"{LIBC_PRELOAD}:{LIBR_PATH}libr_anal.so:{LIBR_PATH}libr_arch.so:{LIBR_PATH}libr_asm.so:{LIBR_PATH}libr_bin.so:{LIBR_PATH}libr_bp.so:{LIBR_PATH}libr_config.so:{LIBR_PATH}libr_cons.so:{LIBR_PATH}libr_core.so:{LIBR_PATH}libr_debug.so:{LIBR_PATH}libr_egg.so:{LIBR_PATH}libr_esil.so:{LIBR_PATH}libr_flag.so:{LIBR_PATH}libr_fs.so:{LIBR_PATH}libr_io.so:{LIBR_PATH}libr_lang.so:{LIBR_PATH}libr_magic.so:{LIBR_PATH}libr_main.so:{LIBR_PATH}libr_muta.so:{LIBR_PATH}libr_reg.so:{LIBR_PATH}libr_search.so:{LIBR_PATH}libr_socket.so:{LIBR_PATH}libr_syscall.so:{LIBR_PATH}libr_util.so:{LIBR_PATH}io_shm.so"
    local_env["AFL_PRELOAD"] = AFL_PRELOAD
    local_env["ASAN_OPTIONS"] = "detect_leaks=0:abort_on_error=1:symbolize=0:detect_stack_use_after_return=0"
    return Environment(
        f"{root_dir}/workdir/targets/{vname}/radare2",
        local_env,
        memory_max
    )

def init_env() -> tuple[dict, dict]:
    global setup_print
    global asan_env
    global vanilla_env
    env = os.environ.copy()
    env["AFL_NO_AFFINITY"] = "1"
    env["AFL_AUTORESUME"] = "1"
    env["LD_PRELOAD"] = LIBC_NOPRINT_PRELOAD
    # does not load plugins, which searches filesystem for some non existent config files and slows down exe.
    env["R2_DEBUG_NOLANG"]= "1"
    for arg in sys.argv:
        if arg == "--print":
            env["LD_PRELOAD"] = LIBC_PRINT_PRELOAD
            env["LD_PRELOAD"] = ""
            env["AFL_DEBUG"] = "1"
            setup_print = True
            break;
    asan_env = _init_env(env, True)
    vanilla_env = _init_env(env, False)
    asan_env.env["ASAN_OPTIONS"]="detect_leaks=0:abort_on_error=1:symbolize=0"

def do_work(cpu_config: CPUConfig):
    sp = None
    OUTPUT_DIR = f"{OUTPUT_DIR_BASE}/fuzz_{cpu_config.cpu // NORMALIZE}"
    if cpu_config.asan:
        local_env = asan_env.env
        target = asan_env.target
        memory_max = asan_env.memory_max
    else:
        local_env = vanilla_env.env
        target = vanilla_env.target
        memory_max = vanilla_env.memory_max

    while True:
        try:
            arr = [
                # "systemd-run", "--user", "--scope", "-p", f"MemoryMax={memory_max}G", # f"MemoryHigh={memory_high}G"
                "numactl", f"--physcpubind={cpu_config.cpu}", "--localalloc",
                "afl-fuzz", "-p", cpu_config.power, "-t", "10000", "-i", INPUT_DIR, "-o", OUTPUT_DIR,
                cpu_config.arg, f"fuzzer{cpu_config.cpu}", "--", 
                target, "-AA", "-qq", "-NN", "--fuzzing_loop", f"{mockfile}"]
            sp = subprocess.Popen(args=arr, env=local_env,
                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            sp.wait()
        except Exception as e:
            print(e)
            pass

        print("CPU %d afl-fuzz instance died" % cpu_config.cpu)
        if setup_print:
            stdout, stderr = sp.communicate()
            print(stdout)
            print(stderr)

def main():
    init_env()
    for cpu_config in ca.cpu_configs:
        threading.Timer(0.0, do_work, args=[cpu_config]).start()

    s = subprocess.Popen([f"{root_dir}/workdir/scripts/aux/rsync.sh"])
    # watch -n 900 afl-whatsup -s "${ROOT}/workdir/output/.master_state"

if __name__ == "__main__":
    main()