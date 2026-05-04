#!/usr/bin/bash

CRASH_DIR="${AFLR2_ROOT}/workdir/output/crashes"
# ./workdir/scripts/run.py -t fuzzing_23_april -i '-AA -NN -qq /home/kali/workspace/projects/r2/fuzzing_r2/workdir/output/crashes/id:000000,sig:11,src:000494,time:670203,execs:33803,op:havoc,rep:5'

# TODO: run them on a sanitized build, not a normal one (!!!)
# now that we use ASAN it's a must. But also if we don't since we 
# might catch extra stuff, seeing that fuzzing is not stable.
# TODO: also run under valgrind. the combination should be enough.

for file in ${CRASH_DIR}/27_04_2026/*; do
    if [ -f "$file" ]; then
        ${AFLR2_ROOT}/workdir/scripts/run.py -t $1 -i "-AA -NN -qq ${file}"
        if [ $? != 0 ]; then
            echo ${file}
        fi
    fi
done