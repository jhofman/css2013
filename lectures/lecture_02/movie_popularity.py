#!/usr/bin/env python

import sys
from collections import defaultdict

if __name__=='__main__':

    fname = sys.argv[1]

    movies = defaultdict(int)
    for line in open(fname, 'r'):
        user, movie, rating = line.rstrip('\n').split(',')

        movies[movie] += 1

    for movie, num_ratings in movies.iteritems():
        print "%s\t%d" % (movie, num_ratings)
