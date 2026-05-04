#!/usr/bin/sh

MASTER_STATE="${AFLR2_ROOT}/workdir/output/.master_state"
CRASH_DIR="${AFLR2_ROOT}/workdir/output/crashes"
find -L $MASTER_STATE -wholename "*/crashes/*" -type f -print0 | xargs -0 -I {} cp --update=none {} "${CRASH_DIR}"
rm ${CRASH_DIR}/README.txt