#!/bin/bash

# mac: /usr/libexec/java_home
# windows: ?
JAVA_HOME="/System/Library/Java/JavaVirtualMachines/1.6.0.jdk/Contents/Home"
PIG="/Users/jakehofman/research/cssbook/course/lectures/lecture_4/pig-0.10.1/bin/pig"

$PIG -x local \
    -p INPUT='enwiki-text.tsv' \
    -p OUTPUT='enwiki-wordcount' \
    wordcount.pig
