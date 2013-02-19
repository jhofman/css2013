#!/bin/bash

uniq -c | awk '{printf("%s\t%s\n",$2,$1)}'
