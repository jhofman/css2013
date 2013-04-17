Template files and sample data for homework 2.

## Problem 1:

	run_wordcount.sh: driver script to run wordcount.pig
		set JAVA_HOME and PIG_BIN appropriately, run as ./run_wordcount.sh
	wordcount.pig: template for problem 1 solution
	enwiki-text.tsv: sample input with wikipedia article ids, urls, and text

## Problem 2:

	run_pagepop.sh: driver script to run pagepop.pig
		set JAVA_HOME and PIG_BIN appropriately, run as ./run_pagepop.sh
	pagepop.pig: template for problem 2 solution
	enwiki-edges.tsv: sample input with wikipedia article ids, urls, and links

Note: Dummy links are included for a subset of the target pages for easy testing. These are indicated by a '#' as the target in the third field.

## Problem 3:

	erdos_nodes.txt: space-separated author ids and quoted names
	erdos_adjlist.txt: space-separated author id and coauthor ids
	download_erdos.sh: script that produced above files from original .net file
