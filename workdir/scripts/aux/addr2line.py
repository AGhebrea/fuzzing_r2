#!/usr/bin/python
import re, os

# TODO: remove hardcoded paths

unknown = 0
edge_map = {}
edge_map_re = r"ModuleID=(\d+) Function=(.*?(?= edgeID)) edgeID=(\d+)"
map_re = r"(\d+):(\d+)"
with open(f"{os.getenv("AFLR2_ROOT")}/workdir/data/edge_map.txt", "r") as f:
    l = f.readline()
    while(l != ""):
        m = re.search(edge_map_re, l)
        edgeid = int(m[3])
        function = m[2]
        moduleid = m[1]
        edge_map[edgeid] = function
        l = f.readline()
with open("/tmp/map/0fc9818d6fc3427c13e17bf23d586772", "r") as f:
    with open("/tmp/map2line/0fc9818d6fc3427c13e17bf23d586772", "w") as o:
        l = f.readline()
        while(l != ""):
            m = re.search(map_re, l)
            edgeid = int(m[1])
            hits = m[2]
            function = edge_map.get(edgeid, None)
            if function is None:
                function = f"Unknown_{edgeid}"
                # debug 
                unknown += 1
            line = f"{function}:{hits}\n"
            l = f.readline()
            o.write(line)
print(f"Unknown edges: {unknown}")