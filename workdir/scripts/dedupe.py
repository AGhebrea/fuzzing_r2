#!/usr/bin/python

import os, tlsh
from pathlib import Path

# i also had to do this on the valgrind output:
# grep -rL "LEAK SUMMARY" . | xargs rm

# TARGET_DIR = Path(f"{os.getenv("AFLR2_ROOT")}/workdir/output/valgrind")
TARGET_DIR = Path(f"/tmp/map")
# i did some empirical checks and found that above 500 the files are quite different. 
# at around 300 they are kind of the same. we could go as low as 100 - 120 but that gives us a lot
# of triage work
# the idea is that we can do this, fix leaks, then redo the process again.
# you can also lower treshold and then run again on same dir, pretty cool.
TRESHOLD = 700

def main():
    hd = {}
    print("Calculating hashes")
    for file in TARGET_DIR.iterdir():
        h = tlsh.hash(open(file, 'rb').read())
        if h not in hd:
            hd[h] = [0, file]
        l = hd[h]
        l[0] += 1
        # if l[0] > 1:
        #     raise ValueError("Same hash appears twice, TODO: need to key by files")

    print("Removing files")
    for h1 in hd:
        if hd[h1][0] == 0:
            continue
        for h2 in hd:
            if hd[h2][0] == 0:
                continue
            if h1 == h2:
                continue
            score = tlsh.diff(h1, h2)
            if score < TRESHOLD:
                os.remove(str(hd[h2][1]))
                hd[h2][0] = 0

if __name__ == "__main__":
    main()