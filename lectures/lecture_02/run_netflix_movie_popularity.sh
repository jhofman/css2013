#!/bin/bash

ratings=../../data/netflix/ratings.csv
output=../../data/netflix/movie_popularity

# python
echo "running python"
time ./netflix.py $ratings > ${output}_py.tsv

# awk
echo "running awk"
time awk -F, '{counts[$2]++} END {for (k in counts) print counts[k]"\t"k}' < $ratings > ${output}_awk.tsv

# uniq (assumes pre-grouped)
echo "running uniq"
time cut -d, -f2 $ratings | uniq -c > ${output}_uniq.tsv
