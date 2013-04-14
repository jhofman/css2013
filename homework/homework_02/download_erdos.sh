#!/bin/bash

# download original file
wget http://vlado.fmf.uni-lj.si/pub/networks/data/Erdos/Erdos02.net

# extract author labels as:
#   id  "last, first"
grep '"' Erdos02.net > erdos_nodes.txt

# extract adjacency list as:
#   id  coauthor1 coauthor2 ...
grep -v '["\*%]' Erdos02.net > erdos_edges.txt