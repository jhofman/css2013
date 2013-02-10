#!/bin/bash

DATA_DIR=../../data

url=http://www.lifecrunch.biz/wp-content/uploads/2011/04/nf_prize_dataset.tar.gz

# create netflix directory
[ -d $DATA_DIR/netflix ] || mkdir -p $DATA_DIR/netflix 

# change to this directory
cd $DATA_DIR/netflix

# download .tar.gz file
[ -f netflix.tar.gz ] || curl -o netflix.tar.gz 

# uncompress .tar.gz file
if [ ! -f training_set.tar ]
    then
    tar zxvf netflix.tar.gz && mv download/* .
fi

# uncompress .tar file of ratings
[ -d training_set ] || tar xvf training_set.tar

# reformat ratings to one comma-separated file with (user, movie, rating) fields
if [ ! -f ratings.csv ]
then
    for f in training_set/*.txt
    do 
	awk -F, '{if (NR == 1) {movie=$1; sub(":","",movie)} else print $1","movie","$2}' < $f
    done > ratings.csv
fi
