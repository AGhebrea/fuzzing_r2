#!/usr/bin/bash

IN="${AFLR2_ROOT}/workdir/output/queue"
OUT="${AFLR2_ROOT}/workdir/output/queue_ln"

echo $IN
echo $OUTls

for file in $IN/*; do
    ln -s $file $OUT/$(basename $file)
done