#!/usr/bin/env python
#
# computes movie popularity for comma-separated ratings files of
# (user, movie, rating) data.
#

import sys
from collections import defaultdict

if __name__ == '__main__':

    # read input file from command line argument
    fname = sys.argv[1]

    # initialize empty dictionary to hold number of ratings for each
    # movie
    movies = defaultdict(int)

    # loop over movies and increment count for each movie we see
    for line in open(fname, 'r'):
        user, movie, rating = line.rstrip('\n').split(',')

        movies[movie] += 1

    # print out each movie and its total number of ratings
    for movie, num_ratings in movies.iteritems():
        print "%s\t%d" % (movie, num_ratings)
