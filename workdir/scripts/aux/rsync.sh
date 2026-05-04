#!/usr/bin/bash
BASE="${AFLR2_ROOT}/workdir/output/output_ramdisks"
MASTER_QUEUE_DIR="${AFLR2_ROOT}/workdir/output/queue"
RAM_DISKS=("${BASE}/fuzz_0" "${BASE}/fuzz_1" "${BASE}/fuzz_2" "${BASE}/fuzz_3" "${BASE}/fuzz_4" "${BASE}/fuzz_5" "${BASE}/fuzz_6" "${BASE}/fuzz_7")

mkdir -p "$MASTER_QUEUE_DIR"

sleep 15m
while true; do
  for disk in "${RAM_DISKS[@]}"; do
    find "$disk" -type d -name "queue" -exec rsync -au --ignore-existing {}/ "$MASTER_QUEUE_DIR/" \;
    find "$disk" -type d -name "queue" -exec rsync -au --ignore-existing "$MASTER_QUEUE_DIR/" {}/ \;
  done

  fdupes -dN $MASTER_QUEUE_DIR &> /dev/null

  echo "Sync complete at $(date). Sleeping for 30 minutes..."
  sleep 30m
done