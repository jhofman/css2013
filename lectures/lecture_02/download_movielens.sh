#!/bin/bash

DATA_DIR=../../data

# 100K: http://www.grouplens.org/system/files/ml-100k.zip
# 1M: http://www.grouplens.org/system/files/ml-1m.zip
# 10M: http://www.grouplens.org/sites/www.grouplens.org/external_files/data/ml-10m.zip
url=http://www.grouplens.org/sites/www.grouplens.org/external_files/data/ml-10m.zip

# create movielens directory 
[ -d $DATA_DIR/movielens ] || mkdir -p $DATA_DIR/movielens

# change to movielens directory
cd $DATA_DIR/movielens

# download ratings zip file
[ -f movielens_10M.zip ] || curl -o movielens_10M.zip $url

# uncompress zip file
if [ ! -f ratings.dat ]
    then
    unzip movielens_10M.zip && mv ml-10M100K/* .
fi

# reformat to comma-separated file
[ -f ratings.csv ] || cat ratings.dat | sed 's/::/,/g' > ratings.csv

