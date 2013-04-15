#!/bin/bash
#
# Driver script to run Pig page popularity locally
#
# Takes sample input from enwiki-edges.tsv and produces output in
# enwiki-pagepop directory from the pagepop.pig script
#

# Usage:
#  1. Set JAVA_HOME below to point to your local java runtime environment path
#     (You can find this on mac os x using: /usr/libexec/java_home)
#  2. Set PIG_BIN below to point to your local pig binary directory
#  3. Run the script with ./run_pagepop.sh
JAVA_HOME="/System/Library/Java/JavaVirtualMachines/1.6.0.jdk/Contents/Home"
PIG_BIN=~/pig-0.10.1/bin

# No need to modify below
$PIG_BIN/pig -x local \
    -p INPUT='enwiki-edges.tsv' \
    -p OUTPUT='enwiki-pagepop' \
    pagepop.pig
