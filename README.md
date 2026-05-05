# Setup
Source the setup.sh script from within this repo directory:
( Be aware that running/sourcing setup.sh when fuzzing is running will mess up fuzzing and it will have to be restarted. )
``` sh
source setup.sh
```
You need to build radare2 with AFL++ and copy libr/* and radare2 binary in targets. You can use the copyrel.sh script for copying the files

# Building radare2
## Non ASAN, AFL++ instrumented build:
Inside of the radare2 directory:
``` sh
export CFLAGS="-g3 -DR_LOG_DISABLE"
export AFL_LLVM_LAF_ALL=1
CC=afl-clang-lto ./configure AR=llvm-ar RANLIB=llvm-ranlib AS=llvm-as
make all
```
## ASAN, AFL++ instrumented build
Inside of the radare2 directory:
``` sh
export CFLAGS="-g3 -DR_LOG_DISABLE"
export AFL_LLVM_LAF_ALL=1
export AFL_USE_ASAN=1
./configure CC=${AFLR2_ROOT}/workdir/scripts/aux/hack-clang-lto-asan LIBS="-lasan" AR=llvm-ar RANLIB=llvm-ranlib AS=llvm-as
make all
```

# Running
To start the fuzzing campaign, you need to do the setup from above and run:
``` sh
./workdir/scripts/multicore.py
```
to monitor progress:
(For this to work I had to modify the afl-whatsup script, search for "find . -maxdepth 2 -iname fuzzer_setup" in afl-whatsup and change it to "find . -L -maxdepth 2 -iname fuzzer_setup")
``` sh
watch -n 900 afl-whatsup -s "${AFLR2_ROOT}/workdir/output/.master_state"
```